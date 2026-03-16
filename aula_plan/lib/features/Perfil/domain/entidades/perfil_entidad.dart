class PerfilEntidad {
  final int? id;
  final String nombre;
  final String apellidos;
  final String region;
  final String zona_escolar;
  final String funcion;
  final String centro_trabajo;



  PerfilEntidad({
    this.id,
    required this.nombre, 
    required this.apellidos, 
    required this.region, 
    required this.zona_escolar, 
    required this.funcion,
    required this.centro_trabajo,

  });
}