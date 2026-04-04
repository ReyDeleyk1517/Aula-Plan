class BitacoraEntidad {
  final int? id;
  final String fecha;
  final String hora;
  final String categoria;
  final String titulo;
  final String actividad;
  final String observaciones;
  final int? perfilId;
  // Campo opcional para grado y grupo
  final String? grado_y_grupo;

  BitacoraEntidad({
    this.id,
    required this.fecha,
    required this.hora,
    required this.categoria,
    required this.titulo,
    required this.actividad,
    required this.observaciones,
    this.perfilId,
    this.grado_y_grupo,
  });
}
