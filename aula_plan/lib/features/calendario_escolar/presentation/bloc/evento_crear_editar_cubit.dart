import 'package:aula_plan/features/calendario_escolar/domain/casos_uso/evento_casos_uso.dart';
import 'package:aula_plan/features/calendario_escolar/domain/entidades/evento_entidad.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FormStatus { inicial, cargando, exito, error }

class EventoCrearEditarState {
  final FormStatus status;
  final String? mensajeError;

  EventoCrearEditarState({this.status = FormStatus.inicial, this.mensajeError});
}

class EventoCrearEditarCubit extends Cubit<EventoCrearEditarState> {
  final GuardarEvento guardarEvento;
  final EditarEvento editarEvento;

  EventoCrearEditarCubit({required this.guardarEvento, required this.editarEvento})
      : super(EventoCrearEditarState());

  Future<void> procesarEvento(EventoEntidad evento) async {
    emit(EventoCrearEditarState(status: FormStatus.cargando));
    try {
      if (evento.id == null) {
        await guardarEvento(evento);
      } else {
        await editarEvento(evento);
      }
      emit(EventoCrearEditarState(status: FormStatus.exito));
    } catch (e) {
      emit(EventoCrearEditarState(status: FormStatus.error, mensajeError: e.toString()));
    }
  }
}
