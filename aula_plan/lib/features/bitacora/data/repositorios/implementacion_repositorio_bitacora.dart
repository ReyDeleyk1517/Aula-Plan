import '../../domain/entidades/entidad_bitacora.dart';
import '../../domain/repositorios/repositorio_bitacora.dart';
import '../fuentes_datos/bitacora_local_data_source.dart';
import '../modelos/modelo_bitacora.dart';

class ImplementacionRepositorioBitacora implements RepositorioBitacora {
  final BitacoraLocalDataSource fuenteDatosLocal;

  ImplementacionRepositorioBitacora({required this.fuenteDatosLocal});

  @override
  Future<void> guardarRegistro(EntidadBitacora registro) async {
    // Convertir Entidad (Domain) a Modelo (Data) antes de mandar a la fuente
    final modelo = ModeloBitacora(
      id: registro.id,
      fecha: registro.fecha,
      hora: registro.hora,
      categoria: registro.categoria,
      titulo: registro.titulo,
      actividad: registro.actividad,
      observaciones: registro.observaciones,
    );
    await fuenteDatosLocal.insertarRegistro(modelo);
  }

  @override
  Future<List<EntidadBitacora>> obtenerRegistros() async {
    // La fuente da Modelos, pero el Repositorio devuelve Entidades al Dominio
    return await fuenteDatosLocal.obtenerRegistros();
  }

  @override
  Future<void> eliminarRegistro(int id) async {
    await fuenteDatosLocal.borrarRegistro(id);
  }

  @override
  Future<void> editarRegistro(EntidadBitacora registro) async {
    // Convertir la Entidad a Modelo
    final modelo = _mapearEntidadAModelo(registro);
    
    // Llamar al método en el DataSource
    await fuenteDatosLocal.actualizarRegistro(modelo);
  }

  
  ModeloBitacora _mapearEntidadAModelo(EntidadBitacora registro) {
    return ModeloBitacora(
      id: registro.id,
      fecha: registro.fecha,
      hora: registro.hora,
      categoria: registro.categoria,
      titulo: registro.titulo,
      actividad: registro.actividad,
      observaciones: registro.observaciones,
    );
  }
}