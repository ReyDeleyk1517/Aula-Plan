import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_agregar_cubit.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/recurso_docentes_entidad.dart';

class AgregarRecursoScreen extends StatelessWidget {
  const AgregarRecursoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgregarRecursoCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: const Text("Nuevo Recurso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
        ),
        body: const _FormularioRecurso(),
      ),
    );
  }
}

class _FormularioRecurso extends StatelessWidget {
  const _FormularioRecurso();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: BlocBuilder<AgregarRecursoCubit, AgregarRecursoState>(
        builder: (context, state) {
          final cubit = context.read<AgregarRecursoCubit>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información General"),
              const SizedBox(height: 12),

              // Nombre del Recurso
              TextFormField(
                initialValue: state.nombre,
                decoration: _inputStyle("Nombre del recurso", Icons.title),
                onChanged: cubit.cambiarNombre,
              ),

              const SizedBox(height: 20),

              // Selectores de Área y Campo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      label: "Área",
                      value: state.area,
                      items: const [
                        'Psicología',
                        'Comunicación',
                        'Trabajo Social',
                        'Pedagogía'
                      ],
                      onChanged: (val) => cubit.cambiarArea(val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      label: "Campo Formativo",
                      value: state.campoFormativo,
                      items: const [
                        'Lenguajes',
                        'Saberes y pensamiento cientifico',
                        'De lo Humano y comunitario',
                        'Etica Naturaleza y sociedad'
                      ],
                      onChanged: (val) => cubit.cambiarCampo(val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              _buildSectionTitle("Tipo de Contenido"),
              const SizedBox(height: 12),

              // Selector de Archivo o Enlace
              Center(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        label: Text("Archivo"),
                        icon: Icon(Icons.file_present)),
                    ButtonSegment(
                        value: true,
                        label: Text("Enlace"),
                        icon: Icon(Icons.link)),
                  ],
                  selected: {state.esEnlace},
                  onSelectionChanged: (val) => cubit.toggleTipo(val.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: const Color(0xFF8B1D1D),
                    selectedForegroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input Dinámico (Archivo o URL)
              if (state.esEnlace)
                TextFormField(
                  decoration: _inputStyle("Pegar enlace (URL)", Icons.link),
                  onChanged: cubit.cambiarEnlace,
                )
              else
                _buildFilePicker(context, state, cubit),

              const SizedBox(height: 40),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1D1D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: state.esValido
                      ? () => _guardarTodo(context, state)
                      : null,
                  child: const Text("Guardar Recurso",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 1));
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF8B1D1D)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildDropdown(
      {required String label,
      required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true, 
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis, // Corta el texto si es muy largo
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(
      BuildContext context, AgregarRecursoState state, AgregarRecursoCubit cubit) {
    final hasFile = state.rutaOEnlace.isNotEmpty;
    return InkWell(
      onTap: cubit.seleccionarArchivo,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasFile ? const Color(0xFF8B1D1D) : Colors.transparent,
              width: 2),
        ),
        child: Row(
          children: [
            Icon(hasFile ? Icons.check_circle : Icons.upload_file,
                color: hasFile ? Colors.green : const Color(0xFF8B1D1D)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                hasFile
                    ? "Archivo: ${state.rutaOEnlace.split('/').last}"
                    : "Seleccionar archivo",
                style: TextStyle(
                    color: hasFile
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF64748B),
                    fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarTodo(BuildContext context, AgregarRecursoState state) {
    final nuevoRecurso = RecursoDocenteEntidad(
      id: null,
      nombre: state.nombre,
      area: state.area,
      campoFormativo: state.campoFormativo,
      tipoArchivo: state.esEnlace ? 'enlace' : state.rutaOEnlace.split('.').last,
      rutaArchivo: state.rutaOEnlace,
      enlace: state.esEnlace ? state.rutaOEnlace : null,
      fechaCreacion: DateTime.now(),
    );

    context.read<RecursosDocenteCubit>().agregarRecurso(nuevoRecurso);
    Navigator.pop(context);
  }
}