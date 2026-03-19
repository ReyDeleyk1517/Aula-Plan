import 'package:aula_plan/features/recursos_docentes/data/fuentes_datos/recurso_docente_local_data_source.dart';
import 'package:aula_plan/features/recursos_docentes/data/repositorios/recurso_docente_implementacion_repositorio.dart';
import 'package:aula_plan/features/recursos_docentes/domain/casos_uso/recurso_docentes_casos_uso.dart';
import 'package:aula_plan/features/recursos_docentes/domain/repositorios/recurso_docentes_repositorio.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:get_it/get_it.dart';

// Bitacora
import 'package:aula_plan/features/bitacora/domain/casos_uso/bitacora_casos_uso.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_bitacora.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_formulario_bitacora.dart';
import 'package:aula_plan/features/bitacora/domain/repositorios/bitacora_repositorio.dart';
import 'package:aula_plan/features/bitacora/data/repositorios/bitacora_implementacion_repositorio.dart';
import 'package:aula_plan/features/bitacora/data/fuentes_datos/bitacora_local_data_source.dart';
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
  sl.registerFactory(() => CubitFormularioBitacora(
    guardarRegistro: sl(), 
    editarRegistro: sl(),
  ));

  sl.registerFactory(() => CubitBitacora(
    obtenerRegistros: sl(), 
    eliminarRegistro: sl(), 
  ));

  // Domain (casos uso)
  sl.registerLazySingleton(() => GuardarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => EditarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => ObtenerRegistrosBitacora(sl()));
  sl.registerLazySingleton(() => EliminarRegistroBitacora(sl()));

  // Data (Repositorios y Data Sources)
  sl.registerLazySingleton<BitacoraRepositorio>(
    () => BitacoraImplementacionRepositorio(
      fuenteDatosLocal: sl(), 
    ),
  );

  sl.registerLazySingleton<BitacoraLocalDataSource>(
    () => ImplementacionBitacoraLocalDataSource(),
  );


  // ===========================================================================
  // MODULO: PERFIL
  // ===========================================================================

  // Presentation (Cubits/Blocs)
  sl.registerFactory(() => CubitFormularioPerfil(
    guardarRegistro: sl(),
    editarRegistro: sl(),
  ));

  sl.registerFactory(() => CubitPerfil(
    obtenerRegistros: sl(),
    eliminarRegistro: sl(),
  ));

  // Domain (Use Cases)
  sl.registerLazySingleton(() => ObtenerRegistrosPerfil(sl()));
  sl.registerLazySingleton(() => EliminarRegistroPerfil(sl()));
  sl.registerLazySingleton(() => GuardarRegistroPerfil(sl()));
  sl.registerLazySingleton(() => EditarRegistroPerfil(sl()));

  // Data (Repositories & Data Sources)
  sl.registerLazySingleton<PerfilRepositorio>(
    () => PerfilImplementacionRepositorio(
      fuenteDatosLocal: sl(),
    ),
  );

  sl.registerLazySingleton<PerfilLocalDataSource>(
    () => ImplementacionPerfilLocalDataSource(),
  );

  // ===========================================================================
  // MODULO: RECURSOS DOCENTES
  // ===========================================================================

  // Presentation (Cubit)
  sl.registerFactory(() => RecursosDocenteCubit(
    guardarRegistros: sl(), 
    eliminarRegistro: sl(),
    obtenerRegistros: sl(), 
  ));

  // Domain (Use Cases)
  sl.registerLazySingleton(() => ObtenerRegistrosRecursos(sl()));
  sl.registerLazySingleton(() => EliminarRegistroRecursos(sl()));
  sl.registerLazySingleton(() => GuardarRegistroRecursos(sl()));
  sl.registerLazySingleton(() => EditarRegistroRecursos(sl()));


  // Data (Repositorio) 
  sl.registerLazySingleton<RecursoDocentesRepositorio>(
    () => RecursoDocenteRepositorioImpl(
      fuenteDatosLocal: sl(),
    ), 
  );

  sl.registerLazySingleton<RecursoDocenteLocalDataSource>(
    () => ImplementacionRecursoDocenteLocalDataSource(),
  );
}