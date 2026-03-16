import '../../domain/entidades/perfil_entidad.dart';

class PerfilModelo extends PerfilEntidad {
  PerfilModelo({
    int? id,
    required String nombre,
    required String apellidos,
    required String region,
    required String zona_escolar,
    required String funcion,
    required String centro_trabajo,
  }) : super(
          id: id,
          nombre: nombre,
          apellidos: apellidos,
          region: region,
          zona_escolar: zona_escolar,
          funcion: funcion,
          centro_trabajo: centro_trabajo      
        );

  factory PerfilModelo.desdeMapa(Map<String, dynamic> mapa) {
    return PerfilModelo(
      id: mapa['id'],
      nombre: mapa['nombre'],
      apellidos: mapa['apellidos'],
      region: mapa['region'],
      zona_escolar: mapa['zona_escolar'],
      funcion: mapa['funcion'],
      centro_trabajo: mapa['centro_trabajo']

    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'region': region,
      'zona_escolar': zona_escolar,
      'funcion': funcion,
      'centro_trabajo': centro_trabajo,
    };
  }
}