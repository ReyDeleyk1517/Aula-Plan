import 'dart:io';
import 'package:aula_plan/features/recursos_docentes/domain/casos_uso/recurso_docentes_casos_uso.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entidades/recurso_docentes_entidad.dart';

// --- STATE ---

class RecursosDocenteState {
  final List<RecursoDocenteEntidad> recursos;
  final List<int> seleccionadosIds; 
  final bool cargando;
  final String filtroArea;

  const RecursosDocenteState({
    this.recursos = const [],
    this.seleccionadosIds = const [],
    this.cargando = false,
    this.filtroArea = 'Todas',
  });

  RecursosDocenteState copyWith({
    List<RecursoDocenteEntidad>? recursos,
    List<int>? seleccionadosIds, 
    bool? cargando,
    String? filtroArea,
  }) {
    return RecursosDocenteState(
      recursos: recursos ?? this.recursos,
      seleccionadosIds: seleccionadosIds ?? this.seleccionadosIds,
      cargando: cargando ?? this.cargando,
      filtroArea: filtroArea ?? this.filtroArea,
    );
  }
}

// --- CUBIT ---

class RecursosDocenteCubit extends Cubit<RecursosDocenteState> {
  final ObtenerRegistrosRecursos obtenerRegistros;
  final EliminarRegistroRecursos eliminarRegistro;
  final GuardarRegistroRecursos guardarRegistros;

  RecursosDocenteCubit({
    required this.obtenerRegistros,
    required this.eliminarRegistro,
    required this.guardarRegistros,
  }) : super(const RecursosDocenteState());

  Future<void> cargarRecursos() async {
    emit(state.copyWith(cargando: true));
    try {
      final lista = await obtenerRegistros(); 
      emit(state.copyWith(recursos: lista, cargando: false));
    } catch (e) {
      emit(state.copyWith(cargando: false));
    }
  }

  Future<void> eliminarRecurso(int id) async {
    await eliminarRegistro(id);
    await cargarRecursos();
  }

  Future<void> agregarRecurso(RecursoDocenteEntidad nuevo) async {
    await guardarRegistros(nuevo);
    await cargarRecursos();
  }

  void toggleSeleccion(int id) { // Ahora recibe int
    final nuevosSeleccionados = List<int>.from(state.seleccionadosIds);
    if (nuevosSeleccionados.contains(id)) {
      nuevosSeleccionados.remove(id);
    } else {
      nuevosSeleccionados.add(id);
    }
    emit(state.copyWith(seleccionadosIds: nuevosSeleccionados));
  }

  void cambiarFiltro(String area) {
    emit(state.copyWith(filtroArea: area));
  }

  Future<void> exportarAZip() async {
    if (state.seleccionadosIds.isEmpty) return;

    try {
      final directory = await getTemporaryDirectory();
      final zipPath = '${directory.path}/recursos_docente.zip';
      
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);

      for (var id in state.seleccionadosIds) {
        // Buscamos el recurso por su ID (int)
        final recurso = state.recursos.firstWhere((r) => r.id == id);
        
        if (recurso.rutaArchivo != null && recurso.rutaArchivo!.isNotEmpty) {
          final file = File(recurso.rutaArchivo!);
          if (await file.exists()) {
            // Se usa el nombre del recurso para el archivo dentro del ZIP
            encoder.addFile(file, recurso.nombre);
          }
        }
      }
      encoder.close();

      await Share.shareXFiles(
        [XFile(zipPath, mimeType: 'application/zip')],
        text: 'Mis recursos docentes',
      );

      // Limpiar selección tras exportar
      emit(state.copyWith(seleccionadosIds: []));
    } catch (e) {
    }
  }
}