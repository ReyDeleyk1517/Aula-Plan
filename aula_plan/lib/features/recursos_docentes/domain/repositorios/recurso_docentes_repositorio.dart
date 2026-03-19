import '../entidades/recurso_docentes_entidad.dart';

abstract class RecursoDocentesRepositorio{
  Future<List<RecursoDocenteEntidad>> obtenerRegistros();
  Future<void> guardarRegistro(RecursoDocenteEntidad registro);
  Future<void> eliminarRegistro(int id);
  Future<void> editarRegistro(RecursoDocenteEntidad registro);
}