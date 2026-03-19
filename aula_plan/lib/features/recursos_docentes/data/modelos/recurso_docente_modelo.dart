import '../../domain/entidades/recurso_docentes_entidad.dart';

class RecursoDocenteModelo extends RecursoDocenteEntidad {
  RecursoDocenteModelo({
    int? id,
    required String nombre,
    required String area,
    required String campoFormativo,
    required String tipoArchivo,
    String? rutaArchivo,
    String? enlace,
    required DateTime fechaCreacion,
    int? perfilId,
  }) : super(
          id: id,
          nombre: nombre,
          area: area,
          campoFormativo: campoFormativo,
          tipoArchivo: tipoArchivo,
          rutaArchivo: rutaArchivo,
          enlace: enlace,
          fechaCreacion: fechaCreacion,
          perfilId: perfilId,
        );

  factory RecursoDocenteModelo.desdeMapa(Map<String, dynamic> mapa) {
    
    final dynamic fc = mapa['fecha_creacion'];
    DateTime fechaCreacion;
    if (fc is DateTime) {
      fechaCreacion = fc;
    } else if (fc is String) {
      try {
        fechaCreacion = DateTime.parse(fc);
      } catch (_) {
        fechaCreacion = DateTime.now();
      }
    } else {
      fechaCreacion = DateTime.now();
    }

    return RecursoDocenteModelo(
      id: mapa['id'],
      nombre: mapa['nombre'] ?? '',
      area: mapa['area'] ?? '',
      campoFormativo: mapa['campo_formativo'] ?? '',
      tipoArchivo: mapa['tipo_archivo'] ?? '',
      rutaArchivo: mapa['ruta_archivo'],
      enlace: mapa['enlace'],
      fechaCreacion: fechaCreacion,
      perfilId: mapa['perfil_id'],
    );
  }

  Map<String, dynamic> aMapa() {
    // Guardamos la fecha como STRING ISO 8601 para facilitar la serialización
    final String fechaCreacionStr = fechaCreacion.toIso8601String();
    return {
      'id': id,
      'nombre': nombre,
      'area': area,
      'campo_formativo': campoFormativo,
      'tipo_archivo': tipoArchivo,
      'ruta_archivo': rutaArchivo,
      'enlace': enlace,
      'fecha_creacion': fechaCreacionStr,
      'perfil_id': perfilId,
    };
  }
}
