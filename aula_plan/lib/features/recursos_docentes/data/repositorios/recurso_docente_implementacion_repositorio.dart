import 'package:aula_plan/core/db_helper.dart';
import 'package:aula_plan/features/recursos_docentes/data/fuentes_datos/recurso_docente_local_data_source.dart';
import 'package:aula_plan/features/recursos_docentes/data/modelos/recurso_docente_modelo.dart';
import 'package:aula_plan/features/recursos_docentes/domain/entidades/recurso_docentes_entidad.dart';
import 'package:aula_plan/features/recursos_docentes/domain/repositorios/recurso_docentes_repositorio.dart';


class RecursoDocenteRepositorioImpl implements RecursoDocentesRepositorio {
  final RecursoDocenteLocalDataSource fuenteDatosLocal;

  RecursoDocenteRepositorioImpl({required this.fuenteDatosLocal});

  @override
  Future<void> guardarRegistro(RecursoDocenteEntidad recurso) async {
    // Obtenemos el ID del perfil activo desde el Helper de la BD
    final idActivo = await DbHelper().obtenerPerfilId();

    // Convertimos la Entidad (Domain) a Modelo (Data)
    final modelo = RecursoDocenteModelo(
      id: recurso.id,
      nombre: recurso.nombre,
      area: recurso.area,
      campoFormativo: recurso.campoFormativo,
      tipoArchivo: recurso.tipoArchivo,
      rutaArchivo: recurso.rutaArchivo,
      enlace: recurso.enlace,
      fechaCreacion: recurso.fechaCreacion,
      perfilId: idActivo!,
    );

    await fuenteDatosLocal.insertarRecurso(modelo);
  }

  @override
  Future<List<RecursoDocenteEntidad>> obtenerRegistros() async {
    
    return await fuenteDatosLocal.obtenerRecursos();
  }

  @override
  Future<void> eliminarRegistro(int id) async {
    await fuenteDatosLocal.borrarRecurso(id);
  }

  @override
  Future<void> editarRegistro(RecursoDocenteEntidad recurso) async {
    // Usamos el método privado para mapear la entidad
    final modelo = _mapearEntidadAModelo(recurso);
    
    await fuenteDatosLocal.actualizarRecurso(modelo);
  }

  /// Método auxiliar para transformar Entidad a Modelo
  RecursoDocenteModelo _mapearEntidadAModelo(RecursoDocenteEntidad recurso) {
    return RecursoDocenteModelo(
      id: recurso.id,
      nombre: recurso.nombre,
      area: recurso.area,
      campoFormativo: recurso.campoFormativo,
      tipoArchivo: recurso.tipoArchivo,
      rutaArchivo: recurso.rutaArchivo,
      enlace: recurso.enlace,
      fechaCreacion: recurso.fechaCreacion,
      perfilId: recurso.perfilId,
    );
  }
}