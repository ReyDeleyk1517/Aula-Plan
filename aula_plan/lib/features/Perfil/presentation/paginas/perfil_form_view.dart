import 'package:aula_plan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/Perfil/domain/entidades/perfil_entidad.dart';
import 'package:aula_plan/core/injection_container.dart' as di;
import 'package:aula_plan/features/Perfil/presentation/bloc/cubit_formulario_perfil.dart';

class PerfilFormView extends StatefulWidget {
  final PerfilEntidad? perfil;
  const PerfilFormView({Key? key, this.perfil}) : super(key: key);
  @override
  _PerfilFormViewState createState() => _PerfilFormViewState();
}

class _PerfilFormViewState extends State<PerfilFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _regionController;
  late TextEditingController _zonaController;
  late TextEditingController _funcionController;
  late TextEditingController _centroController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.perfil?.nombre ?? '');
    _apellidosController = TextEditingController(text: widget.perfil?.apellidos ?? '');
    _regionController = TextEditingController(text: widget.perfil?.region ?? '');
    _zonaController = TextEditingController(text: widget.perfil?.zona_escolar ?? '');
    _funcionController = TextEditingController(text: widget.perfil?.funcion ?? '');
    _centroController = TextEditingController(text: widget.perfil?.centro_trabajo ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _regionController.dispose();
    _zonaController.dispose();
    _funcionController.dispose();
    _centroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CubitFormularioPerfil>(),
      child: BlocListener<CubitFormularioPerfil, FormPerfilState>(
        listener: (context, state) {
          if (state.status == FormPerfilStatus.exito) {
            // 1. Mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil guardado correctamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // 2. Navegación inteligente
            if (widget.perfil == null) {
              // Si es nuevo, reiniciamos la pila hacia el MenuPrincipal
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MenuPrincipal()),
                (route) => false,
              );
            } else {
              // Si es edición, regresamos a la vista anterior
              Navigator.pop(context);
            }
          } else if (state.status == FormPerfilStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensajeError ?? 'Error al guardar'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.perfil == null ? 'Crear Perfil' : 'Editar Perfil'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(label: 'Nombre', controller: _nombreController, icon: Icons.person_outline),
                  _buildTextField(label: 'Apellidos', controller: _apellidosController, icon: Icons.badge_outlined),
                  _buildTextField(label: 'Región', controller: _regionController, icon: Icons.location_on_outlined),
                  _buildTextField(label: 'Zona Escolar', controller: _zonaController, icon: Icons.school_outlined),
                  _buildTextField(label: 'Función', controller: _funcionController, icon: Icons.work_outline),
                  _buildTextField(label: 'Centro de Trabajo', controller: _centroController, icon: Icons.business_outlined),
                  const SizedBox(height: 30),
                  
                  // Botón envuelto en BlocBuilder para reaccionar al estado de carga
                  BlocBuilder<CubitFormularioPerfil, FormPerfilState>(
                    builder: (context, state) {
                      final bool estaCargando = state.status == FormPerfilStatus.cargando;
                      
                      return ElevatedButton.icon(
                        onPressed: estaCargando 
                          ? null // Desactiva el botón mientras guarda
                          : () {
                              if ((_formKey.currentState?.validate() ?? false)) {
                                final perfil = PerfilEntidad(
                                  id: widget.perfil?.id,
                                  nombre: _nombreController.text,
                                  apellidos: _apellidosController.text,
                                  region: _regionController.text,
                                  zona_escolar: _zonaController.text,
                                  funcion: _funcionController.text,
                                  centro_trabajo: _centroController.text,
                                );
                                context.read<CubitFormularioPerfil>().procesarPerfil(perfil);
                              }
                            },
                        icon: estaCargando 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Icon(Icons.save),
                        label: Text(
                          estaCargando ? 'Guardando...' : 'Guardar Perfil',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words, // Mejora la experiencia de escritura
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor ingresa: $label';
          }
          return null;
        },
      ),
    );
  }
}