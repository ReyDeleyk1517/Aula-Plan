import '../entidades/perfil_entidad.dart';

abstract class PerfilRepositorio {
  Future<List<PerfilEntidad>> obtenerRegistros();
  Future<void> guardarRegistro(PerfilEntidad registro);
  Future<void> eliminarRegistro(int id);
  Future<void> editarRegistro(PerfilEntidad registro);
}