import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

class AgregarRecursoState {
  final String nombre;
  final String area;
  final String campoFormativo;
  final bool esEnlace; // true: enlace, false: archivo
  final String rutaOEnlace;
  final bool estaGuardando;

  const AgregarRecursoState({
    this.nombre = '',
    this.area = 'Psicología',
    this.campoFormativo = 'Lenguajes',
    this.esEnlace = false,
    this.rutaOEnlace = '',
    this.estaGuardando = false,
  });

  AgregarRecursoState copyWith({
    String? nombre,
    String? area,
    String? campoFormativo,
    bool? esEnlace,
    String? rutaOEnlace,
    bool? estaGuardando,
  }) {
    return AgregarRecursoState(
      nombre: nombre ?? this.nombre,
      area: area ?? this.area,
      campoFormativo: campoFormativo ?? this.campoFormativo,
      esEnlace: esEnlace ?? this.esEnlace,
      rutaOEnlace: rutaOEnlace ?? this.rutaOEnlace,
      estaGuardando: estaGuardando ?? this.estaGuardando,
    );
  }

  bool get esValido => nombre.isNotEmpty && rutaOEnlace.isNotEmpty;
}

class AgregarRecursoCubit extends Cubit<AgregarRecursoState> {
  AgregarRecursoCubit() : super(const AgregarRecursoState());

  void cambiarNombre(String val) => emit(state.copyWith(nombre: val));
  void cambiarArea(String val) => emit(state.copyWith(area: val));
  void cambiarCampo(String val) => emit(state.copyWith(campoFormativo: val));
  
  void toggleTipo(bool esEnlace) {
    emit(state.copyWith(esEnlace: esEnlace, rutaOEnlace: ''));
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
}