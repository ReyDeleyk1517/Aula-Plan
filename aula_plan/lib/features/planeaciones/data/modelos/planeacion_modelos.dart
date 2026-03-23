import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';

class PlaneacionModelo extends PlaneacionEntidad {
  PlaneacionModelo({
    int? id,
    int? perfilId,
    required String cicloEscolar,
    required String fechaEntrega,
    required String nombreEscuela,
    required String nivelEducativo,
    required String faseEducativa,
    required String grupo,
    required String condicionAlumnado,
    required String temporalidad,
    required String necesidadesBap,
    required String disciplina,
    required String camposFormativos,
    required String contenidos,
    required String pda,
    required String ejesArticuladores,
    required String escenarios,
    required String metodologia,
    required String nombreProyecto,
    required String observaciones,
    List<FasePlaneacionModelo> fases = const [],
  }) : super(
          id: id,
          perfilId: perfilId,
          cicloEscolar: cicloEscolar,
          fechaEntrega: fechaEntrega,
          nombreEscuela: nombreEscuela,
          nivelEducativo: nivelEducativo,
          faseEducativa: faseEducativa,
          grupo: grupo,
          condicionAlumnado: condicionAlumnado,
          temporalidad: temporalidad,
          necesidadesBap: necesidadesBap,
          disciplina: disciplina,
          camposFormativos: camposFormativos,
          contenidos: contenidos,
          pda: pda,
          ejesArticuladores: ejesArticuladores,
          escenarios: escenarios,
          metodologia: metodologia,
          nombreProyecto: nombreProyecto,
          observaciones: observaciones,
          fases: fases,
        );

  factory PlaneacionModelo.desdeMapa(Map<String, dynamic> mapa, {List<FasePlaneacionModelo> fases = const []}) {
    return PlaneacionModelo(
      id: mapa['id'],
      perfilId: mapa['perfil_id'],
      cicloEscolar: mapa['ciclo_escolar'],
      fechaEntrega: mapa['fecha_entrega'],
      nombreEscuela: mapa['nombre_escuela'],
      nivelEducativo: mapa['nivel_educativo'],
      faseEducativa: mapa['fase_educativa'],
      grupo: mapa['grupo'],
      condicionAlumnado: mapa['condicion_alumnado'],
      temporalidad: mapa['temporalidad'],
      necesidadesBap: mapa['necesidades_bap'],
      disciplina: mapa['disciplina'],
      camposFormativos: mapa['campos_formativos'],
      contenidos: mapa['contenidos'],
      pda: mapa['pda'],
      ejesArticuladores: mapa['ejes_articuladores'],
      escenarios: mapa['escenarios'],
      metodologia: mapa['metodologia'],
      nombreProyecto: mapa['nombre_proyecto'],
      observaciones: mapa['observaciones'],
      fases: fases,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'perfil_id': perfilId,
      'ciclo_escolar': cicloEscolar,
      'fecha_entrega': fechaEntrega,
      'nombre_escuela': nombreEscuela,
      'nivel_educativo': nivelEducativo,
      'fase_educativa': faseEducativa,
      'grupo': grupo,
      'condicion_alumnado': condicionAlumnado,
      'temporalidad': temporalidad,
      'necesidades_bap': necesidadesBap,
      'disciplina': disciplina,
      'campos_formativos': camposFormativos,
      'contenidos': contenidos,
      'pda': pda,
      'ejes_articuladores': ejesArticuladores,
      'escenarios': escenarios,
      'metodologia': metodologia,
      'nombre_proyecto': nombreProyecto,
      'observaciones': observaciones,
    };
  }

  factory PlaneacionModelo.fromEntity(PlaneacionEntidad entidad) {
    return PlaneacionModelo(
      id: entidad.id,
      perfilId: entidad.perfilId,
      cicloEscolar: entidad.cicloEscolar,
      fechaEntrega: entidad.fechaEntrega,
      nombreEscuela: entidad.nombreEscuela,
      nivelEducativo: entidad.nivelEducativo,
      faseEducativa: entidad.faseEducativa,
      grupo: entidad.grupo,
      condicionAlumnado: entidad.condicionAlumnado,
      temporalidad: entidad.temporalidad,
      necesidadesBap: entidad.necesidadesBap,
      disciplina: entidad.disciplina,
      camposFormativos: entidad.camposFormativos,
      contenidos: entidad.contenidos,
      pda: entidad.pda,
      ejesArticuladores: entidad.ejesArticuladores,
      escenarios: entidad.escenarios,
      metodologia: entidad.metodologia,
      nombreProyecto: entidad.nombreProyecto,
      observaciones: entidad.observaciones,
      // Mapear fases
      fases: entidad.fases.map((f) => FasePlaneacionModelo.fromEntity(f)).toList(),
    );
  }
}

//==================================
// FASES DE PLANEACIONES
//==================================

class FasePlaneacionModelo extends FasePlaneacionEntidad {
  FasePlaneacionModelo({
    int? id,
    int? idPlaneacion,
    required String fasesDesarrollo,
    required String actividades,
    required String materialesRecursos,
    required String organizacionGrupo,
    required String espacio,
    required String tiempo,
    required String responsables,
    required String evaluacionIndicadores,
    required String evaluacionInstrumentos,
  }) : super(
          id: id,
          idPlaneacion: idPlaneacion,
          fasesDesarrollo: fasesDesarrollo,
          actividades: actividades,
          materialesRecursos: materialesRecursos,
          organizacionGrupo: organizacionGrupo,
          espacio: espacio,
          tiempo: tiempo,
          responsables: responsables,
          evaluacionIndicadores: evaluacionIndicadores,
          evaluacionInstrumentos: evaluacionInstrumentos,
        );

  factory FasePlaneacionModelo.desdeMapa(Map<String, dynamic> mapa) {
    return FasePlaneacionModelo(
      id: mapa['id'],
      idPlaneacion: mapa['id_planeacion'],
      fasesDesarrollo: mapa['fases_desarrollo'],
      actividades: mapa['actividades'],
      materialesRecursos: mapa['materiales_recursos'],
      organizacionGrupo: mapa['organizacion_grupo'],
      espacio: mapa['espacio'],
      tiempo: mapa['tiempo'],
      responsables: mapa['responsables'],
      evaluacionIndicadores: mapa['evaluacion_indicadores'],
      evaluacionInstrumentos: mapa['evaluacion_instrumentos'],
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'id_planeacion': idPlaneacion,
      'fases_desarrollo': fasesDesarrollo,
      'actividades': actividades,
      'materiales_recursos': materialesRecursos,
      'organizacion_grupo': organizacionGrupo,
      'espacio': espacio,
      'tiempo': tiempo,
      'responsables': responsables,
      'evaluacion_indicadores': evaluacionIndicadores,
      'evaluacion_instrumentos': evaluacionInstrumentos,
    };
  }

  factory FasePlaneacionModelo.fromEntity(FasePlaneacionEntidad entidad) {
    return FasePlaneacionModelo(
      id: entidad.id,
      idPlaneacion: entidad.idPlaneacion,
      fasesDesarrollo: entidad.fasesDesarrollo,
      actividades: entidad.actividades,
      materialesRecursos: entidad.materialesRecursos,
      organizacionGrupo: entidad.organizacionGrupo,
      espacio: entidad.espacio,
      tiempo: entidad.tiempo,
      responsables: entidad.responsables,
      evaluacionIndicadores: entidad.evaluacionIndicadores,
      evaluacionInstrumentos: entidad.evaluacionInstrumentos,
    );
  }
  
}
