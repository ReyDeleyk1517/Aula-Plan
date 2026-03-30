import 'package:flutter/material.dart';

class ActividadesWidget extends StatefulWidget {
  final List<Map<String, String>> initial;
  final Function(List<Map<String, String>>) onChanged;

  const ActividadesWidget({
    Key? key,
    required this.initial,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ActividadesWidget> createState() => _ActividadesWidgetState();
}

class _ActividadesWidgetState extends State<ActividadesWidget> {
  // Lista de mapas de controladores para que cada campo sea independiente
  late List<Map<String, TextEditingController>> _controllers;
  final Color zacTinto = const Color(0xFF8B1D1D);

  // DENTRO DE _ActividadesWidgetState en actividades_widget.dart

  @override
  void initState() {
    super.initState();
    _controllers = widget.initial.map((act) {
      return {
        'titulo': TextEditingController(text: act['titulo']),
        'descripcion': TextEditingController(text: act['descripcion']),
        'materiales': TextEditingController(text: act['materiales']),
      };
    }).toList();

    if (_controllers.isEmpty) {
      Future.microtask(() => _agregarNuevaActividad());
    }
  }

  void _agregarNuevaActividad() {
    setState(() {
      _controllers.add({
        'titulo': TextEditingController(),
        'descripcion': TextEditingController(),
        'materiales': TextEditingController(),
      });
    });
    _notificarCambios();
  }

  void _eliminarActividad(int index) {
    setState(() {
      _controllers[index].forEach((key, ctrl) => ctrl.dispose());
      _controllers.removeAt(index);
    });
    _notificarCambios();
  }

  void _notificarCambios() {
    final datos = _controllers
        .map(
          (c) => {
            'titulo': c['titulo']!.text,
            'descripcion': c['descripcion']!.text,
            'materiales': c['materiales']!.text,
          },
        )
        .toList();
    widget.onChanged(datos);
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.forEach((key, ctrl) => ctrl.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._controllers.asMap().entries.map((entry) {
          int idx = entry.key;
          var ctrls = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Column(
              children: [
                // Cabecera de la actividad
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 18,
                            color: Colors.orange.shade900,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "ACTIVIDAD #${idx + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (_controllers.length > 1)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _eliminarActividad(idx),
                        ),
                    ],
                  ),
                ),
                // Campos de la Fase (Similares al resto de la planeación)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _actividadTextField(
                        ctrls['titulo']!,
                        "Título de la Actividad",
                        Icons.title,
                        "Ej. Inicio del proyecto",
                      ),
                      _actividadTextField(
                        ctrls['descripcion']!,
                        "Desarrollo / Actividades",
                        Icons.play_arrow,
                        "Describa el paso a paso...",
                        maxLines: 3,
                      ),
                      _actividadTextField(
                        ctrls['materiales']!,
                        "Materiales y Recursos",
                        Icons.inventory_2,
                        "Hojas, proyector, etc.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Botón para añadir más, con el estilo del mockup
        TextButton.icon(
          onPressed: _agregarNuevaActividad,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text(
            "AGREGAR OTRA ACTIVIDAD",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange.shade900,
            backgroundColor: Colors.orange.shade100.withOpacity(0.4),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actividadTextField(
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
        onChanged: (_) =>
            _notificarCambios(), // Sincroniza con el padre en cada tecla
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: zacTinto.withOpacity(0.6)),
          hintText: hint,
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
}
