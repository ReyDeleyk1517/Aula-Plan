import 'package:aula_plan/core/injection_container.dart';
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
    required this.fechaSeleccionada,
  });

  @override
  State<BitacoraCrearEditarView> createState() =>
      _PaginaRegistroBitacoraState();
}

class _PaginaRegistroBitacoraState extends State<BitacoraCrearEditarView> {
  final _formKey = GlobalKey<FormState>();
  final Color zacTinto = const Color(0xFF8B1D1D); // Color institucional

  late TextEditingController _tituloCtrl;
  late TextEditingController _actividadCtrl;
  late TextEditingController _observacionesCtrl;
  late TextEditingController _gradoYGCtrl;
  late String _categoria;
  late String _hora;

  @override
  void initState() {
    super.initState();
    final r = widget.registroExistente;
    _tituloCtrl = TextEditingController(text: r?.titulo ?? "");
    _actividadCtrl = TextEditingController(text: r?.actividad ?? "");
    _observacionesCtrl = TextEditingController(text: r?.observaciones ?? "");
    _gradoYGCtrl = TextEditingController(text: r?.grado_y_grupo ?? "");
    _categoria = r?.categoria ?? "Clases";
    _hora = r?.hora ?? _formatearHora(TimeOfDay.now());
  }

  String _formatearHora(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  void _guardar(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final registro = BitacoraEntidad(
        id: widget.registroExistente?.id,
        titulo: _tituloCtrl.text,
        actividad: _actividadCtrl.text,
        observaciones: _observacionesCtrl.text,
        categoria: _categoria,
        grado_y_grupo: _gradoYGCtrl.text.isNotEmpty ? _gradoYGCtrl.text : null,
        hora: _hora,
        fecha:
            widget.registroExistente?.fecha ??
            "${widget.fechaSeleccionada.year}-${widget.fechaSeleccionada.month.toString().padLeft(2, '0')}-${widget.fechaSeleccionada.day.toString().padLeft(2, '0')}",
      );
      context.read<BitacoraCrearEditarCubit>().procesarRegistro(registro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.registroExistente != null;

    return BlocProvider(
      create: (_) => sl<BitacoraCrearEditarCubit>(),
      child: BlocListener<BitacoraCrearEditarCubit, BitacoraCrearEditarState>(
        listener: (context, state) {
          if (state.status == FormStatus.exito) {
            Navigator.pop(context, true);
          }
          if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensajeError ?? "Error"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              appBar: AppBar(
                title: Text(
                  isEdit ? "Editar Registro" : "Nuevo Registro de Bitácora",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                backgroundColor: zacTinto,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSeccionTitulo("INFORMACIÓN DEL REGISTRO"),
                      _cardWrapper([
                        _customField(
                          _tituloCtrl,
                          "Título de la actividad",
                          Icons.title,
                          "Ej. Clase de Matemáticas",
                        ),
                        _gradoYGrupoField(),
                        _buildDropdown(),
                        const SizedBox(height: 12),
                        _customField(
                          _actividadCtrl,
                          "Descripción / Actividad",
                          Icons.description,
                          "Detalle lo sucedido...",
                          maxLines: 4,
                        ),
                        _customField(
                          _observacionesCtrl,
                          "Observaciones",
                          Icons.comment,
                          "Notas adicionales...",
                          maxLines: 2,
                        ),
                      ]),
                      const SizedBox(
                        height: 100,
                      ), // Espacio para el botón flotante
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: _buildBotonGuardar(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
      child: Text(
        titulo,
        style: TextStyle(
          color: zacTinto.withOpacity(0.8),
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _cardWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _customField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) && label != "Observaciones"
            ? "Campo requerido"
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          prefixIcon: Icon(icon, size: 20, color: zacTinto.withOpacity(0.6)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _categoria,
        items: [
          "Clases",
          "Incidencias",
          "Evaluaciones",
          "Otros",
        ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => _categoria = val!),
        decoration: InputDecoration(
          labelText: "Categoría",
          prefixIcon: Icon(
            Icons.category,
            size: 20,
            color: zacTinto.withOpacity(0.6),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildBotonGuardar(context) {
    return BlocBuilder<BitacoraCrearEditarCubit, BitacoraCrearEditarState>(
      builder: (context, state) {
        return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: state.status == FormStatus.cargando
                ? null
                : () => _guardar(context),
            icon: state.status == FormStatus.cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              state.status == FormStatus.cargando
                  ? "GUARDANDO..."
                  : "GUARDAR REGISTRO",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: zacTinto,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _gradoYGrupoField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _gradoYGCtrl,
        decoration: InputDecoration(
          labelText: "Grado y Grupo (opcional)",
          prefixIcon: Icon(
            Icons.school,
            size: 20,
            color: Color(0xFF8B1D1D).withOpacity(0.6),
          ),
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}
