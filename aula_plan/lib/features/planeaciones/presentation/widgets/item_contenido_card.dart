import 'package:flutter/material.dart';
import 'contenido_service.dart';
import 'contenido_model.dart';

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
    final bool tieneSeleccionados = seleccionados.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: tieneSeleccionados ? 4 : 1,
      child: ExpansionTile(
        leading: item.numero != null 
          ? CircleAvatar(
              backgroundColor: colorTema.withOpacity(0.1),
              radius: 16,
              child: Text(
                item.numero!, 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorTema),
              ),
            )
          : null,
        title: Text(
          item.titulo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: tieneSeleccionados ? FontWeight.bold : FontWeight.w500,
            color: tieneSeleccionados ? colorTema : Colors.black87,
          ),
        ),
        subtitle: Text("${seleccionados.length} de ${item.pdas.length} seleccionados", style: const TextStyle(fontSize: 11)),
        children: item.pdas.map((pda) {
          final bool esSel = seleccionados.contains(pda);
          return CheckboxListTile(
            title: Text(pda, style: const TextStyle(fontSize: 12)),
            value: esSel,
            activeColor: colorTema,
            onChanged: (val) => onToggle(pda, val ?? false),
          );
        }).toList(),
      ),
    );
  }
}