import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/bitacora_entidad.dart';
import '../../domain/casos_uso/bitacora_casos_uso.dart';

enum FormStatus { inicial, cargando, exito, error }

class BitacoraCrearEditarState {
  final FormStatus status;
  final String? mensajeError;

  BitacoraCrearEditarState({this.status = FormStatus.inicial, this.mensajeError});
}

class BitacoraCrearEditarCubit extends Cubit<BitacoraCrearEditarState> {
  final GuardarRegistroBitacora guardarRegistro;
  final EditarRegistroBitacora editarRegistro;

  BitacoraCrearEditarCubit({
    required this.guardarRegistro,
    required this.editarRegistro,
  }) : super(BitacoraCrearEditarState());

  Future<void> procesarRegistro(BitacoraEntidad registro) async {
    emit(BitacoraCrearEditarState(status: FormStatus.cargando));
    try {
      if (registro.id == null) {
        await guardarRegistro(registro);
      } else {
        await editarRegistro(registro);
      }
      emit(BitacoraCrearEditarState(status: FormStatus.exito));
    } catch (e) {
      emit(BitacoraCrearEditarState(status: FormStatus.error, mensajeError: e.toString()));
    }
  }
}