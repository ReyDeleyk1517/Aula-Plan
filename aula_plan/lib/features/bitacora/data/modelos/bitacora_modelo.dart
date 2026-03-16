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
  }) : super(
          id: id,
          fecha: fecha,
          hora: hora,
          categoria: categoria,
          titulo: titulo,
          actividad: actividad,
          observaciones: observaciones,
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