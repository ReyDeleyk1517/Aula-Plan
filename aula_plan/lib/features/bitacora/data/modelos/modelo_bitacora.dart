import '../../domain/entidades/entidad_bitacora.dart';

class ModeloBitacora extends EntidadBitacora {
  ModeloBitacora({
    int? id,
    required String fecha,
    required String hora,
    required String categoria,
    required String titulo,
    required String actividad,
    required String observaciones,
  }) : super(
          id: id,
          fecha: fecha,
          hora: hora,
          categoria: categoria,
          titulo: titulo,
          actividad: actividad,
          observaciones: observaciones,
        );

  factory ModeloBitacora.desdeMapa(Map<String, dynamic> mapa) {
    return ModeloBitacora(
      id: mapa['id'],
      fecha: mapa['fecha'],
      hora: mapa['hora'],
      categoria: mapa['categoria'],
      titulo: mapa['titulo'],
      actividad: mapa['actividad'],
      observaciones: mapa['observaciones'],
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
    };
  }
}