import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/evento_entidad.dart';
import '../../domain/casos_uso/evento_casos_uso.dart';

class EventoState {
  final bool cargando;
  final List<EventoEntidad> eventos;
  final DateTime fechaSeleccionada;
  final String? error;

  // Todos los eventos disponibles (para calcular dots en el calendario)
  final List<EventoEntidad> todosEventos;
  final String? filtroCategoria;
  final List<int> eventosSeleccionados;

  EventoState({
    this.cargando = false,
    this.eventos = const [],
    required this.fechaSeleccionada,
    this.error,
    this.todosEventos = const [],
    this.filtroCategoria,
    this.eventosSeleccionados = const [],
  });

  // Método para copiar el estado fácilmente (pattern copyWith)
  EventoState copyWith({
    bool? cargando,
    List<EventoEntidad>? eventos,
    DateTime? fechaSeleccionada,
    String? error,
    List<EventoEntidad>? todosEventos,
    String? filtroCategoria,
    List<int>? registrosSeleccionados,
  }) {
    return EventoState(
      cargando: cargando ?? this.cargando,
      eventos: eventos ?? this.eventos,
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      error: error ?? this.error,
      todosEventos: todosEventos ?? this.todosEventos,
      filtroCategoria: filtroCategoria ?? this.filtroCategoria,
      eventosSeleccionados: registrosSeleccionados ?? this.eventosSeleccionados,
    );
  }
}

// --- Cubit ---
class EventoCubit extends Cubit<EventoState> {
  // Inyectar Casos de Uso en lugar del Repositorio
  final ObtenerEventos obtenerEventos;
  final EliminarEvento eliminarEvento;

  EventoCubit({required this.obtenerEventos, required this.eliminarEvento})
    : super(EventoState(fechaSeleccionada: DateTime.now(), cargando: true));

  Future<void> cargarEventos(DateTime fecha) async {
    emit(state.copyWith(cargando: true, fechaSeleccionada: fecha, error: null));
    try {
      //obtener todos los registros
      final todos = await obtenerEventos();

      // Filtrar por rango de fecha (inicio <= fecha <= fin)
      final filtrados = todos.where((e) => _dateInRange(fecha, e)).toList();
      final String? filtroActual = state.filtroCategoria;
      List<EventoEntidad> filtradosConFiltro = filtrados;
      if (filtroActual != null && filtroActual != "Todos") {
        filtradosConFiltro = filtrados
            .where((r) => r.tipo_evento == filtroActual)
            .toList();
      }
      // Actualizar todos los eventos para permitir dot en UI
      emit(
        state.copyWith(
          cargando: false,
          eventos: filtradosConFiltro,
          todosEventos: todos,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          cargando: false,
          error: "Error al cargar la información de eventos",
        ),
      );
    }
  }

  Future<void> borrarEvento(int id) async {
    try {
      await eliminarEvento(id);
      await cargarEventos(state.fechaSeleccionada);
    } catch (e) {
      emit(state.copyWith(error: "No se pudo eliminar el evento"));
    }
  }

  void cambiarFecha(DateTime nuevaFecha) => cargarEventos(nuevaFecha);

  // Formateo utilitario (no estricto, solo si se requiere en otros métodos)
  bool _dateInRange(DateTime fecha, EventoEntidad e) {
    try {
      final DateTime inicio = DateTime.parse(e.fecha_inicio);
      final DateTime fin = DateTime.parse(e.fecha_fin);
      final DateTime dia = DateTime(fecha.year, fecha.month, fecha.day);
      return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) &&
          (dia.isAtSameMomentAs(fin) || dia.isBefore(fin));
    } catch (_) {
      // Si falla el parse, no considerar el evento para el día
      return false;
    }
  }

  String _formatearFecha(DateTime fecha) =>
      "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

  void seleccionarFiltro(String? categoria) {
    // Actualizar estado
    emit(state.copyWith(filtroCategoria: categoria));
    // Recargar los registros para la fecha que este actualmente seleccionada con el nuevo filtro
    cargarEventos(state.fechaSeleccionada);
  }

  // Lógica de Selección
  void toggleSeleccion(int id) {
    final actuales = List<int>.from(state.eventosSeleccionados);
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

  // Lógica de Borrado Múltiple
  Future<void> borrarSeleccionados() async {
    emit(state.copyWith(cargando: true));
    try {
      // Borramos uno por uno usando el caso de uso existente
      for (var id in state.eventosSeleccionados) {
        await eliminarEvento(id);
      }
      // Limpiamos la lista de selección y recargamos
      emit(state.copyWith(registrosSeleccionados: []));
      await cargarEventos(state.fechaSeleccionada);
    } catch (e) {
      emit(
        state.copyWith(
          cargando: false,
          error: "Error al eliminar registros múltiples",
        ),
      );
    }
  }
}
