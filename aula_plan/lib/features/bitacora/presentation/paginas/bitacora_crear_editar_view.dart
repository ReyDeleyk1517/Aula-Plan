import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/bitacora_entidad.dart';
import '../bloc/bitacora_crear_editar_cubit.dart'; 

class BitacoraCrearEditarView extends StatefulWidget {
  final BitacoraEntidad? registroExistente;
  final DateTime fechaSeleccionada;

  const BitacoraCrearEditarView({
    super.key, 
    this.registroExistente, 
    required this.fechaSeleccionada
  });

  @override
  State<BitacoraCrearEditarView> createState() => _PaginaRegistroBitacoraState();
}

class _PaginaRegistroBitacoraState extends State<BitacoraCrearEditarView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _tituloCtrl;
  late TextEditingController _actividadCtrl;
  late TextEditingController _observacionesCtrl;
  late String _categoria;
  late String _hora;

  @override
  void initState() {
    super.initState();
    // Inicializar con datos existentes o valores por defecto
    final r = widget.registroExistente;
    _tituloCtrl = TextEditingController(text: r?.titulo ?? "");
    _actividadCtrl = TextEditingController(text: r?.actividad ?? "");
    _observacionesCtrl = TextEditingController(text: r?.observaciones ?? "");
    _categoria = r?.categoria ?? "Clases";
    _hora = r?.hora ?? _formatearHora(TimeOfDay.now());
  }

  String _formatearHora(TimeOfDay time) => 
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  void _guardar(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final registro = BitacoraEntidad(
        // Si tiene ID, el Cubit detectara que es edición
        id: widget.registroExistente?.id, 
        titulo: _tituloCtrl.text,
        actividad: _actividadCtrl.text,
        observaciones: _observacionesCtrl.text,
        categoria: _categoria,
        hora: _hora,
        fecha: widget.registroExistente?.fecha ?? 
               "${widget.fechaSeleccionada.year}-${widget.fechaSeleccionada.month.toString().padLeft(2, '0')}-${widget.fechaSeleccionada.day.toString().padLeft(2, '0')}",
      );

      context.read<BitacoraCrearEditarCubit>().procesarRegistro(registro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BitacoraCrearEditarCubit, BitacoraCrearEditarState>(
      listener: (context, state) {
        if (state.status == FormStatus.exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Guardado correctamente"), backgroundColor: Colors.green)
          );
          // Retornar 'true' para indicar que hubo cambios
          Navigator.pop(context, true); 
        }
        if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensajeError ?? "Error"), backgroundColor: Colors.red)
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.registroExistente == null ? "Nueva Actividad" : "Editar Actividad"),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: "Categoría", border: OutlineInputBorder()),
                  items: ["Clases", "Incidencias", "Evaluaciones", "Otros"]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _categoria = val!),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _actividadCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _observacionesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Observaciones (Opcional)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 30),
                
                BlocBuilder<BitacoraCrearEditarCubit, BitacoraCrearEditarState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                        onPressed: state.status == FormStatus.cargando ? null : () => _guardar(context),
                        child: state.status == FormStatus.cargando 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("GUARDAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}