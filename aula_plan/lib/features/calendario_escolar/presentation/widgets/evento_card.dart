import 'package:flutter/material.dart';
import '../../domain/entidades/evento_entidad.dart';

class EventoCard extends StatelessWidget {
  final EventoEntidad evento;
  final VoidCallback? onTap; // Para editar
  final bool estaSeleccionado;
  final VoidCallback onToggleSeleccion;

  const EventoCard({
    super.key,
    required this.evento,
    this.onTap,
    required this.estaSeleccionado,
    required this.onToggleSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    Color colorCat;
    IconData iconoCat;
    switch (evento.tipo_evento) {
      case "Académico":
        colorCat = const Color(0xFF3B82F6); 
        iconoCat = Icons.school_outlined;
        break;
      case "Cívico":
        colorCat = const Color(0xFF10B981);
        iconoCat = Icons.flag_outlined;
        break;
      case "Social":
        colorCat = const Color(0xFF8B5CF6);
        iconoCat = Icons.celebration_outlined;
        break;
      case "Urgente":
        colorCat = const Color(0xFFEF4444); 
        iconoCat = Icons.priority_high_rounded;
        break;
      case "Otros":
      default:
        colorCat = const Color(0xFF64748B); 
        iconoCat = Icons.more_horiz_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      elevation: estaSeleccionado ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: estaSeleccionado 
            ? const BorderSide(color: Color(0xFF6366F1), width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorCat.withOpacity(0.04), // Fondo sutil
            border: Border(left: BorderSide(color: colorCat, width: 6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Contenido Principal 
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(iconoCat, size: 14, color: colorCat),
                        const SizedBox(width: 6),
                        Text(
                          evento.tipo_evento.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: colorCat,
                            letterSpacing: 0.8
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: Color(0xFF1E293B)
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on_outlined, "Lugar:", evento.lugar),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.description_outlined, "Nota:", evento.descripcion),
                  ],
                ),
              ),
              // Selector lateral
              IconButton(
                icon: Icon(
                  estaSeleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: estaSeleccionado ? const Color(0xFF6366F1) : Colors.grey.shade400,
                  size: 26,
                ),
                onPressed: onToggleSeleccion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink(); 
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "$label $value",
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}