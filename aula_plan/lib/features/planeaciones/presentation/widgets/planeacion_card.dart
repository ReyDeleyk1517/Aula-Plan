import 'package:flutter/material.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';

class PlaneacionCard extends StatelessWidget {
  final PlaneacionEntidad planeacion;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onSelected;

  const PlaneacionCard({
    Key? key,
    required this.planeacion,
    required this.onTap,
    this.selected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color colorInstitucional = Color(0xFF800020); 

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      elevation: selected ? 4 : 1, // Más elevación si está seleccionada
      // Cambiamos el color de fondo si está seleccionada
      color: selected ? const Color(0xFFE0E7FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? const Color(0xFF6366F1) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onSelected, // También permite seleccionar con long press
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: selected ? const Color(0xFF6366F1) : colorInstitucional, 
                width: 6
              )
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(height: 4),
                  Text(
                    planeacion.cicloEscolar,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planeacion.nivelEducativo.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorInstitucional,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      planeacion.nombreProyecto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMiniInfo(Icons.school_outlined, "Escuela: ", planeacion.nombreEscuela),
                    const SizedBox(height: 6),
                    _buildMiniInfo(Icons.groups_outlined, "Grupo: ", planeacion.grupo),
                  ],
                ),
              ),
              // Checkbox de selección con animación de color
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                  size: 26,
                ),
                onPressed: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              children: [
                TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}