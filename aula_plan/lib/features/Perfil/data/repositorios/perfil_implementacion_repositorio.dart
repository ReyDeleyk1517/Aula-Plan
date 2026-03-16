import 'package:aula_plan/features/Perfil/data/fuentes_datos/perfil_local_data_source.dart';
import 'package:aula_plan/features/Perfil/data/modelos/perfil_modelo.dart';
import 'package:aula_plan/features/Perfil/domain/entidades/perfil_entidad.dart';
import 'package:aula_plan/features/Perfil/domain/repositorios/perfil_repositorio.dart';

class PerfilImplementacionRepositorio implements PerfilRepositorio {
  final PerfilLocalDataSource fuenteDatosLocal;

  PerfilImplementacionRepositorio({required this.fuenteDatosLocal});

  @override
  Future<void> guardarRegistro(PerfilEntidad registro) async {
    // Convertir Entidad (Domain) a Modelo (Data) antes de mandar a la fuente
    final modelo = PerfilModelo(
      id: registro.id,
      nombre: registro.nombre,
      apellidos: registro.apellidos,
      region: registro.region,
      zona_escolar: registro.zona_escolar,
      funcion: registro.funcion,
      centro_trabajo: registro.centro_trabajo,
    );
    await fuenteDatosLocal.insertarRegistro(modelo);
  }

  @override
  Future<List<PerfilEntidad>> obtenerRegistros() async {
    // La fuente da Modelos, pero el Repositorio devuelve Entidades al Dominio
    return await fuenteDatosLocal.obtenerRegistros();
  }

  @override
  Future<void> eliminarRegistro(int id) async {
    await fuenteDatosLocal.borrarRegistro(id);
  }

  @override
  Future<void> editarRegistro(PerfilEntidad registro) async {
    // Convertir la Entidad a Modelo
    final modelo = _mapearEntidadAModelo(registro);
    
    // Llamar al método en el DataSource
    await fuenteDatosLocal.actualizarRegistro(modelo);
  }

  
  PerfilModelo _mapearEntidadAModelo(PerfilEntidad registro) {
    return PerfilModelo(
      id: registro.id,
      nombre: registro.nombre,
      apellidos: registro.apellidos,
      region: registro.region,
      zona_escolar: registro.zona_escolar,
      funcion: registro.funcion,
      centro_trabajo: registro.centro_trabajo,
    );
  }
}