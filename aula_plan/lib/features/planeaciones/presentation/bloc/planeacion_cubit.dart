import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/planeacion_entidades.dart';
import '../../domain/casos_uso/planeacion_casos_uso.dart';

class PlaneacionState {
  final bool cargando;
  final List<PlaneacionEntidad> planeaciones;
  final String? error;

  PlaneacionState({
    this.cargando = false,
    this.planeaciones = const [],
    this.error,
  });

  PlaneacionState copyWith({bool? cargando, List<PlaneacionEntidad>? planeaciones, String? error}) {
    return PlaneacionState(
      cargando: cargando ?? this.cargando,
      planeaciones: planeaciones ?? this.planeaciones,
      error: error ?? this.error,
    );
  }
}

class PlaneacionCubit extends Cubit<PlaneacionState> {
  final ObtenerPlaneaciones obtenerPlaneaciones;
  final EliminarPlaneacion eliminarPlaneacion;

  PlaneacionCubit({required this.obtenerPlaneaciones, required this.eliminarPlaneacion})
      : super(PlaneacionState(cargando: true));

  Future<void> cargarPlaneaciones() async {
    emit(state.copyWith(cargando: true, error: null));
    try {
      final lista = await obtenerPlaneaciones();
      emit(state.copyWith(cargando: false, planeaciones: lista));
    } catch (e) {
      emit(state.copyWith(cargando: false, error: 'Error al cargar planeaciones'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await eliminarPlaneacion(id);
      await cargarPlaneaciones();
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar planeación'));
    }
  }
}
