import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/core/injection_container.dart' as di;
import 'package:aula_plan/features/Perfil/presentation/bloc/cubit_perfil.dart';
import 'package:aula_plan/features/Perfil/presentation/paginas/perfil_form_view.dart';
import 'package:aula_plan/features/Perfil/domain/entidades/perfil_entidad.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Creamos el Cubit y cargamos los datos inmediatamente
      create: (_) => di.sl<CubitPerfil>()..cargarPerfiles(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mi Perfil"),
          centerTitle: true,
          actions: [
            // Botón de editar en la parte superior para fácil acceso
            BlocBuilder<CubitPerfil, PerfilState>(
              builder: (context, state) {
                if (state.perfiles.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _irAFormulario(context, state.perfiles.first),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body: BlocBuilder<CubitPerfil, PerfilState>(
          builder: (context, state) {
            if (state.status == PerfilStatus.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.perfiles.isEmpty) {
              return const Center(child: Text("No se encontró información del perfil."));
            }

            final perfil = state.perfiles.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  // Información mostrada en tarjetas de solo lectura
                  _InfoCard(label: "Nombre Completo", value: "${perfil.nombre} ${perfil.apellidos}", icon: Icons.badge),
                  _InfoCard(label: "Región", value: perfil.region, icon: Icons.map),
                  _InfoCard(label: "Zona Escolar", value: perfil.zona_escolar, icon: Icons.school),
                  _InfoCard(label: "Función", value: perfil.funcion, icon: Icons.work),
                  _InfoCard(label: "Centro de Trabajo", value: perfil.centro_trabajo, icon: Icons.business),
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton.icon(
                    onPressed: () => _irAFormulario(context, perfil),
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar Información"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _irAFormulario(BuildContext context, PerfilEntidad perfil) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PerfilFormView(perfil: perfil),
      ),
    ).then((_) {
      // Al regresar del formulario, refrescamos los datos
      context.read<CubitPerfil>().cargarPerfiles();
    });
  }
}

// Widget auxiliar para mostrar la información bonita
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}