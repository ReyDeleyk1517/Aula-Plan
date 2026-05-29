import 'package:flutter/material.dart';
import '../../domain/entidades/bitacora_entidad.dart';

class BitacoraCard extends StatelessWidget {
  final BitacoraEntidad registro;
  final VoidCallback? onTap;
  final bool estaSeleccionado;
  final VoidCallback onToggleSeleccion;
  final VoidCallback onEdit;

  const BitacoraCard({
    super.key,
    required this.registro,
    this.onTap,
    required this.estaSeleccionado,
    required this.onToggleSeleccion,
    required this.onEdit,
  });

  // Helper para centralizar la lógica de colores e iconos por categoría
  _CategoryStyle _getCategoryStyle(String categoria) {
    switch (categoria) {
      case "Clases":
        return const _CategoryStyle(Color(0xFF10B981), Icons.school_outlined);

      case "Incidencias":
        return const _CategoryStyle(
          Color(0xFFEF4444),
          Icons.report_problem_outlined,
        );

      case "Evaluaciones":
        return const _CategoryStyle(
          Color(0xFFF59E0B),
          Icons.assignment_turned_in_outlined,
        );

      case "Reuniones":
        return const _CategoryStyle(
          Color.fromARGB(255, 11, 210, 245),
          Icons.groups_outlined,
        );

      case "Acompañamiento Padres":
        return const _CategoryStyle(
          Color(0xFF8B5CF6),
          Icons.family_restroom_outlined,
        );

      case "Acompañamiento Maestros":
        return const _CategoryStyle(
          Color(0xFF3B82F6),
          Icons.support_agent_outlined,
        );

      default:
        return const _CategoryStyle(Color(0xFF64748B), Icons.bookmark_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(registro.categoria);

    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de color lateral corregido (No se desfasa en las esquinas)
                Container(width: 6, color: style.color),

                // Contenido de la Tarjeta
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna de Hora
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
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
                                  Icon(
                                    style.icon,
                                    size: 14,
                                    color: style.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    registro.categoria.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: style.color,
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
                        const SizedBox(width: 8),

                        // Columna de Acciones (Selección y Edición Condicional)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de Selección (Bolita)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                estaSeleccionado
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: estaSeleccionado
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade400,
                                size: 28,
                              ),
                              onPressed: onToggleSeleccion,
                            ),

                            // Oculta el espacio y el lápiz dinámicamente si está seleccionado
                            if (!estaSeleccionado) ...[
                              const SizedBox(height: 8),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF64748B),
                                  size: 24,
                                ),
                                onPressed: onEdit,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
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

class _CategoryStyle {
  final Color color;
  final IconData icon;
  const _CategoryStyle(this.color, this.icon);
}
