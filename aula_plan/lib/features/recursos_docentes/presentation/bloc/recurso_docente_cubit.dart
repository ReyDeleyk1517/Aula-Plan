import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p; // Importante para manejar rutas multiplataforma

import '../../domain/entidades/recurso_docentes_entidad.dart';
import '../../domain/casos_uso/recurso_docentes_casos_uso.dart';

class RecursosDocenteState {
  final List<RecursoDocenteEntidad> recursos;
  final List<int> seleccionadosIds;
  final bool cargando;
  final String filtroArea;
  final String filtroCampo;
  final String filtroTipo;
  final String busqueda;

  const RecursosDocenteState({
    this.recursos = const [],
    this.seleccionadosIds = const [],
    this.cargando = false,
    this.filtroArea = 'Todas',
    this.filtroCampo = 'Todos',
    this.filtroTipo = 'Todos',
    this.busqueda = '',
  });

  RecursosDocenteState copyWith({
    List<RecursoDocenteEntidad>? recursos,
    List<int>? seleccionadosIds,
    bool? cargando,
    String? filtroArea,
    String? filtroCampo,
    String? filtroTipo,
    String? busqueda,
  }) {
    return RecursosDocenteState(
      recursos: recursos ?? this.recursos,
      seleccionadosIds: seleccionadosIds ?? this.seleccionadosIds,
      cargando: cargando ?? this.cargando,
      filtroArea: filtroArea ?? this.filtroArea,
      filtroCampo: filtroCampo ?? this.filtroCampo,
      filtroTipo: filtroTipo ?? this.filtroTipo,
      busqueda: busqueda ?? this.busqueda,
    );
  }

  List<RecursoDocenteEntidad> get recursosFiltrados {
    return recursos.where((r) {
      final coincideArea = filtroArea == 'Todas' || r.area == filtroArea;
      final coincideCampo = filtroCampo == 'Todos' || r.campoFormativo == filtroCampo;
      
      bool coincideTipo = true;
      if (filtroTipo != 'Todos') {
        final ext = r.tipoArchivo?.toLowerCase() ?? '';
        switch (filtroTipo) {
          case 'Documentos':
            coincideTipo = ['pdf', 'doc', 'docx', 'txt', 'odt'].contains(ext);
            break;
          case 'Imagen':
            coincideTipo = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
            break;
          case 'Video':
            coincideTipo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
            break;
          case 'Enlace': 
            coincideTipo = (ext == 'enlace'); 
            break;
          case 'Otros':
            const categoriasConocidas = [
              'pdf', 'doc', 'docx', 'txt', 'odt',
              'jpg', 'jpeg', 'png', 'webp', 'gif',
              'mp4', 'mov', 'avi', 'mkv', 'webm','enlace'
            ];
            coincideTipo = !categoriasConocidas.contains(ext);
            break;
        }
      }

      final coincideBusqueda = busqueda.isEmpty || 
          r.nombre.toLowerCase().contains(busqueda.toLowerCase());
      return coincideArea && coincideCampo && coincideTipo && coincideBusqueda;
    }).toList();
  }
}

class RecursosDocenteCubit extends Cubit<RecursosDocenteState> {
  final ObtenerRegistrosRecursos obtenerRegistros;
  final EliminarRegistroRecursos eliminarRegistro;

  RecursosDocenteCubit({
    required this.obtenerRegistros,
    required this.eliminarRegistro,
  }) : super(const RecursosDocenteState());

  Future<void> cargarRecursos() async {
    emit(state.copyWith(cargando: true));
    try {
      final lista = await obtenerRegistros();
      final idsValidos = state.seleccionadosIds.where((id) => lista.any((r) => r.id == id)).toList();
      emit(state.copyWith(recursos: lista, seleccionadosIds: idsValidos, cargando: false));
    } catch (e) {
      emit(state.copyWith(cargando: false));
    }
  }

  Future<void> eliminarRecurso(int id) async {
    await eliminarRegistro(id);
    await cargarRecursos();
  }

  void cambiarFiltroArea(String area) => emit(state.copyWith(filtroArea: area));
  void cambiarFiltroCampo(String campo) => emit(state.copyWith(filtroCampo: campo));
  void cambiarFiltroTipo(String tipo) => emit(state.copyWith(filtroTipo: tipo));
  void actualizarBusqueda(String query) => emit(state.copyWith(busqueda: query));

  void toggleSeleccion(int id) {
    final nuevosSeleccionados = List<int>.from(state.seleccionadosIds);
    nuevosSeleccionados.contains(id) ? nuevosSeleccionados.remove(id) : nuevosSeleccionados.add(id);
    emit(state.copyWith(seleccionadosIds: nuevosSeleccionados));
  }

  Future<void> exportarAZip() async {
    if (state.seleccionadosIds.isEmpty) return;
    emit(state.copyWith(cargando: true));

    try {
      final archive = Archive();
      
      for (var id in state.seleccionadosIds) {
        final recurso = state.recursos.firstWhere((r) => r.id == id);
        
        if (recurso.tipoArchivo == 'enlace') {
          // Limpiar nombre para evitar caracteres prohibidos en nombres de archivo
          final nombreSeguro = recurso.nombre.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
          final content = "Nombre: ${recurso.nombre}\nURL: ${recurso.enlace}";
          final bytes = utf8.encode(content);
          archive.addFile(ArchiveFile("$nombreSeguro.txt", bytes.length, bytes));
        } else if (recurso.rutaArchivo != null) {
          final file = File(recurso.rutaArchivo!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            // p.basename obtiene solo "archivo.ext" sin importar la plataforma
            final nombreArchivo = p.basename(recurso.rutaArchivo!);
            archive.addFile(ArchiveFile(nombreArchivo, bytes.length, bytes));
          }
        }
      }

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) throw Exception("No se pudo generar el ZIP");

      if (Platform.isWindows) {
        // --- LÓGICA WINDOWS ---
        final sugerenciaNombre = 'recursos_${DateTime.now().ms}.zip';
        
        String? selectedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar exportación ZIP',
          fileName: sugerenciaNombre,
          type: FileType.custom,
          allowedExtensions: ['zip'],
        );

        if (selectedPath != null) {
          final zipFile = File(selectedPath);
          await zipFile.writeAsBytes(zipData);
        }
      } else {
        // --- LÓGICA MÓVIL ---
        final directory = await getTemporaryDirectory();
        final zipFile = File('${directory.path}/recursos_${DateTime.now().ms}.zip');
        await zipFile.writeAsBytes(zipData);

        await Share.shareXFiles([XFile(zipFile.path)], text: 'Exportación de recursos');
      }

      emit(state.copyWith(seleccionadosIds: [], cargando: false));
    } catch (e) {
      print("Error en exportarAZip: $e");
      emit(state.copyWith(cargando: false));
    }
  }
}

extension on DateTime { int get ms => millisecondsSinceEpoch; }