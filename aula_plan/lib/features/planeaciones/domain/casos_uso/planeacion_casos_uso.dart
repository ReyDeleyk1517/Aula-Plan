import '../entidades/planeacion_entidades.dart';
import '../repositorios/planeacion_repositorio.dart';

class ObtenerPlaneaciones {
  final PlaneacionRepositorio repositorio;

  ObtenerPlaneaciones(this.repositorio);

  Future<List<PlaneacionEntidad>> call() async {
    return await repositorio.obtenerTodasLasPlaneaciones();
  }
}

class GuardarPlaneacion {
  final PlaneacionRepositorio repositorio;

  GuardarPlaneacion(this.repositorio);

  Future<void> call(PlaneacionEntidad planeacion) async {
    return await repositorio.guardarPlaneacionCompleta(planeacion);
  }
}

class EditarPlaneacion {
  final PlaneacionRepositorio repositorio;

  EditarPlaneacion(this.repositorio);

  Future<void> call(PlaneacionEntidad planeacion) async {
    return await repositorio.editarPlaneacion(planeacion);
  }
}

class EliminarPlaneacion {
  final PlaneacionRepositorio repositorio;

  EliminarPlaneacion(this.repositorio);

  Future<void> call(int idPlaneacion) async {
    return await repositorio.eliminarPlaneacion(idPlaneacion);
  }
}

class ObtenerPlaneacionPorId {
  final PlaneacionRepositorio repositorio;

  ObtenerPlaneacionPorId(this.repositorio);

  Future<PlaneacionEntidad?> call(int idPlaneacion) async {
    return await repositorio.obtenerPlaneacionPorId(idPlaneacion);
  }
}