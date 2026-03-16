import 'package:aula_plan/features/Perfil/domain/entidades/perfil_entidad.dart';
import 'package:aula_plan/features/Perfil/domain/repositorios/perfil_repositorio.dart';

class ObtenerRegistrosPerfil {
  final PerfilRepositorio repositorio; 

  ObtenerRegistrosPerfil(this.repositorio); 

  Future<List<PerfilEntidad>> call() async {
    return await repositorio.obtenerRegistros(); 
  }
}

class EliminarRegistroPerfil {
  final PerfilRepositorio repositorio; 

  EliminarRegistroPerfil(this.repositorio);

  Future<void> call(int id) async {
    return await repositorio.eliminarRegistro(id); 
  }
}


class EditarRegistroPerfil {
  final PerfilRepositorio repositorio; 

  EditarRegistroPerfil(this.repositorio);

  Future<void> call(PerfilEntidad perfil) async {
    return await repositorio.editarRegistro(perfil); 
  }
}

class GuardarRegistroPerfil {
  final PerfilRepositorio repositorio; 

  GuardarRegistroPerfil(this.repositorio);

  Future<void> call(PerfilEntidad perfil) async {
    return await repositorio.guardarRegistro(perfil); 
  }
}
