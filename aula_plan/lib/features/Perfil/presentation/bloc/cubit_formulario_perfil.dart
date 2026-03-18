import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/perfil_entidad.dart';
import '../../domain/casos de uso/perfil_casos_uso.dart';

enum FormPerfilStatus { inicial, cargando, exito, error }

class FormPerfilState {
  final FormPerfilStatus status;
  final String? mensajeError;
  FormPerfilState({this.status = FormPerfilStatus.inicial, this.mensajeError});
}

class CubitFormularioPerfil extends Cubit<FormPerfilState> {
  final GuardarRegistroPerfil guardarRegistro;
  final EditarRegistroPerfil editarRegistro;

  CubitFormularioPerfil({required this.guardarRegistro, required this.editarRegistro})
      : super(FormPerfilState());

  Future<void> procesarPerfil(PerfilEntidad perfil) async {
    emit(FormPerfilState(status: FormPerfilStatus.cargando));
    try {
      if (perfil.id == null) {
        await guardarRegistro(perfil);
      } else {
        await editarRegistro(perfil);
      }
      emit(FormPerfilState(status: FormPerfilStatus.exito));
    } catch (e) {
      emit(FormPerfilState(status: FormPerfilStatus.error, mensajeError: e.toString()));
    }
  }
}
