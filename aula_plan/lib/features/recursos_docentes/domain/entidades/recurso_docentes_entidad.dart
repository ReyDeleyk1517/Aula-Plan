// domain/entities/recurso_educativo.dart

class RecursoDocenteEntidad {
  final int? id;
  final String nombre;
  final String area;
  final String campoFormativo;
  final String tipoArchivo;
  final String? rutaArchivo;
  final String? enlace;
  final DateTime fechaCreacion;
  final int? perfilId;

  const RecursoDocenteEntidad({
    required this.id,
    required this.nombre,
    required this.area,
    required this.campoFormativo,
    required this.tipoArchivo,
    this.rutaArchivo,
    this.enlace,
    required this.fechaCreacion,
    this.perfilId
  });

}