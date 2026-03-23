import '../entidades/evento_entidad.dart';

abstract class EventoRepositorio{
  Future<List<EventoEntidad>> obtenerEventos();
  Future<void> guardarEvento(EventoEntidad evento);
  Future<void> eliminarEvento(int id);
  Future<void> editarEvento(EventoEntidad evento);
}