import '../../domain/entidades/evento_entidad.dart';

class EventoModelo extends EventoEntidad {
  EventoModelo({
    int? id,
    required String titulo,
    required String descripcion,
    required String fecha_inicio,
    required String fecha_fin,
    required String tipo_evento,
    required String lugar,
    int? perfilId,
  }) : super(
            id: id,
            titulo: titulo,
            descripcion: descripcion,
            fecha_inicio: fecha_inicio,
            fecha_fin: fecha_fin,
            tipo_evento: tipo_evento,
            lugar: lugar,
            perfilId: perfilId,
          );

  factory EventoModelo.desdeMapa(Map<String, dynamic> mapa) {
    return EventoModelo(
      id: mapa['id'],
      titulo: mapa['titulo'],
      descripcion: mapa['descripcion'],
      fecha_inicio: mapa['fecha_inicio'],
      fecha_fin: mapa['fecha_fin'],
      tipo_evento: mapa['tipo_evento'],
      lugar: mapa['lugar'],
      perfilId: mapa['perfil_id'],
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_inicio': fecha_inicio,
      'fecha_fin': fecha_fin,
      'tipo_evento': tipo_evento,
      'lugar': lugar,
      'perfil_id': perfilId,
    };
  }
}