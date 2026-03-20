import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/opciones_filtrado.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';

class ModalFiltros extends StatelessWidget {
  const ModalFiltros();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
        builder: (context, state) {
          final cubit = context.read<RecursosDocenteCubit>();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))
                ),
              ),
              const SizedBox(height: 20),
              const Text("Filtrar Recursos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 15),
              OpcionesFiltrado(
                label: "Áreas",
                options: const ['Todas', 'Psicología', 'Comunicacion', 'Trabajo Social', 'Pedagogía'],
                selectedValue: state.filtroArea,
                onSelected: (val) => cubit.cambiarFiltroArea(val),
              ),
              OpcionesFiltrado(
                label: "Campos Formativos",
                options: const ['Todos', 'Lenguajes', 'Saberes y pensamiento cientifico', 'De lo Humano y comunitario', 'Etica Naturaleza y sociedad'],
                selectedValue: state.filtroCampo,
                onSelected: (val) => cubit.cambiarFiltroCampo(val),
              ),
              OpcionesFiltrado(
                label: "Tipo de Archivo",
                options: const ['Todos', 'PDF', 'Imagen', 'Video', 'Otros'],
                selectedValue: state.filtroTipo,
                onSelected: (val) => cubit.cambiarFiltroTipo(val),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Aplicar Filtros", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
