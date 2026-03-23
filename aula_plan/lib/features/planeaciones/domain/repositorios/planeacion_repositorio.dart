import '../entidades/planeacion_entidades.dart';

abstract class PlaneacionRepositorio {
  
  Future<List<PlaneacionEntidad>> obtenerTodasLasPlaneaciones();

  Future<PlaneacionEntidad?> obtenerPlaneacionPorId(int idPlaneacion);

  Future<void> guardarPlaneacionCompleta(PlaneacionEntidad planeacion);
 
  Future<void> eliminarPlaneacion(int idPlaneacion);
 
  Future<void> editarPlaneacion(PlaneacionEntidad planeacion);

  Future<void> editarFase(FasePlaneacionEntidad fase);
  
  Future<void> agregarFaseAPlaneacion(int idPlaneacion, FasePlaneacionEntidad fase);
}