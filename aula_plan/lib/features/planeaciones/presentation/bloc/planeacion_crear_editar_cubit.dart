import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/planeacion_entidades.dart';
import '../../domain/casos_uso/planeacion_casos_uso.dart';

enum FormStatus { inicial, cargando, exito, error }

class PlaneacionCrearEditarState {
  final FormStatus status;
  final String? mensajeError;

  PlaneacionCrearEditarState({this.status = FormStatus.inicial, this.mensajeError});
}

class PlaneacionCrearEditarCubit extends Cubit<PlaneacionCrearEditarState> {
  final GuardarPlaneacion guardarPlaneacion;
  final EditarPlaneacion editarPlaneacion;

  PlaneacionCrearEditarCubit({required this.guardarPlaneacion, required this.editarPlaneacion})
      : super(PlaneacionCrearEditarState());

  Future<void> procesarPlaneacion(PlaneacionEntidad planeacion) async {
    emit(PlaneacionCrearEditarState(status: FormStatus.cargando));
    try {
      if (planeacion.id == null) {
        await guardarPlaneacion(planeacion);
      } else {
        await editarPlaneacion(planeacion);
      }
      emit(PlaneacionCrearEditarState(status: FormStatus.exito));
    } catch (e) {
      emit(PlaneacionCrearEditarState(status: FormStatus.error, mensajeError: e.toString()));
    }
  }
}
