import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';

class Tag extends StatelessWidget {
  final String text;
  const Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(4)),
      child: Text(
        text.toUpperCase(), 
        style: const TextStyle(fontSize: 8, 
        fontWeight: FontWeight.bold, 
        color: AppColors.textLight,
        overflow: TextOverflow.ellipsis
      )),
    );
  }
}
