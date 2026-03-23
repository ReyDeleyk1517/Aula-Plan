import 'package:flutter/material.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';

class PlaneacionCard extends StatelessWidget {
  final PlaneacionEntidad planeacion;
  final VoidCallback onTap;

  const PlaneacionCard({Key? key, required this.planeacion, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(planeacion.nombreProyecto,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${planeacion.nombreEscuela} • Ciclo ${planeacion.cicloEscolar}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Grupo: ${planeacion.grupo}  |  Nivel: ${planeacion.nivelEducativo}',
                style: const TextStyle(color: Colors.black87)),
          ]),
        ),
      ),
    );
  }
}
