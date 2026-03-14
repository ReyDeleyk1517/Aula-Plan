import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/entidad_bitacora.dart';
//import '../../domain/repositorios/repositorio_bitacora.dart';
import '../../domain/casos_uso/casos_uso.dart';

class BitacoraState {
  final bool cargando;
  final List<EntidadBitacora> registros;
  final DateTime fechaSeleccionada;
  final String? error;

  final String? filtroCategoria;
  final List<int> registrosSeleccionados; 

  BitacoraState({
    this.cargando = false,
    this.registros = const [],
    required this.fechaSeleccionada,
    this.error,
    this.filtroCategoria,
    this.registrosSeleccionados = const [],
  });

  // Método para copiar el estado fácilmente (pattern copyWith)
  BitacoraState copyWith({
    bool? cargando,
    List<EntidadBitacora>? registros,
    DateTime? fechaSeleccionada,
    String? error,
    String? filtroCategoria,
    List<int>? registrosSeleccionados,
  }) {
    return BitacoraState(
      cargando: cargando ?? this.cargando,
      registros: registros ?? this.registros,
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      error: error ?? this.error,
      filtroCategoria: filtroCategoria ?? this.filtroCategoria,
      registrosSeleccionados: registrosSeleccionados ?? this.registrosSeleccionados,
    );
  }
}

// --- Cubit ---
class CubitBitacora extends Cubit<BitacoraState> {
  // Inyectar Casos de Uso en lugar del Repositorio
  final ObtenerRegistrosBitacora obtenerRegistros;
  final EliminarRegistroBitacora eliminarRegistro;


  CubitBitacora({
    required this.obtenerRegistros,

    required this.eliminarRegistro,

  }) : super(BitacoraState(fechaSeleccionada: DateTime.now(), cargando: true));

  Future<void> cargarRegistros(DateTime fecha) async {
    emit(state.copyWith(cargando: true, fechaSeleccionada: fecha, error: null));
    
    try {
      //obtener todos los registros
      final todos = await obtenerRegistros();
      
      final fechaFormateada = _formatearFecha(fecha);
      var filtrados = todos.where((r) => r.fecha == fechaFormateada).toList();
      final String? filtroActual = state.filtroCategoria;
      if (filtroActual != null && filtroActual != "Todos") {
        filtrados = filtrados.where((r) => r.categoria == filtroActual).toList();
      }
      
      emit(state.copyWith(cargando: false, registros: filtrados));
    } catch (e) {
      emit(state.copyWith(cargando: false, error: "Error al cargar la bitácora"));
    }
  }

  Future<void> borrarRegistro(int id) async {
    try {
      await eliminarRegistro(id);
      await cargarRegistros(state.fechaSeleccionada);
    } catch (e) {
      emit(state.copyWith(error: "No se pudo eliminar el registro"));
    }
  }

  void cambiarFecha(DateTime nuevaFecha) => cargarRegistros(nuevaFecha);

  String _formatearFecha(DateTime fecha) => 
      "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";


  void seleccionarFiltro(String? categoria) {
    // Actualizar estado
    emit(state.copyWith(filtroCategoria: categoria));
    // Recargar los registros para la fecha que este actualmente seleccionada con el nuevo filtro
    cargarRegistros(state.fechaSeleccionada);
  }

  // --- Lógica de Selección ---

  void toggleSeleccion(int id) {
    final actuales = List<int>.from(state.registrosSeleccionados);
    if (actuales.contains(id)) {
      actuales.remove(id);
    } else {
      actuales.add(id);
    }
    emit(state.copyWith(registrosSeleccionados: actuales));
  }

  void limpiarSeleccion() {
    emit(state.copyWith(registrosSeleccionados: []));
  }

  // --- Lógica de Borrado Múltiple ---

  Future<void> borrarSeleccionados() async {
    emit(state.copyWith(cargando: true));
    try {
      // Borramos uno por uno usando el caso de uso existente
      for (var id in state.registrosSeleccionados) {
        await eliminarRegistro(id);
      }
      
      // Limpiamos la lista de selección y recargamos
      emit(state.copyWith(registrosSeleccionados: []));
      await cargarRegistros(state.fechaSeleccionada);
    } catch (e) {
      emit(state.copyWith(cargando: false, error: "Error al eliminar registros múltiples"));
    }
  }
}
