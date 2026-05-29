import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icalendar_parser/icalendar_parser.dart';

import '../../domain/entidades/evento_entidad.dart';
import '../../domain/casos_uso/evento_casos_uso.dart';

// --- Estado ---
class EventoState {
  final bool cargando;
  final List<EventoEntidad> eventos; // Eventos personales filtrados (SQLite)
  final List<Map<String, dynamic>> eventosOficiales; // Eventos del ICS
  final DateTime fechaSeleccionada;
  final String? error;
  final List<EventoEntidad> todosEventos; // Todos los de SQLite (para puntos en calendario)
  final String? filtroCategoria;
  final List<int> eventosSeleccionados;

  EventoState({
    this.cargando = false,
    this.eventos = const [],
    this.eventosOficiales = const [],
    required this.fechaSeleccionada,
    this.error,
    this.todosEventos = const [],
    this.filtroCategoria,
    this.eventosSeleccionados = const [],
  });

  EventoState copyWith({
    bool? cargando,
    List<EventoEntidad>? eventos,
    List<Map<String, dynamic>>? eventosOficiales,
    DateTime? fechaSeleccionada,
    String? error,
    List<EventoEntidad>? todosEventos,
    String? filtroCategoria,
    List<int>? registrosSeleccionados,
  }) {
    return EventoState(
      cargando: cargando ?? this.cargando,
      eventos: eventos ?? this.eventos,
      eventosOficiales: eventosOficiales ?? this.eventosOficiales,
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
  final ObtenerEventos obtenerEventos;
  final EliminarEvento eliminarEvento;

  EventoCubit({
    required this.obtenerEventos,
    required this.eliminarEvento,
  }) : super(EventoState(fechaSeleccionada: DateTime.now(), cargando: true));

  /// Carga los eventos desde SQLite filtrados por la fecha seleccionada
  Future<void> cargarEventos(DateTime fecha) async {
    emit(state.copyWith(cargando: true, fechaSeleccionada: fecha, error: null));
    try {
      final todos = await obtenerEventos();

      // Filtrar eventos personales que coincidan con el día
      final filtradosPorFecha = todos.where((e) => _dateInRange(fecha, e)).toList();
      
      final String? filtroActual = state.filtroCategoria;
      List<EventoEntidad> listaFinal = filtradosPorFecha;

      // Aplicar filtro de categoría si existe
      if (filtroActual != null && filtroActual != "Todos") {
        listaFinal = filtradosPorFecha
            .where((r) => r.tipo_evento == filtroActual)
            .toList();
      }

      emit(
        state.copyWith(
          cargando: false,
          eventos: listaFinal,
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

  /// Carga y parsea el calendario escolar desde el archivo ICS en assets
  Future<void> inicializarCalendarioDesdeAssets() async {
    try {
      final contenido = await rootBundle.loadString('assets/files/calendario_2025_2026.ics');
      final icp = ICalendar.fromString(contenido);
      
      final oficiales = icp.data
          .where((item) => item['type'] == 'VEVENT')
          .map((e) {
            final title = e['summary'] as String? ?? '';
            // El parser devuelve IcsDateTime, lo convertimos a DateTime de Dart
            final DateTime dtStart = (e['dtstart'] as IcsDateTime).toDateTime()!;
            final DateTime dtEnd = (e['dtend'] as IcsDateTime).toDateTime()!;

            return {
              'titulo': title,
              'inicio': dtStart,
              'fin': dtEnd,
              'color': _obtenerColorIcs(title),
              'esOficial': true,
            };
          }).toList();

      emit(state.copyWith(eventosOficiales: oficiales));
    } catch (e) {
      debugPrint("Error cargando calendario oficial: $e");
    }
  }

  void cambiarFecha(DateTime nuevaFecha) => cargarEventos(nuevaFecha);

  void seleccionarFiltro(String? categoria) {
    emit(state.copyWith(filtroCategoria: categoria));
    cargarEventos(state.fechaSeleccionada);
  }

  // --- Lógica de Selección y Borrado ---

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

  Future<void> borrarSeleccionados() async {
    emit(state.copyWith(cargando: true));
    try {
      for (var id in state.eventosSeleccionados) {
        await eliminarEvento(id);
      }
      emit(state.copyWith(registrosSeleccionados: []));
      await cargarEventos(state.fechaSeleccionada);
    } catch (e) {
      emit(state.copyWith(cargando: false, error: "Error al eliminar múltiples registros"));
    }
  }
  

  // --- Helpers ---

  bool _dateInRange(DateTime date, EventoEntidad e) {
    try {
      final inicio = DateTime.parse(e.fecha_inicio);
      final fin = DateTime.parse(e.fecha_fin);
      final dia = DateTime(date.year, date.month, date.day);
      
      // Ajuste para que el día final sea inclusivo hasta medianoche
      final finInclusivo = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);

      return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) &&
          (dia.isBefore(finInclusivo));
    } catch (_) {
      return false;
    }
  }

  Color _obtenerColorIcs(String titulo) {
    final t = titulo.toLowerCase();
    if (t.contains('consejo técnico')) return Colors.orange;
    if (t.contains('receso') || t.contains('vacaciones')) return Colors.green;
    if (t.contains('suspensión') || t.contains('festivo')) return Colors.red;
    if (t.contains('boletas') || t.contains('administrativo')) return Colors.blue;
    return Colors.blueGrey;
  }
}