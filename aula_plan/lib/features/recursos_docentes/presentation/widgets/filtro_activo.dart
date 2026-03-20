import 'package:flutter/material.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';

class FiltroActivo extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const FiltroActivo({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}
