import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/injection_container.dart' as di;
import 'core/injection_container.dart';

// Presentacion
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_bitacora.dart';
import 'package:aula_plan/features/bitacora/presentation/paginas/pagina_bitacora.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // inicializar GET_IT
  await di.init(); 
  
  await initializeDateFormatting('es_ES', null);

  runApp(const MainApp()); 
}

class MainApp extends StatelessWidget {
  const MainApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // usar 'sl' para crear cubits
        // GetIt encargara que casos de uso inyectar automáticamente
        BlocProvider(
          create: (context) => sl<CubitBitacora>()..cargarRegistros(DateTime.now()),
        ),
      ],
      child: MaterialApp(
        title: 'Aula Plan',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6366F1),
        ),
        home: const PaginaBitacora(),
      ),
    );
  }
}