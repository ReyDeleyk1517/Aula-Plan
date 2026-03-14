import '../entidades/entidad_bitacora.dart';

abstract class RepositorioBitacora {
  Future<List<EntidadBitacora>> obtenerRegistros();
  Future<void> guardarRegistro(EntidadBitacora registro);
  Future<void> eliminarRegistro(int id);
  Future<void> editarRegistro(EntidadBitacora registro);
}