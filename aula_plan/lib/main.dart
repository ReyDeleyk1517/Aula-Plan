import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/paginas/recurso_docente_view.dart';
import 'package:aula_plan/planeacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/injection_container.dart' as di;
import 'core/injection_container.dart';

import 'package:aula_plan/core/db_helper.dart'; 

import 'package:aula_plan/features/Perfil/presentation/paginas/perfil_form_view.dart';
import 'package:aula_plan/features/Perfil/presentation/paginas/perfil_view.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/bitacora_cubit.dart';
import 'package:aula_plan/features/bitacora/presentation/paginas/bitacora_view.dart';

import 'dart:io'; // detectar la plataforma
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importar FFI para sqlite windows

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // --- AGREGAR ESTO PARA WINDOWS ---
    if (Platform.isWindows || Platform.isLinux) {
      // Inicializar FFI para bases de datos en escritorio
      sqfliteFfiInit();
      // Cambiar el factory global para usar FFI
      databaseFactory = databaseFactoryFfi;
    }
    // ---------------------------------

    // Inicializar dependencias (GetIt)
    await di.init(); 
    
    // Inicializar la base de datos
    await DbHelper().initDatabase();
    
    await initializeDateFormatting('es_ES', null);

    runApp(const MainApp());
  } catch (e) {
    debugPrint("Error durante el arranque: $e");
    runApp(const MainApp()); 
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<BitacoraCubit>()..cargarRegistros(DateTime.now()),
        ),
        BlocProvider(
          create: (context) => sl<RecursosDocenteCubit>()..cargarRecursos(),
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
        // Pantalla de entrada que decide a dónde ir
        home: const AppStart(),
      ),
    );
  }
}

// App start
class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  @override
  void initState() {
    super.initState();
    _checkProfileAndNavigate();
  }

  Future<void> _checkProfileAndNavigate() async {
    try {
      // verificar existencia de perfil
      final bool tienePerfil = await DbHelper().existePerfil();

      if (!mounted) return;

      if (!tienePerfil) {
        // No hay perfil -> Crear uno
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PerfilFormView()),
        );
      } else {
        // Ya tiene perfil -> Ir al menú
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuPrincipal()),
        );
      }
    } catch (e) {
      debugPrint("Error verificando perfil: $e");
      // En caso de error crítico, intentar abrir menu
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuPrincipal()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Iniciando Aula Plan...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// MENÚ PRINCIPAL 
class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula Plan - USAER'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _crearBotonModulo(
              context,
              titulo: 'Bitácora',
              icono: Icons.auto_stories,
              color: Colors.indigo,
              destino: const BitacoraView(),
            ),
            _crearBotonModulo(
              context,
              titulo: 'Planeación',
              icono: Icons.assignment_turned_in_rounded,
              color: Colors.teal,
              destino: PlaneacionScreen(),
            ),
            _crearBotonModulo(
              context,
              titulo: 'Calendario',
              icono: Icons.calendar_month_rounded,
              color: Colors.redAccent,
              destino: const PlaceholderView(titulo: 'Calendario', color: Colors.redAccent),
            ),
            _crearBotonModulo(
              context,
              titulo: 'Recursos',
              icono: Icons.folder_shared_rounded,
              color: Colors.amber,
              destino: RecursosDocenteView(),
            ),
            _crearBotonModulo(
              context,
              titulo: 'Perfil',
              icono: Icons.person_rounded,
              color: Colors.orange,
              destino: const PerfilView(), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearBotonModulo(BuildContext context, 
      {required String titulo, required IconData icono, required Color color, required Widget destino}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 50, color: color),
            const SizedBox(height: 10),
            Text(titulo, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Vista genérica para módulos en desarrollo
class PlaceholderView extends StatelessWidget {
  final String titulo;
  final Color color;

  const PlaceholderView({super.key, required this.titulo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: color.withOpacity(0.2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: color),
            const SizedBox(height: 20),
            Text(
              'Módulo de $titulo',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('Próximamente disponible', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}