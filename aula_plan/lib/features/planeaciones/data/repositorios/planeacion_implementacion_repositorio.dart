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

  PlaneacionModelo _mapearEntidadAModelo(
    PlaneacionEntidad entidad,
    int? perfilId,
  ) {
    // Mapeamos la lista de actividades de Entidad a Modelo
    final listaActividadesModelos = entidad.actividades.map((actEntidad) {
      return ActividadPlaneacionModelo.fromEntity(actEntidad);
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
      contenidos_lenguaje: entidad.contenidos_lenguaje,
      contenidos_saberes_y_pensamiento_cientifico:
          entidad.contenidos_saberes_y_pensamiento_cientifico,
      contenidos_de_lo_humano_y_comunitario:
          entidad.contenidos_de_lo_humano_y_comunitario,
      contenidos_etica_naturaleza_y_sociedad:
          entidad.contenidos_etica_naturaleza_y_sociedad,
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
      // Mapeo de problemática
      problematica: entidad.problematica,
      // Mapear actividades en lugar de fases
      actividades: listaActividadesModelos,
    );
  }

  @override
  Future<List<ActividadPlaneacionEntidad>> obtenerActividadesPorPlaneacion(
    int idPlaneacion,
  ) async {
    // Consulta desde la fuente de datos local la lista de actividades para la planeación
    final actividades = await fuenteDatosLocal.obtenerActividadesPorPlaneacion(
      idPlaneacion,
    );
    // Ya son entidades
    return actividades;
  }

  @override
  Future<void> insertarActividadesParaPlaneacion(
    int idPlaneacion,
    List<ActividadPlaneacionEntidad> actividades,
  ) async {
    // Convertimos cada Entidad a Modelo explícitamente usando el factory que ya creaste
    final listaModelos = actividades
        .map((a) => ActividadPlaneacionModelo.fromEntity(a))
        .toList();

    await fuenteDatosLocal.insertarActividadesParaPlaneacion(
      idPlaneacion,
      listaModelos,
    );
  }

  @override
  Future<void> actualizarActividadesParaPlaneacion(
    int idPlaneacion,
    List<ActividadPlaneacionEntidad> actividades,
  ) async {
    // Nota: Cambié el parámetro a List<ActividadPlaneacionEntidad> para que coincida con la interfaz del repositorio
    final listaModelos = actividades
        .map((a) => ActividadPlaneacionModelo.fromEntity(a))
        .toList();

    await fuenteDatosLocal.actualizarActividadesParaPlaneacion(
      idPlaneacion,
      listaModelos,
    );
  }
}
