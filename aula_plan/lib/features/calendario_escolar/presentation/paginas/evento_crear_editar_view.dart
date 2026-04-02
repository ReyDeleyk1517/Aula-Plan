import 'package:aula_plan/core/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/evento_entidad.dart';
import '../bloc/evento_crear_editar_cubit.dart';

class EventoCrearEditarView extends StatefulWidget {
  final EventoEntidad? registroExistente;
  final DateTime fechaSeleccionada;

  const EventoCrearEditarView({
    super.key,
    this.registroExistente,
    required this.fechaSeleccionada,
  });

  @override
  State<EventoCrearEditarView> createState() => _EventoCrearEditarViewState();
}

class _EventoCrearEditarViewState extends State<EventoCrearEditarView> {
  final _formKey = GlobalKey<FormState>();
  final Color zacTinto = const Color(0xFF8B1D1D);

  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _lugarCtrl;
  late String _tipoEvento;
  late String _fechaInicio;
  late String _fechaFin;

  @override
  void initState() {
    super.initState();
    final e = widget.registroExistente;

    _tituloCtrl = TextEditingController(text: e?.titulo ?? "");
    _descripcionCtrl = TextEditingController(text: e?.descripcion ?? "");
    _lugarCtrl = TextEditingController(text: e?.lugar ?? "");
    _tipoEvento = e?.tipo_evento ?? "Académico";
    
    // Si es nuevo, usamos la fecha seleccionada en el calendario
    // Si es edición, usamos las fechas del objeto
    _fechaInicio = e?.fecha_inicio ?? _formatDateTime(widget.fechaSeleccionada);
    _fechaFin = e?.fecha_fin ?? _formatDateTime(widget.fechaSeleccionada);
  }

  String _formatDateTime(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime fechaInicial = DateTime.parse(esInicio ? _fechaInicio : _fechaFin);
    
    final DateTime? seleccionado = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: zacTinto,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionado != null) {
      setState(() {
        String fechaFormateada = _formatDateTime(seleccionado);
        if (esInicio) {
          _fechaInicio = fechaFormateada;
          // Validación simple: si la fecha fin es menor a la nueva fecha inicio, las igualamos
          if (DateTime.parse(_fechaFin).isBefore(seleccionado)) {
            _fechaFin = fechaFormateada;
          }
        } else {
          _fechaFin = fechaFormateada;
        }
      });
    }
  }

  void _guardar(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Validación lógica de fechas
      if (DateTime.parse(_fechaFin).isBefore(DateTime.parse(_fechaInicio))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La fecha de fin no puede ser anterior a la de inicio")),
        );
        return;
      }

      final evento = EventoEntidad(
        id: widget.registroExistente?.id,
        titulo: _tituloCtrl.text,
        descripcion: _descripcionCtrl.text,
        fecha_inicio: _fechaInicio,
        fecha_fin: _fechaFin,
        tipo_evento: _tipoEvento,
        lugar: _lugarCtrl.text,
        perfilId: widget.registroExistente?.perfilId,
      );

      context.read<EventoCrearEditarCubit>().procesarEvento(evento);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.registroExistente != null;

    return BlocProvider(
      create: (_) => sl<EventoCrearEditarCubit>(),
      child: BlocListener<EventoCrearEditarCubit, EventoCrearEditarState>(
        listener: (context, state) {
          if (state.status == FormStatus.exito) {
            Navigator.pop(context, true);
          }
          if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensajeError ?? "Error"), backgroundColor: Colors.red),
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              appBar: AppBar(
                title: Text(isEdit ? "Editar Evento" : "Nuevo Evento",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                      _buildSeccionTitulo("DETALLES DEL EVENTO"),
                      _cardWrapper([
                        _customField(_tituloCtrl, "Título del evento", Icons.event, "Ej. Reunión de Consejo"),
                        _buildDropdownTipo(),
                        _customField(_lugarCtrl, "Lugar", Icons.location_on, "Ej. Auditorio Principal"),
                        const SizedBox(height: 12),
                        _customField(_descripcionCtrl, "Descripción", Icons.notes, "Detalles adicionales...", maxLines: 4),
                      ]),
                      const SizedBox(height: 20),
                      _buildSeccionTitulo("VIGENCIA"),
                      _cardWrapper([
                        _buildPickerFecha(
                          context: context,
                          titulo: "Fecha Inicio",
                          fecha: _fechaInicio,
                          icono: Icons.calendar_today,
                          onTap: () => _seleccionarFecha(context, true),
                        ),
                        const Divider(),
                        _buildPickerFecha(
                          context: context,
                          titulo: "Fecha Fin",
                          fecha: _fechaFin,
                          icono: Icons.calendar_month,
                          onTap: () => _seleccionarFecha(context, false),
                        ),
                      ]),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: _buildBotonGuardar(context),
            );
          },
        ),
      ),
    );
  }

  // --- Widgets de Apoyo ---

  Widget _buildPickerFecha({
    required BuildContext context,
    required String titulo,
    required String fecha,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icono, color: zacTinto),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(fecha, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_calendar, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
      child: Text(titulo,
          style: TextStyle(
              color: zacTinto.withOpacity(0.8),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.1)),
    );
  }

  Widget _cardWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _customField(TextEditingController ctrl, String label, IconData icon, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) ? "Campo requerido" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          prefixIcon: Icon(icon, size: 20, color: zacTinto.withOpacity(0.6)),
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildDropdownTipo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _tipoEvento,
        // Lista completa de tipos de eventos
        items: ["Académico", "Cívico", "Social", "Urgente", "Otros"]
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (val) => setState(() => _tipoEvento = val!),
        decoration: InputDecoration(
          labelText: "Tipo de Evento",
          prefixIcon: Icon(Icons.category, size: 20, color: zacTinto.withOpacity(0.6)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        ),
      ),
    );
  }

  Widget _buildBotonGuardar(BuildContext context) {
    return BlocBuilder<EventoCrearEditarCubit, EventoCrearEditarState>(
      builder: (context, state) {
        return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: state.status == FormStatus.cargando ? null : () => _guardar(context),
            icon: state.status == FormStatus.cargando
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            label: Text(state.status == FormStatus.cargando ? "GUARDANDO..." : "GUARDAR EVENTO",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: zacTinto,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
            ),
          ),
        );
      },
    );
  }
}