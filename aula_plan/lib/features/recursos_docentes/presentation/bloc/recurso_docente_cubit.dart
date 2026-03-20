import 'dart:io';
import 'package:aula_plan/features/recursos_docentes/domain/casos_uso/recurso_docentes_casos_uso.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entidades/recurso_docentes_entidad.dart';
import 'dart:convert';


class RecursosDocenteState {
  final List<RecursoDocenteEntidad> recursos;
  final List<int> seleccionadosIds;
  final bool cargando;
  
  // Filtros
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

  // Getter para obtener la lista ya filtrada directamente desde el estado
  List<RecursoDocenteEntidad> get recursosFiltrados {
    return recursos.where((r) {
      final coincideArea = filtroArea == 'Todas' || r.area == filtroArea;
      final coincideCampo = filtroCampo == 'Todos' || r.campoFormativo == filtroCampo;
      final coincideTipo = filtroTipo == 'Todos' || r.tipoArchivo?.toLowerCase() == filtroTipo.toLowerCase();
      final coincideBusqueda = busqueda.isEmpty || 
          r.nombre.toLowerCase().contains(busqueda.toLowerCase());

      return coincideArea && coincideCampo && coincideTipo && coincideBusqueda;
    }).toList();
  }
}

// CUBIT
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

  //  Metodos de Filtrado

  void cambiarFiltroArea(String area) => emit(state.copyWith(filtroArea: area));

  void cambiarFiltroCampo(String campo) => emit(state.copyWith(filtroCampo: campo));

  void cambiarFiltroTipo(String tipo) => emit(state.copyWith(filtroTipo: tipo));

  void actualizarBusqueda(String query) => emit(state.copyWith(busqueda: query));

  // Acciones de Datos 

  Future<void> eliminarRecurso(int id) async {
    await eliminarRegistro(id);
    await cargarRecursos();
  }

  Future<void> agregarRecurso(RecursoDocenteEntidad nuevo) async {
    await guardarRegistros(nuevo);
    await cargarRecursos();
  }

  void toggleSeleccion(int id) {
    final nuevosSeleccionados = List<int>.from(state.seleccionadosIds);
    if (nuevosSeleccionados.contains(id)) {
      nuevosSeleccionados.remove(id);
    } else {
      nuevosSeleccionados.add(id);
    }
    emit(state.copyWith(seleccionadosIds: nuevosSeleccionados));
  }

  // Exportacion

  Future<void> exportarAZip() async {
    if (state.seleccionadosIds.isEmpty) return;

    print("test pdf exportar");
    print("IDs solicitados: ${state.seleccionadosIds}");

    try {
      emit(state.copyWith(cargando: true));

      final archive = Archive(); // Objeto contenedor de la librería archive
      final directory = await getTemporaryDirectory();
      int archivosAgregadosContador = 0;

      // Procesar cada ID de forma secuencial
      for (var id in state.seleccionadosIds) {
        final recurso = state.recursos.firstWhere((r) => r.id == id);
        print("Procesando ID: $id | Nombre: ${recurso.nombre}");

        if (recurso.tipoArchivo == 'enlace') {
          // Manejar enlaces y convertirlos a txt
          if (recurso.enlace != null && recurso.enlace!.isNotEmpty) {
            final content = "Nombre: ${recurso.nombre}\nURL: ${recurso.enlace}";
            final bytes = utf8.encode(content);
            final nombreTxt = "${recurso.nombre.replaceAll(' ', '_')}_$id.txt";
            
            // Agregamos directamente al objeto Archive
            archive.addFile(ArchiveFile(nombreTxt, bytes.length, bytes));
            archivosAgregadosContador++;
            print("Añadido enlace como: $nombreTxt");
          }
        } else if (recurso.rutaArchivo != null) {
          // Manejar archivos fisicos
          final file = File(recurso.rutaArchivo!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes(); // Leer los bytes
            final nombreOriginal = recurso.rutaArchivo!.split('/').last;
            
            // Agregar los bytes al objeto Archive
            archive.addFile(ArchiveFile(nombreOriginal, bytes.length, bytes));
            archivosAgregadosContador++;
            print("Añadido archivo: $nombreOriginal (${bytes.length} bytes)");
          } else {
            print("ERROR: El archivo no existe en la ruta: ${recurso.rutaArchivo}");
          }
        }
      }

      print("Total archivos en objeto Archive: $archivosAgregadosContador");

      // Generamos el archivo ZIP final a partir del objeto Archive
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) throw Exception("Error al codificar el ZIP");

      final String zipPath = '${directory.path}/recursos_export_${DateTime.now().millisecondsSinceEpoch}.zip';
      final zipFile = File(zipPath);
      
      // Escribimos todo de una vez
      await zipFile.writeAsBytes(zipData, flush: true);
      print(" Archivo físico escrito en: $zipPath");
      print(" Tamaño final del ZIP: ${await zipFile.length()} bytes");

      // Verificación final antes de compartir
      if (archivosAgregadosContador == state.seleccionadosIds.length) {
        print(" Verificación exitosa: $archivosAgregadosContador de ${state.seleccionadosIds.length}");
        
        await Share.shareXFiles(
          [XFile(zipPath, mimeType: 'application/zip')],
          subject: 'Recursos Docentes',
          text: 'Exportación de $archivosAgregadosContador archivos.',
        );
      } else {
        print(" ERROR: Los archivos agregados no coinciden con la selección.");
      }

      emit(state.copyWith(seleccionadosIds: [], cargando: false));

    } catch (e) {
      print(" ERROR CRÍTICO: $e");
      emit(state.copyWith(cargando: false));
    }
  }
}
