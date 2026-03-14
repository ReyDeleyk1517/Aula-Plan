import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/entidad_bitacora.dart';
import '../../domain/casos_uso/casos_uso.dart';

enum FormStatus { inicial, cargando, exito, error }

class FormBitacoraState {
  final FormStatus status;
  final String? mensajeError;

  FormBitacoraState({this.status = FormStatus.inicial, this.mensajeError});
}

class CubitFormularioBitacora extends Cubit<FormBitacoraState> {
  final GuardarRegistroBitacora guardarRegistro;
  final EditarRegistroBitacora editarRegistro;

  CubitFormularioBitacora({
    required this.guardarRegistro,
    required this.editarRegistro,
  }) : super(FormBitacoraState());

  Future<void> procesarRegistro(EntidadBitacora registro) async {
    emit(FormBitacoraState(status: FormStatus.cargando));
    try {
      if (registro.id == null) {
        await guardarRegistro(registro);
      } else {
        await editarRegistro(registro);
      }
      emit(FormBitacoraState(status: FormStatus.exito));
    } catch (e) {
      emit(FormBitacoraState(status: FormStatus.error, mensajeError: e.toString()));
    }
  }
}