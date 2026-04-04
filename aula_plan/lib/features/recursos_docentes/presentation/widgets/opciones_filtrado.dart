import 'package:flutter/material.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';

class OpcionesFiltrado extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final Function(String) onSelected;

  const OpcionesFiltrado({
    required this.label, 
    required this.options, 
    required this.selectedValue, 
    required this.onSelected
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label.toUpperCase(), 
            style: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              color: AppColors.textLight
            )
          ),
        ),
        Wrap(
          spacing: 8.0, 
          runSpacing: 0.0, 
          children: options.map((opt) {
            final isSelected = opt == selectedValue;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 11, 
                color: isSelected ? Colors.white : AppColors.textDark
              ),
              showCheckmark: false,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16), 
      ],
    );
  }
}