import '../entidades/bitacora_entidad.dart';

abstract class BitacoraRepositorio{
  Future<List<BitacoraEntidad>> obtenerRegistros();
  Future<void> guardarRegistro(BitacoraEntidad registro);
  Future<void> eliminarRegistro(int id);
  Future<void> editarRegistro(BitacoraEntidad registro);
}