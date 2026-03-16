import 'package:aula_plan/features/Perfil/presentation/paginas/perfil_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/injection_container.dart' as di;
import 'core/injection_container.dart';

// Presentacion
import 'package:aula_plan/features/bitacora/presentation/bloc/cubit_bitacora.dart';
import 'package:aula_plan/features/bitacora/presentation/paginas/bitacora_view.dart';

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
        home: const MenuPrincipal(),
      ),
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula Plan - Módulos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _crearBotonModulo(
              context,
              titulo: 'Bitácora',
              icono: Icons.auto_stories,
              color: Colors.indigo,
              destino: const PaginaBitacora(),
            ),
            _crearBotonModulo(
              context,
              titulo: 'Perfil',
              icono: Icons.person_rounded,
              color: Colors.orange,
              destino: const PerfilView(), 
              
            ),
            // Aquí puedes agregar más botones fácilmente
          ],
        ),
      ),
    );
  }

  Widget _crearBotonModulo(BuildContext context, 
      {required String titulo, required IconData icono, required Color color, required Widget destino}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destino),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}