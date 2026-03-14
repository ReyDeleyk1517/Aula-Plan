import '../entidades/entidad_bitacora.dart';
import '../repositorios/repositorio_bitacora.dart';


class ObtenerRegistrosBitacora {
  final RepositorioBitacora repositorio; 

  ObtenerRegistrosBitacora(this.repositorio); 

  Future<List<EntidadBitacora>> call() async {
    return await repositorio.obtenerRegistros(); 
  }
}

class EliminarRegistroBitacora {
  final RepositorioBitacora repositorio; 

  EliminarRegistroBitacora(this.repositorio);

  Future<void> call(int id) async {
    return await repositorio.eliminarRegistro(id); 
  }
}


class EditarRegistroBitacora {
  final RepositorioBitacora repositorio; 

  EditarRegistroBitacora(this.repositorio);

  Future<void> call(EntidadBitacora bitacora) async {
    return await repositorio.editarRegistro(bitacora); 
  }
}

class GuardarRegistroBitacora {
  final RepositorioBitacora repositorio; 

  GuardarRegistroBitacora(this.repositorio);

  Future<void> call(EntidadBitacora bitacora) async {
    // Guardar un nuevo registro, no editar
    return await repositorio.guardarRegistro(bitacora); 
  }
}
