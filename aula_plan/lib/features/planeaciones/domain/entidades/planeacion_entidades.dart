
class PlaneacionEntidad {
  final int? id;
  final int? perfilId;
  final String cicloEscolar;
  final String fechaEntrega;
  final String nombreEscuela;
  final String nivelEducativo;
  final String faseEducativa;
  final String grupo;
  final String condicionAlumnado;
  final String temporalidad;
  final String necesidadesBap;
  final String disciplina;
  final String camposFormativos;
  final String contenidos;
  final String pda;
  final String ejesArticuladores;
  final String escenarios;
  final String metodologia;
  final String nombreProyecto;
  final String observaciones;
  
  // Una planeación tiene múltiples fases
  final List<FasePlaneacionEntidad> fases;

  PlaneacionEntidad({
    this.id,
    this.perfilId,
    required this.cicloEscolar,
    required this.fechaEntrega,
    required this.nombreEscuela,
    required this.nivelEducativo,
    required this.faseEducativa,
    required this.grupo,
    required this.condicionAlumnado,
    required this.temporalidad,
    required this.necesidadesBap,
    required this.disciplina,
    required this.camposFormativos,
    required this.contenidos,
    required this.pda,
    required this.ejesArticuladores,
    required this.escenarios,
    required this.metodologia,
    required this.nombreProyecto,
    required this.observaciones,
    this.fases = const [],
  });
}

class FasePlaneacionEntidad {
  final int? id;
  final int? idPlaneacion;
  final String fasesDesarrollo;
  final String actividades;
  final String materialesRecursos;
  final String organizacionGrupo;
  final String espacio;
  final String tiempo;
  final String responsables;
  final String evaluacionIndicadores;
  final String evaluacionInstrumentos;

  FasePlaneacionEntidad({
    this.id,
    this.idPlaneacion,
    required this.fasesDesarrollo,
    required this.actividades,
    required this.materialesRecursos,
    required this.organizacionGrupo,
    required this.espacio,
    required this.tiempo,
    required this.responsables,
    required this.evaluacionIndicadores,
    required this.evaluacionInstrumentos,
  });
}