class EventoEntidad {
  final int? id;
  final String titulo;
  final String descripcion;
  final String fecha_inicio;
  final String fecha_fin;
  final String tipo_evento;
  final String lugar;
  final int? perfilId;

  EventoEntidad({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha_inicio,
    required this.fecha_fin,
    required this.tipo_evento,
    required this.lugar,
    this.perfilId,
  });
}
