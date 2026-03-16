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
    Color colorCat = const Color(0xFF10B981);
    if (registro.categoria == "Clases") colorCat = const Color(0xFF10B981);
    if (registro.categoria == "Incidencias") colorCat = const Color(0xFFEF4444);
    if (registro.categoria == "Evaluaciones") colorCat = const Color(0xFFF59E0B);
    if (registro.categoria == "Otros") colorCat = const Color.fromARGB(255, 54, 53, 52);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: colorCat, width: 5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(registro.hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(registro.categoria.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorCat)),
                  Text(registro.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(registro.actividad, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  Text(registro.observaciones, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                estaSeleccionado ? Icons.check_box : Icons.check_box_outline_blank,
                color: estaSeleccionado ? const Color(0xFF6366F1) : Colors.grey,
              ),
              onPressed: onToggleSeleccion,
            ),
          ],
        ),
      ),
    );
  }
}
