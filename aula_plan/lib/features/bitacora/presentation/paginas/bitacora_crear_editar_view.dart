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
  late TextEditingController _horaCtrl; // Controlador para manejar la hora editable
  late String _categoria;

  @override
  void initState() {
    super.initState();
    final r = widget.registroExistente;
    _tituloCtrl = TextEditingController(text: r?.titulo ?? "");
    _actividadCtrl = TextEditingController(text: r?.actividad ?? "");
    _observacionesCtrl = TextEditingController(text: r?.observaciones ?? "");
    _gradoYGCtrl = TextEditingController(text: r?.grado_y_grupo ?? "");
    _categoria = r?.categoria ?? "Clases";
    
    // Si viene nulo se queda vacío sin autocompletar la hora actual
    _horaCtrl = TextEditingController(text: r?.hora ?? "");
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _actividadCtrl.dispose();
    _observacionesCtrl.dispose();
    _gradoYGCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  String _formatearHora(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  // Método para abrir el selector de hora nativo
  Future<void> _seleccionarHora(BuildContext context) async {
    TimeOfDay horaInicial = TimeOfDay.now();
    try {
      final partes = _horaCtrl.text.split(':');
      if (partes.length == 2) {
        horaInicial = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
      }
    } catch (_) {}

    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: zacTinto, // Color de cabecera
              onPrimary: Colors.white,
              onSurface: Colors.black, // Color del texto
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
        );
      },
    );

    if (horaSeleccionada != null) {
      setState(() {
        _horaCtrl.text = _formatearHora(horaSeleccionada);
      });
    }
  }

  void _guardar(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final registro = BitacoraEntidad(
        id: widget.registroExistente?.id,
        titulo: _tituloCtrl.text,
        actividad: _actividadCtrl.text,
        observaciones: _observacionesCtrl.text.isNotEmpty ? _observacionesCtrl.text : "",
        categoria: _categoria,
        grado_y_grupo: _gradoYGCtrl.text.isNotEmpty ? _gradoYGCtrl.text : null,
        
        hora: _horaCtrl.text.isNotEmpty ? _horaCtrl.text : "", 
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
                        _horaField(context), 
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
                          "Observaciones (opcional)",
                          Icons.comment,
                          "Notas adicionales...",
                          maxLines: 2,
                        ),
                      ]),
                      const SizedBox(
                        height: 100,
                      ),
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
        validator: (v) {
          if (label.startsWith("Observaciones")) return null;
          if (v == null || v.isEmpty) return "Campo requerido";
          return null;
        },
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
          "Reuniones",
          "Acompañamiento Padres",
          "Acompañamiento Maestros",
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

  Widget _horaField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _horaCtrl,
        readOnly: true,
        onTap: () => _seleccionarHora(context),
        validator: (v) => null, 
        decoration: InputDecoration(
          labelText: "Hora del registro (opcional)", 
          prefixIcon: Icon(
            Icons.access_time,
            size: 20,
            color: zacTinto.withOpacity(0.6),
          ),
          suffixIcon: _horaCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    // El setState garantiza que el botón "X" desaparezca inmediatamente al borrar
                    setState(() {
                      _horaCtrl.clear();
                    });
                  },
                )
              : null,
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
            color: const Color(0xFF8B1D1D).withOpacity(0.6),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}