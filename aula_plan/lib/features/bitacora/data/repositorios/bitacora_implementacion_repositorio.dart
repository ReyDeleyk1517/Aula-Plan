import 'package:aula_plan/core/db_helper.dart';

import '../../domain/entidades/bitacora_entidad.dart';
import '../../domain/repositorios/bitacora_repositorio.dart';
import '../fuentes_datos/bitacora_local_data_source.dart';
import '../modelos/bitacora_modelo.dart';

class BitacoraImplementacionRepositorio implements BitacoraRepositorio {
  final BitacoraLocalDataSource fuenteDatosLocal;
  BitacoraImplementacionRepositorio({required this.fuenteDatosLocal});

  @override
  Future<void> guardarRegistro(BitacoraEntidad registro) async {
    final idActivo = await DbHelper().obtenerPerfilId();
    // Convertir Entidad (Domain) a Modelo (Data) antes de mandar a la fuente
    final modelo = BitacoraModelo(
      id: registro.id,
      fecha: registro.fecha,
      hora: registro.hora,
      categoria: registro.categoria,
      titulo: registro.titulo,
      actividad: registro.actividad,
      observaciones: registro.observaciones,
      perfilId: idActivo!,
    );
    await fuenteDatosLocal.insertarRegistro(modelo);
  }

  @override
  Future<List<BitacoraEntidad>> obtenerRegistros() async {
    // La fuente da Modelos, pero el Repositorio devuelve Entidades al Dominio
    return await fuenteDatosLocal.obtenerRegistros();
  }

  @override
  Future<void> eliminarRegistro(int id) async {
    await fuenteDatosLocal.borrarRegistro(id);
  }

  @override
  Future<void> editarRegistro(BitacoraEntidad registro) async {
    // Convertir la Entidad a Modelo
    final modelo = _mapearEntidadAModelo(registro);
    
    // Llamar al método en el DataSource
    await fuenteDatosLocal.actualizarRegistro(modelo);
  }

  
  BitacoraModelo _mapearEntidadAModelo(BitacoraEntidad registro) {
    return BitacoraModelo(
      id: registro.id,
      fecha: registro.fecha,
      hora: registro.hora,
      categoria: registro.categoria,
      titulo: registro.titulo,
      actividad: registro.actividad,
      observaciones: registro.observaciones,
      perfilId: registro.perfilId,
    );
  }
}
