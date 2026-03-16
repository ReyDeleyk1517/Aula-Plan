import '../entidades/bitacora_entidad.dart';
import '../repositorios/bitacora_repositorio.dart';


class ObtenerRegistrosBitacora {
  final BitacoraRepositorio repositorio; 

  ObtenerRegistrosBitacora(this.repositorio); 

  Future<List<BitacoraEntidad>> call() async {
    return await repositorio.obtenerRegistros(); 
  }
}

class EliminarRegistroBitacora {
  final BitacoraRepositorio repositorio; 

  EliminarRegistroBitacora(this.repositorio);

  Future<void> call(int id) async {
    return await repositorio.eliminarRegistro(id); 
  }
}


class EditarRegistroBitacora {
  final BitacoraRepositorio repositorio; 

  EditarRegistroBitacora(this.repositorio);

  Future<void> call(BitacoraEntidad bitacora) async {
    return await repositorio.editarRegistro(bitacora); 
  }
}

class GuardarRegistroBitacora {
  final BitacoraRepositorio repositorio; 

  GuardarRegistroBitacora(this.repositorio);

  Future<void> call(BitacoraEntidad bitacora) async {
    return await repositorio.guardarRegistro(bitacora); 
  }
}
