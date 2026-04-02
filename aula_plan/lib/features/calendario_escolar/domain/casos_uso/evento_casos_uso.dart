import 'package:aula_plan/features/calendario_escolar/domain/entidades/evento_entidad.dart';
import 'package:aula_plan/features/calendario_escolar/domain/repositorios/evento_repositorio.dart';


class ObtenerEventos {
  final EventoRepositorio repositorio; 

  ObtenerEventos(this.repositorio); 

  Future<List<EventoEntidad>> call() async {
    return await repositorio.obtenerEventos(); 
  }
}


class GuardarEvento {
  final EventoRepositorio repositorio;

  GuardarEvento(this.repositorio);

  Future<void> call(EventoEntidad planeacion) async {
    return await repositorio.guardarEvento(planeacion);
  }
}

class EditarEvento {
  final EventoRepositorio repositorio;

  EditarEvento(this.repositorio);

  Future<void> call(EventoEntidad planeacion) async {
    return await repositorio.editarEvento(planeacion);
  }
}

class EliminarEvento {
  final EventoRepositorio repositorio; 

  EliminarEvento(this.repositorio);

  Future<void> call(int id) async {
    return await repositorio.eliminarEvento(id); 
  }
}


