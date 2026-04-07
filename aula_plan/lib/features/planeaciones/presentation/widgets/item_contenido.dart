import 'package:flutter/material.dart';
import 'contenido_service.dart';

class ItemContenidoCard extends StatelessWidget {
  final ContenidoBusqueda item;
  final List<String> seleccionados;
  final Color colorTema;
  final Function(String pda, bool seleccionado) onToggle;

  const ItemContenidoCard({
    super.key,
    required this.item,
    required this.seleccionados,
    required this.colorTema,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final int seleccionadosCount = seleccionados.length;
    final bool tieneSeleccionados = seleccionadosCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: tieneSeleccionados ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tieneSeleccionados ? colorTema.withOpacity(0.5) : Colors.transparent,
        ),
      ),
      child: ExpansionTile(
        key: PageStorageKey(item.titulo),
        title: Text(
          item.titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: tieneSeleccionados ? FontWeight.bold : FontWeight.w500,
            color: tieneSeleccionados ? colorTema : Colors.black87,
          ),
        ),
        subtitle: Text(
          "$seleccionadosCount de ${item.pdas.length} PDAs seleccionados",
          style: TextStyle(
            fontSize: 12,
            color: tieneSeleccionados ? colorTema : Colors.grey.shade600,
          ),
        ),
        children: item.pdas.map((pda) {
          final bool esSeleccionado = seleccionados.contains(pda);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: esSeleccionado ? colorTema.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: esSeleccionado ? colorTema.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: true,
              activeColor: colorTema,
              title: Text(
                pda,
                style: TextStyle(
                  fontSize: 13,
                  color: esSeleccionado ? colorTema : Colors.black87,
                  fontWeight: esSeleccionado ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              value: esSeleccionado,
              onChanged: (val) => onToggle(pda, val ?? false),
            ),
          );
        }).toList(),
      ),
    );
  }
}