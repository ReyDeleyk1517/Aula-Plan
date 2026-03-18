class BitacoraEntidad {
  final int? id;
  final String fecha;
  final String hora;
  final String categoria;
  final String titulo;
  final String actividad;
  final String observaciones;
  final int? perfilId;

  BitacoraEntidad({
    this.id,
    required this.fecha,
    required this.hora,
    required this.categoria,
    required this.titulo,
    required this.actividad,
    required this.observaciones,
    this.perfilId,
  });
}
