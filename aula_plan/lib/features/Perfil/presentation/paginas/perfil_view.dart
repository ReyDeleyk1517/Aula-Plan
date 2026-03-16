import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
      ),
      home: const PerfilView(),
    );
  }
}

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil de Usuario"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar decorativo con estilo moderno
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person, 
                      size: 60, 
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Campos de texto utilizando el helper method
              _buildTextField(label: "Nombre", icon: Icons.person_outline),
              _buildTextField(label: "Apellidos", icon: Icons.badge_outlined),
              _buildTextField(label: "Región", icon: Icons.location_on_outlined),
              _buildTextField(label: "Zona Escolar", icon: Icons.school_outlined),
              _buildTextField(label: "Función", icon: Icons.work_outline),
              _buildTextField(label: "Centro de Trabajo", icon: Icons.business_outlined),

              const SizedBox(height: 30),

              // Botón de Guardar
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos de perfil actualizados')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Guardar Perfil", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable optimizado para PerfilView
  Widget _buildTextField({required String label, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa: $label';
          }
          return null;
        },
      ),
    );
  }
}