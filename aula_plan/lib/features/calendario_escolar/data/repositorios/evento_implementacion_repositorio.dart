import 'package:aula_plan/core/db_helper.dart';
import 'package:aula_plan/features/calendario_escolar/data/fuentes_datos/evento_local_data_source.dart';
import 'package:aula_plan/features/calendario_escolar/data/modelos/evento_modelo.dart';
import 'package:aula_plan/features/calendario_escolar/domain/entidades/evento_entidad.dart';
import 'package:aula_plan/features/calendario_escolar/domain/repositorios/evento_repositorio.dart';


class EventoImplementacionRepositorio implements EventoRepositorio {
  final EventoLocalDataSource fuenteDatosLocal;
  EventoImplementacionRepositorio({required this.fuenteDatosLocal});

  @override
  Future<void> guardarEvento(EventoEntidad evento) async {
    final idActivo = await DbHelper().obtenerPerfilId();
    // Convertir Entidad (Domain) a Modelo (Data) antes de mandar a la fuente
    
    final modelo = _mapearEntidadAModelo(evento, idActivo);
    await fuenteDatosLocal.insertarEvento(modelo);
  }

  @override
  Future<List<EventoEntidad>> obtenerEventos() async {
    return await fuenteDatosLocal.obtenerEventos();
  }

  @override
  Future<void> eliminarEvento(int id) async {
    await fuenteDatosLocal.borrarEvento(id);
  }

  @override
  Future<void> editarEvento(EventoEntidad evento) async {
    // Convertir la Entidad a Modelo
    final idPerfil = evento.perfilId ?? await DbHelper().obtenerPerfilId();
    final modelo = _mapearEntidadAModelo(evento, idPerfil);
    
    // Llamar al método en el DataSource
    await fuenteDatosLocal.actualizarEvento(modelo);
  }

  
  EventoModelo _mapearEntidadAModelo(EventoEntidad evento, perfilId) {
    return EventoModelo(
      id: evento.id,
      descripcion: evento.titulo,
      titulo: evento.titulo,
      fecha_inicio: evento.fecha_inicio,
      fecha_fin: evento.fecha_fin,
      tipo_evento: evento.tipo_evento,
      lugar: evento.lugar,
      perfilId: perfilId,
    );
  }
}
