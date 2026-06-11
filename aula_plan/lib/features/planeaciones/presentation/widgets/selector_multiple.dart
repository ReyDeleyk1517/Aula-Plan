import 'package:flutter/material.dart';

class MultiSelectField extends StatelessWidget {
  final String titulo;
  final List<String> opciones;
  final List<String> seleccionados;
  final ValueChanged<List<String>> onChanged;
  final Color color;

  const MultiSelectField({
    super.key,
    required this.titulo,
    required this.opciones,
    required this.seleccionados,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 8,
          ),
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(.8),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withOpacity(.05),
            ),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opciones.map((opcion) {
              final selected =
                  seleccionados.contains(opcion);

              return _ChipSeleccion(
                label: opcion,
                selected: selected,
                color: color,
                onTap: () {
                  final nuevaLista =
                      List<String>.from(
                        seleccionados,
                      );

                  if (selected) {
                    nuevaLista.remove(opcion);
                  } else {
                    nuevaLista.add(opcion);
                  }

                  onChanged(nuevaLista);
                },
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _ChipSeleccion extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _ChipSeleccion({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              selected ? color : Colors.white,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color
                : color.withOpacity(.2),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(
                      .3,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
              size: 16,
              color: selected
                  ? Colors.white
                  : color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : color,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}