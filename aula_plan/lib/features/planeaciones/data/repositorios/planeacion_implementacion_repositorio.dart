import 'package:aula_plan/features/planeaciones/data/modelos/planeacion_modelos.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import '../../../../core/db_helper.dart';
import '../../domain/repositorios/planeacion_repositorio.dart';
import '../fuentes_datos/planeacion_local_data_source.dart';

class PlaneacionImplementacionRepositorio implements PlaneacionRepositorio {
  final PlaneacionLocalDataSource fuenteDatosLocal;

  PlaneacionImplementacionRepositorio({required this.fuenteDatosLocal});

  @override
  Future<void> guardarPlaneacionCompleta(PlaneacionEntidad planeacion) async {
    // Obtenemos el perfil activo desde el Helper
    final idPerfilActivo = await DbHelper().obtenerPerfilId();

    // Convertimos la Entidad y sus Fases a Modelos
    final modelo = _mapearEntidadAModelo(planeacion, idPerfilActivo);

    await fuenteDatosLocal.insertarCompleta(modelo);
  }

  @override
  Future<List<PlaneacionEntidad>> obtenerTodasLasPlaneaciones() async {
    return await fuenteDatosLocal.obtenerTodas();
  }

  @override
  Future<PlaneacionEntidad?> obtenerPlaneacionPorId(int idPlaneacion) async {
    return await fuenteDatosLocal.obtenerPorId(idPlaneacion);
  }

  @override
  Future<void> eliminarPlaneacion(int idPlaneacion) async {
    await fuenteDatosLocal.eliminar(idPlaneacion);
  }

  @override
  Future<void> editarPlaneacion(PlaneacionEntidad planeacion) async {
    final idPerfil = planeacion.perfilId ?? await DbHelper().obtenerPerfilId();
    
    final modelo = _mapearEntidadAModelo(planeacion, idPerfil);
    
    await fuenteDatosLocal.actualizarCompleta(modelo);
  }


  PlaneacionModelo _mapearEntidadAModelo(PlaneacionEntidad entidad, int? perfilId) {
    // Mapeamos la lista de fases de Entidad a Modelo
    final listaFasesModelos = entidad.fases.map((faseEntidad) {
      return FasePlaneacionModelo(
        id: faseEntidad.id,
        idPlaneacion: faseEntidad.idPlaneacion,
        fasesDesarrollo: faseEntidad.fasesDesarrollo,
        actividades: faseEntidad.actividades,
        materialesRecursos: faseEntidad.materialesRecursos,
        organizacionGrupo: faseEntidad.organizacionGrupo,
        espacio: faseEntidad.espacio,
        tiempo: faseEntidad.tiempo,
        responsables: faseEntidad.responsables,
        evaluacionIndicadores: faseEntidad.evaluacionIndicadores,
        evaluacionInstrumentos: faseEntidad.evaluacionInstrumentos,
      );
    }).toList();

    return PlaneacionModelo(
      id: entidad.id,
      perfilId: perfilId,
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
      fases: listaFasesModelos, 
    );
  }

  @override
  Future<void> editarFase(FasePlaneacionEntidad fase) async {
    // Convertir la entidad de la fase a su modelo de datos
    final modeloFase = FasePlaneacionModelo(
      id: fase.id,
      idPlaneacion: fase.idPlaneacion,
      fasesDesarrollo: fase.fasesDesarrollo,
      actividades: fase.actividades,
      materialesRecursos: fase.materialesRecursos,
      organizacionGrupo: fase.organizacionGrupo,
      espacio: fase.espacio,
      tiempo: fase.tiempo,
      responsables: fase.responsables,
      evaluacionIndicadores: fase.evaluacionIndicadores,
      evaluacionInstrumentos: fase.evaluacionInstrumentos,
    );

    await fuenteDatosLocal.actualizarFaseIndividual(modeloFase);
  }

  @override
  Future<void> agregarFaseAPlaneacion(int idPlaneacion, FasePlaneacionEntidad fase) async {
    final modeloFase = FasePlaneacionModelo(
      id: fase.id,
      idPlaneacion: idPlaneacion, // insertar el ID de la planeación padre
      fasesDesarrollo: fase.fasesDesarrollo,
      actividades: fase.actividades,
      materialesRecursos: fase.materialesRecursos,
      organizacionGrupo: fase.organizacionGrupo,
      espacio: fase.espacio,
      tiempo: fase.tiempo,
      responsables: fase.responsables,
      evaluacionIndicadores: fase.evaluacionIndicadores,
      evaluacionInstrumentos: fase.evaluacionInstrumentos,
    );

    await fuenteDatosLocal.insertarFaseIndividual(modeloFase);
  }
}