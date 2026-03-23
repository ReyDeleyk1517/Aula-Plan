import 'package:flutter/material.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';

class FasePlaneacionWidget extends StatefulWidget {
  final int index;
  final FasePlaneacionEntidad? fase;
  final void Function(FasePlaneacionEntidad) onChanged;
  // accion para eliminar esta fase
  final void Function(int index)? onDelete;

  const FasePlaneacionWidget({
    Key? key,
    required this.index,
    this.fase,
    required this.onChanged,
    this.onDelete,
  }) : super(key: key);

  @override
  _FasePlaneacionWidgetState createState() => _FasePlaneacionWidgetState();
}

class _FasePlaneacionWidgetState extends State<FasePlaneacionWidget> {
  late TextEditingController _fasesDesarrolloCtrl;
  late TextEditingController _actividadesCtrl;
  late TextEditingController _materialesCtrl;
  late TextEditingController _organizacionCtrl;
  late TextEditingController _espacioCtrl;
  late TextEditingController _tiempoCtrl;
  late TextEditingController _responsablesCtrl;
  late TextEditingController _indicadoresCtrl;
  late TextEditingController _instrumentosCtrl;

  @override
  void initState() {
    super.initState();
    final f = widget.fase;
    _fasesDesarrolloCtrl = TextEditingController(text: f?.fasesDesarrollo ?? '');
    _actividadesCtrl = TextEditingController(text: f?.actividades ?? '');
    _materialesCtrl = TextEditingController(text: f?.materialesRecursos ?? '');
    _organizacionCtrl = TextEditingController(text: f?.organizacionGrupo ?? '');
    _espacioCtrl = TextEditingController(text: f?.espacio ?? '');
    _tiempoCtrl = TextEditingController(text: f?.tiempo ?? '');
    _responsablesCtrl = TextEditingController(text: f?.responsables ?? '');
    _indicadoresCtrl = TextEditingController(text: f?.evaluacionIndicadores ?? '');
    _instrumentosCtrl = TextEditingController(text: f?.evaluacionInstrumentos ?? '');

    // notificar initial state si ya hay datos
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  @override
  void dispose() {
    _fasesDesarrolloCtrl.dispose();
    _actividadesCtrl.dispose();
    _materialesCtrl.dispose();
    _organizacionCtrl.dispose();
    _espacioCtrl.dispose();
    _tiempoCtrl.dispose();
    _responsablesCtrl.dispose();
    _indicadoresCtrl.dispose();
    _instrumentosCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final fase = FasePlaneacionEntidad(
      id: widget.fase?.id,
      idPlaneacion: widget.fase?.idPlaneacion,
      fasesDesarrollo: _fasesDesarrolloCtrl.text,
      actividades: _actividadesCtrl.text,
      materialesRecursos: _materialesCtrl.text,
      organizacionGrupo: _organizacionCtrl.text,
      espacio: _espacioCtrl.text,
      tiempo: _tiempoCtrl.text,
      responsables: _responsablesCtrl.text,
      evaluacionIndicadores: _indicadoresCtrl.text,
      evaluacionInstrumentos: _instrumentosCtrl.text,
    );
    widget.onChanged(fase);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // opción de eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fase ${widget.index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.onDelete?.call(widget.index - 1);
                    },
                    tooltip: 'Eliminar fase',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fasesDesarrolloCtrl,
              decoration: const InputDecoration(labelText: 'Fases Desarrollo'),
              onChanged: (_) => _notifyChange(),
            ),
            TextFormField(
              controller: _actividadesCtrl,
              decoration: const InputDecoration(labelText: 'Actividades'),
              onChanged: (_) => _notifyChange(),
            ),
            TextFormField(
              controller: _materialesCtrl,
              decoration: const InputDecoration(labelText: 'Materiales/Recursos'),
              onChanged: (_) => _notifyChange(),
            ),
            TextFormField(
              controller: _organizacionCtrl,
              decoration: const InputDecoration(labelText: 'Organización Grupo'),
              onChanged: (_) => _notifyChange(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _espacioCtrl,
                    decoration: const InputDecoration(labelText: 'Espacio'),
                    onChanged: (_) => _notifyChange(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _tiempoCtrl,
                    decoration: const InputDecoration(labelText: 'Tiempo'),
                    onChanged: (_) => _notifyChange(),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _responsablesCtrl,
              decoration: const InputDecoration(labelText: 'Responsables'),
              onChanged: (_) => _notifyChange(),
            ),
            TextFormField(
              controller: _indicadoresCtrl,
              decoration: const InputDecoration(labelText: 'Indicadores de Evaluación'),
              onChanged: (_) => _notifyChange(),
            ),
            TextFormField(
              controller: _instrumentosCtrl,
              decoration: const InputDecoration(labelText: 'Instrumentos de Evaluación'),
              onChanged: (_) => _notifyChange(),
            ),
          ],
        ),
      ),
    );
  }
}
