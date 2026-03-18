import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/perfil_entidad.dart';
import '../../domain/casos de uso/perfil_casos_uso.dart';

enum PerfilStatus { inicial, cargando, exito, error }

class PerfilState {
  final PerfilStatus status;
  final List<PerfilEntidad> perfiles;
  final String? error;
  PerfilState({this.status = PerfilStatus.inicial, this.perfiles = const [], this.error});

  PerfilState copyWith({PerfilStatus? status, List<PerfilEntidad>? perfiles, String? error}) {
    return PerfilState(
      status: status ?? this.status,
      perfiles: perfiles ?? this.perfiles,
      error: error ?? this.error,
    );
  }
}

class CubitPerfil extends Cubit<PerfilState> {
  final ObtenerRegistrosPerfil obtenerRegistros;
  final EliminarRegistroPerfil eliminarRegistro;

  CubitPerfil({required this.obtenerRegistros, required this.eliminarRegistro})
      : super(PerfilState());

  Future<void> cargarPerfiles() async {
    emit(state.copyWith(status: PerfilStatus.cargando));
    try {
      final lista = await obtenerRegistros();
      // Cambiamos a status: PerfilStatus.exito
      emit(state.copyWith(status: PerfilStatus.exito, perfiles: lista));
    } catch (e) {
      emit(state.copyWith(status: PerfilStatus.error, error: e.toString()));
    }
  }
}