// Recursos
import 'package:aula_plan/features/recursos_docentes/data/fuentes_datos/recurso_docente_local_data_source.dart';
import 'package:aula_plan/features/recursos_docentes/data/repositorios/recurso_docente_implementacion_repositorio.dart';
import 'package:aula_plan/features/recursos_docentes/domain/casos_uso/recurso_docentes_casos_uso.dart';
import 'package:aula_plan/features/recursos_docentes/domain/repositorios/recurso_docentes_repositorio.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_agregar_editar_cubit.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:get_it/get_it.dart';

// Bitacora
import 'package:aula_plan/features/bitacora/domain/casos_uso/bitacora_casos_uso.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/bitacora_cubit.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/bitacora_crear_editar_cubit.dart';
import 'package:aula_plan/features/bitacora/domain/repositorios/bitacora_repositorio.dart';
import 'package:aula_plan/features/bitacora/data/repositorios/bitacora_implementacion_repositorio.dart';
import 'package:aula_plan/features/bitacora/data/fuentes_datos/bitacora_local_data_source.dart';
// Planeaciones
import 'package:aula_plan/features/planeaciones/domain/casos_uso/planeacion_casos_uso.dart';
import 'package:aula_plan/features/planeaciones/domain/repositorios/planeacion_repositorio.dart';
import 'package:aula_plan/features/planeaciones/data/repositorios/planeacion_implementacion_repositorio.dart';
import 'package:aula_plan/features/planeaciones/data/fuentes_datos/planeacion_local_data_source.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_cubit.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_crear_editar_cubit.dart';
// Perfil
import 'package:aula_plan/features/Perfil/data/fuentes_datos/perfil_local_data_source.dart';
import 'package:aula_plan/features/Perfil/domain/repositorios/perfil_repositorio.dart';
import 'package:aula_plan/features/Perfil/data/repositorios/perfil_implementacion_repositorio.dart';
import 'package:aula_plan/features/Perfil/domain/casos de uso/perfil_casos_uso.dart';
import 'package:aula_plan/features/Perfil/presentation/bloc/cubit_perfil.dart';
import 'package:aula_plan/features/Perfil/presentation/bloc/cubit_formulario_perfil.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ===========================================================================
  // MODULO: BITÁCORA
  // ===========================================================================

  // Presentation (Cubits/Blocs)
  sl.registerFactory(
    () => BitacoraCrearEditarCubit(guardarRegistro: sl(), editarRegistro: sl()),
  );

  sl.registerFactory(
    () => BitacoraCubit(obtenerRegistros: sl(), eliminarRegistro: sl()),
  );

  // Domain (casos uso)
  sl.registerLazySingleton(() => GuardarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => EditarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => ObtenerRegistrosBitacora(sl()));
  sl.registerLazySingleton(() => EliminarRegistroBitacora(sl()));

  // Data (Repositorios y Data Sources)
  sl.registerLazySingleton<BitacoraRepositorio>(
    () => BitacoraImplementacionRepositorio(fuenteDatosLocal: sl()),
  );

  sl.registerLazySingleton<BitacoraLocalDataSource>(
    () => ImplementacionBitacoraLocalDataSource(),
  );

  // ===========================================================================
  // MODULO: PERFIL
  // ===========================================================================

  // Presentation (Cubits/Blocs)
  sl.registerFactory(
    () => CubitFormularioPerfil(guardarRegistro: sl(), editarRegistro: sl()),
  );

  sl.registerFactory(
    () => CubitPerfil(obtenerRegistros: sl(), eliminarRegistro: sl()),
  );

  // Domain (Use Cases)
  sl.registerLazySingleton(() => ObtenerRegistrosPerfil(sl()));
  sl.registerLazySingleton(() => EliminarRegistroPerfil(sl()));
  sl.registerLazySingleton(() => GuardarRegistroPerfil(sl()));
  sl.registerLazySingleton(() => EditarRegistroPerfil(sl()));

  // Data (Repositories & Data Sources)
  sl.registerLazySingleton<PerfilRepositorio>(
    () => PerfilImplementacionRepositorio(fuenteDatosLocal: sl()),
  );

  sl.registerLazySingleton<PerfilLocalDataSource>(
    () => ImplementacionPerfilLocalDataSource(),
  );

  // ===========================================================================
  // MODULO: RECURSOS DOCENTES
  // ===========================================================================

  // Presentation (Cubits/Blocs)
  sl.registerFactory(
    () => recursoAgregarEditarCubit(guardarUsecase: sl(), editarUsecase: sl()),
  );

  sl.registerFactory(
    () => RecursosDocenteCubit(eliminarRegistro: sl(), obtenerRegistros: sl()),
  );

  // Domain (Use Cases)
  sl.registerLazySingleton(() => ObtenerRegistrosRecursos(sl()));
  sl.registerLazySingleton(() => EliminarRegistroRecursos(sl()));
  sl.registerLazySingleton(() => GuardarRegistroRecursos(sl()));
  sl.registerLazySingleton(() => EditarRegistroRecursos(sl()));

  // Data (Repositorios y Data Sources)
  sl.registerLazySingleton<RecursoDocentesRepositorio>(
    () => RecursoDocenteRepositorioImpl(fuenteDatosLocal: sl()),
  );

  sl.registerLazySingleton<RecursoDocenteLocalDataSource>(
    () => ImplementacionRecursoDocenteLocalDataSource(),
  );

  // Planeaciones
  sl.registerFactory(
    () => PlaneacionCrearEditarCubit(guardarPlaneacion: sl(), editarPlaneacion: sl()),
  );
  sl.registerFactory(
    () => PlaneacionCubit(obtenerPlaneaciones: sl(), eliminarPlaneacion: sl()),
  );

  sl.registerLazySingleton(() => GuardarPlaneacion(sl()));
  sl.registerLazySingleton(() => EditarPlaneacion(sl()));
  sl.registerLazySingleton(() => ObtenerPlaneaciones(sl()));
  sl.registerLazySingleton(() => EliminarPlaneacion(sl()));

  sl.registerLazySingleton<PlaneacionRepositorio>(
    () => PlaneacionImplementacionRepositorio(fuenteDatosLocal: sl()),
  );

  sl.registerLazySingleton<PlaneacionLocalDataSource>(
    () => ImplementacionPlaneacionLocalDataSource(),
  );
}
