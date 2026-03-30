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
    required String organizacionGrupo,
    required String espacio,
    required String tiempo,
    required String responsables,
    required String evaluacionIndicadores,
    required String evaluacionInstrumentos,
    List<ActividadPlaneacionModelo> actividades = const [],
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
            organizacionGrupo: organizacionGrupo,
            espacio: espacio,
            tiempo: tiempo,
            responsables: responsables,
            evaluacionIndicadores: evaluacionIndicadores,
            evaluacionInstrumentos: evaluacionInstrumentos,
            actividades: actividades,
          );

  factory PlaneacionModelo.desdeMapa(Map<String, dynamic> mapa, {List<ActividadPlaneacionModelo> actividades = const []}) {
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
      organizacionGrupo: mapa['organizacion_grupo'],
      espacio: mapa['espacio'],
      tiempo: mapa['tiempo'],
      responsables: mapa['responsables'],
      evaluacionIndicadores: mapa['evaluacion_indicadores'],
      evaluacionInstrumentos: mapa['evaluacion_instrumentos'],
      actividades: actividades,
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
      'organizacion_grupo': organizacionGrupo,
      'espacio': espacio,
      'tiempo': tiempo,
      'responsables': responsables,
      'evaluacion_indicadores': evaluacionIndicadores,
      'evaluacion_instrumentos': evaluacionInstrumentos,
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
      organizacionGrupo: entidad.organizacionGrupo,
      espacio: entidad.espacio,
      tiempo: entidad.tiempo,
      responsables: entidad.responsables,
      evaluacionIndicadores: entidad.evaluacionIndicadores,
      evaluacionInstrumentos: entidad.evaluacionInstrumentos,
      // Mapear actividades
      actividades: entidad.actividades.map((a) => ActividadPlaneacionModelo.fromEntity(a)).toList(),
    );
  }
}

//==================================
// ACTIVIDADES DE PLANEACIÓN (Modelo)
//==================================

class ActividadPlaneacionModelo extends ActividadPlaneacionEntidad {
  ActividadPlaneacionModelo({
    int? id,
    int? idPlaneacion,
    required String titulo,
    required String descripcion,
    required String materiales,
  }) : super(
          id: id,
          idPlaneacion: idPlaneacion,
          titulo: titulo,
          descripcion: descripcion,
          materiales: materiales,
        );

  factory ActividadPlaneacionModelo.desdeMapa(Map<String, dynamic> mapa) {
    return ActividadPlaneacionModelo(
      id: mapa['id'],
      idPlaneacion: mapa['id_planeacion'],
      titulo: mapa['titulo'],
      descripcion: mapa['descripcion'],
      materiales: mapa['materiales'],
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'id_planeacion': idPlaneacion,
      'titulo': titulo,
      'descripcion': descripcion,
      'materiales': materiales,
    };
  }

  factory ActividadPlaneacionModelo.fromEntity(ActividadPlaneacionEntidad entidad) {
    return ActividadPlaneacionModelo(
      id: entidad.id,
      idPlaneacion: entidad.idPlaneacion,
      titulo: entidad.titulo,
      descripcion: entidad.descripcion,
      materiales: entidad.materiales,
    );
  }
}
