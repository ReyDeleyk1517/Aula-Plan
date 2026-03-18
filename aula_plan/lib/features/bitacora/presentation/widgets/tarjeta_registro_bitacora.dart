import 'package:flutter/material.dart';
import '../../domain/entidades/bitacora_entidad.dart';

class TarjetaRegistroBitacora extends StatelessWidget {
  final BitacoraEntidad registro;
  final VoidCallback? onTap;
  final bool estaSeleccionado;
  final VoidCallback onToggleSeleccion;

  const TarjetaRegistroBitacora({
    super.key,
    required this.registro,
    this.onTap,
    required this.estaSeleccionado,
    required this.onToggleSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    // Definición de colores e iconos por categoría
    Color colorCat;
    IconData iconoCat;

    switch (registro.categoria) {
      case "Clases":
        colorCat = const Color(0xFF10B981);
        iconoCat = Icons.school_outlined;
        break;
      case "Incidencias":
        colorCat = const Color(0xFFEF4444);
        iconoCat = Icons.report_problem_outlined;
        break;
      case "Evaluaciones":
        colorCat = const Color(0xFFF59E0B);
        iconoCat = Icons.assignment_turned_in_outlined;
        break;
      default:
        colorCat = const Color(0xFF64748B);
        iconoCat = Icons.bookmark_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: colorCat, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de Hora
              Column(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(height: 4),
                  Text(
                    registro.hora,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Contenido Principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Categoría
                    Row(
                      children: [
                        Icon(iconoCat, size: 14, color: colorCat),
                        const SizedBox(width: 4),
                        Text(
                          registro.categoria.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorCat,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Título
                    Text(
                      registro.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.5),

                    // Subtítulos con Iconos
                    _buildInfoRow(
                      icon: Icons.text_fields,
                      label: "Actividad:",
                      value: registro.actividad,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.comment_outlined,
                      label: "Obs:",
                      value: registro.observaciones,
                    ),
                  ],
                ),
              ),

              // Botón de Selección
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  estaSeleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: estaSeleccionado ? const Color(0xFF6366F1) : Colors.grey.shade400,
                  size: 28,
                ),
                onPressed: onToggleSeleccion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las filas de información con subtítulo e icono
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}