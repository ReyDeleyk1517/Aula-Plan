import '../../domain/entidades/bitacora_entidad.dart';

class BitacoraModelo extends BitacoraEntidad {
  BitacoraModelo({
    int? id,
    required String fecha,
    required String hora,
    required String categoria,
    required String titulo,
    required String actividad,
    required String observaciones,
    int? perfilId,
    String? grado_y_grupo,
  }) : super(
         id: id,
         fecha: fecha,
         hora: hora,
         categoria: categoria,
         titulo: titulo,
         actividad: actividad,
         observaciones: observaciones,
         perfilId: perfilId,
         grado_y_grupo: grado_y_grupo,
       );

  factory BitacoraModelo.desdeMapa(Map<String, dynamic> mapa) {
    return BitacoraModelo(
      id: mapa['id'],
      fecha: mapa['fecha'],
      hora: mapa['hora'],
      categoria: mapa['categoria'],
      titulo: mapa['titulo'],
      actividad: mapa['actividad'],
      observaciones: mapa['observaciones'],
      perfilId: mapa['perfil_id'],
      grado_y_grupo: mapa['grado_y_grupo'],
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'fecha': fecha,
      'hora': hora,
      'categoria': categoria,
      'titulo': titulo,
      'actividad': actividad,
      'observaciones': observaciones,
      'perfil_id': perfilId,
      'grado_y_grupo': grado_y_grupo,
    };
  }
}
