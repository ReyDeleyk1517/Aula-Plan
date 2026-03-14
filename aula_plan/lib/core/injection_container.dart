import 'package:aula_plan/features/bitacora/domain/casos_uso/casos_uso.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_bitacora.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_formulario_bitacora.dart';
import 'package:get_it/get_it.dart';

// Importar repositorios y data sources
import 'package:aula_plan/features/bitacora/domain/repositorios/repositorio_bitacora.dart';
import 'package:aula_plan/features/bitacora/data/repositorios/implementacion_repositorio_bitacora.dart';
import 'package:aula_plan/features/bitacora/data/fuentes_datos/bitacora_local_data_source.dart';
final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // PRESENTATION (Factory) 
  sl.registerFactory(() => CubitFormularioBitacora(
    guardarRegistro: sl(), 
    editarRegistro: sl(),
  ));

  sl.registerFactory(() => CubitBitacora(
    obtenerRegistros: sl(), 
    eliminarRegistro: sl(), 

  ));

  // DOMAIN / CASOS DE USO (LazySingleton) 
  sl.registerLazySingleton(() => GuardarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => EditarRegistroBitacora(sl()));
  sl.registerLazySingleton(() => ObtenerRegistrosBitacora(sl()));
  sl.registerLazySingleton(() => EliminarRegistroBitacora(sl()));

  // DATA / REPOSITORIOS
  sl.registerLazySingleton<RepositorioBitacora>(
    () => ImplementacionRepositorioBitacora(
      fuenteDatosLocal: sl(), 
    ),
  );

  // DATA SOURCES 
  sl.registerLazySingleton<BitacoraLocalDataSource>(
    () => ImplementacionBitacoraLocalDataSource(),
  );
}