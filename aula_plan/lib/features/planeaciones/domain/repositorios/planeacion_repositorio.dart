import '../entidades/planeacion_entidades.dart';

abstract class PlaneacionRepositorio {
  
  Future<List<PlaneacionEntidad>> obtenerTodasLasPlaneaciones();

  Future<PlaneacionEntidad?> obtenerPlaneacionPorId(int idPlaneacion);

  Future<void> guardarPlaneacionCompleta(PlaneacionEntidad planeacion);
 
  Future<void> eliminarPlaneacion(int idPlaneacion);

  Future<void> editarPlaneacion(PlaneacionEntidad planeacion);
  
  // Actividades por planeacion (nueva tabla, DB separada)
  Future<List<ActividadPlaneacionEntidad>> obtenerActividadesPorPlaneacion(int idPlaneacion);
  Future<void> insertarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionEntidad> actividades);
  Future<void> actualizarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionEntidad> actividades);
}
