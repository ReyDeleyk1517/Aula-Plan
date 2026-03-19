import '../entidades/recurso_docentes_entidad.dart';
import '../repositorios/recurso_docentes_repositorio.dart';


class ObtenerRegistrosRecursos {
  final RecursoDocentesRepositorio repositorio; 

  ObtenerRegistrosRecursos(this.repositorio); 

  Future<List<RecursoDocenteEntidad>> call() async {
    return await repositorio.obtenerRegistros(); 
  }
}

class EliminarRegistroRecursos {
  final RecursoDocentesRepositorio repositorio; 

  EliminarRegistroRecursos(this.repositorio);

  Future<void> call(int id) async {
    return await repositorio.eliminarRegistro(id); 
  }
}


class EditarRegistroRecursos {
  final RecursoDocentesRepositorio repositorio; 

  EditarRegistroRecursos(this.repositorio);

  Future<void> call(RecursoDocenteEntidad bitacora) async {
    return await repositorio.editarRegistro(bitacora); 
  }
}

class GuardarRegistroRecursos {
  final RecursoDocentesRepositorio repositorio; 

  GuardarRegistroRecursos(this.repositorio);

  Future<void> call(RecursoDocenteEntidad bitacora) async {
    return await repositorio.guardarRegistro(bitacora); 
  }
}
