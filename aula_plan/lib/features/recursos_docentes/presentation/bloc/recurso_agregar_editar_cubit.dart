import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entidades/recurso_docentes_entidad.dart';
import '../../domain/casos_uso/recurso_docentes_casos_uso.dart';

class recursoAgregarEditarState {
  final int? id;
  final String nombre;
  final String area;
  final String campoFormativo;
  final bool esEnlace;
  final String rutaOEnlace;
  final bool estaGuardando;
  final String? mensajeError;

  const recursoAgregarEditarState({
    this.id,
    this.nombre = '',
    this.area = 'Psicología',
    this.campoFormativo = 'Lenguajes',
    this.esEnlace = false,
    this.rutaOEnlace = '',
    this.estaGuardando = false,
    this.mensajeError,
  });

  recursoAgregarEditarState copyWith({
    int? id,
    String? nombre,
    String? area,
    String? campoFormativo,
    bool? esEnlace,
    String? rutaOEnlace,
    bool? estaGuardando,
    String? mensajeError,
  }) {
    return recursoAgregarEditarState(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      area: area ?? this.area,
      campoFormativo: campoFormativo ?? this.campoFormativo,
      esEnlace: esEnlace ?? this.esEnlace,
      rutaOEnlace: rutaOEnlace ?? this.rutaOEnlace,
      estaGuardando: estaGuardando ?? this.estaGuardando,
      mensajeError: mensajeError,
    );
  }

  bool get esValido => nombre.trim().isNotEmpty && rutaOEnlace.trim().isNotEmpty;
}

class recursoAgregarEditarCubit extends Cubit<recursoAgregarEditarState> {
  final GuardarRegistroRecursos guardarUsecase;
  final EditarRegistroRecursos editarUsecase;

  recursoAgregarEditarCubit({
    required this.guardarUsecase,
    required this.editarUsecase,
  }) : super(const recursoAgregarEditarState());

  void cargarRecursoParaEdicion(RecursoDocenteEntidad recurso) {
    emit(state.copyWith(
      id: recurso.id,
      nombre: recurso.nombre,
      area: recurso.area,
      campoFormativo: recurso.campoFormativo,
      esEnlace: recurso.tipoArchivo == 'enlace',
      rutaOEnlace: (recurso.tipoArchivo == 'enlace') 
          ? (recurso.enlace ?? '') 
          : (recurso.rutaArchivo ?? ''),
    ));
  }

  void cambiarNombre(String val) => emit(state.copyWith(nombre: val));
  void cambiarArea(String val) => emit(state.copyWith(area: val));
  void cambiarCampo(String val) => emit(state.copyWith(campoFormativo: val));
  
  void toggleTipo(bool esEnlace) {
    emit(state.copyWith(
      esEnlace: esEnlace, 
      rutaOEnlace: '', 
    ));
  }

  void cambiarEnlace(String val) => emit(state.copyWith(rutaOEnlace: val));

  Future<void> seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      emit(state.copyWith(
        rutaOEnlace: file.path,
        nombre: state.nombre.isEmpty ? file.name : state.nombre,
      ));
    }
  }

  /// Método principal de persistencia
  Future<bool> ejecutarGuardado() async {
    if (!state.esValido) return false;
    emit(state.copyWith(estaGuardando: true));

    try {
      final tipoCalculado = state.esEnlace 
          ? 'enlace' 
          : state.rutaOEnlace.split('.').last.toLowerCase();

      final recurso = RecursoDocenteEntidad(
        id: state.id,
        nombre: state.nombre,
        area: state.area,
        campoFormativo: state.campoFormativo,
        tipoArchivo: tipoCalculado,
        rutaArchivo: state.esEnlace ? null : state.rutaOEnlace,
        enlace: state.esEnlace ? state.rutaOEnlace : null,
        fechaCreacion: DateTime.now(),
      );

      if (state.id == null) {
        await guardarUsecase(recurso);
      } else {
        await editarUsecase(recurso);
      }
      
      emit(state.copyWith(estaGuardando: false));
      return true;
    } catch (e) {
      emit(state.copyWith(estaGuardando: false, mensajeError: e.toString()));
      return false;
    }
  }
}