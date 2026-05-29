class PlaneacionEntidad {
  final int? id;
  final int? perfilId;
  // Optional: path to a template image asset to format the PDF
  final String? templateImageAsset;
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
  final String contenidos_lenguaje;
  final String contenidos_saberes_y_pensamiento_cientifico;
  final String contenidos_de_lo_humano_y_comunitario;
  final String contenidos_etica_naturaleza_y_sociedad;
  final String pda;
  final String ejesArticuladores;
  final String escenarios;
  final String metodologia;
  final String nombreProyecto;
  final String organizacionGrupo;
  final String espacio;
  final String tiempo;
  final String responsables;
  final String evaluacionIndicadores;
  final String evaluacionInstrumentos;
  final String observaciones;
  // Nueva: problemática de la planeación
  final String problematica;
  // Nueva: fecha de creación de la planeación
  final String? fechaCreacion;
  // Nueva: fase_momento_etapa
  final String? faseMomentoEtapa;

  // Una planeación tiene múltiples actividades
  final List<ActividadPlaneacionEntidad> actividades;

  PlaneacionEntidad({
    this.id,
    this.perfilId,
    this.templateImageAsset,
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
    required this.contenidos_lenguaje,
    required this.contenidos_saberes_y_pensamiento_cientifico,
    required this.contenidos_de_lo_humano_y_comunitario,
    required this.contenidos_etica_naturaleza_y_sociedad,
    required this.pda,
    required this.ejesArticuladores,
    required this.escenarios,
    required this.metodologia,
    required this.nombreProyecto,
    required this.organizacionGrupo,
    required this.espacio,
    required this.tiempo,
    required this.responsables,
    required this.evaluacionIndicadores,
    required this.evaluacionInstrumentos,
    required this.observaciones,
    required this.problematica,
    this.fechaCreacion,
    this.faseMomentoEtapa,
    this.actividades = const [],
  });
}

// NUEVA: Actividad de una planeación (tabla independiente)
class ActividadPlaneacionEntidad {
  final int? id;
  final int? idPlaneacion;
  final String titulo;
  final String descripcion;
  final String materiales;

  ActividadPlaneacionEntidad({
    this.id,
    this.idPlaneacion,
    required this.titulo,
    required this.descripcion,
    required this.materiales,
  });
}
