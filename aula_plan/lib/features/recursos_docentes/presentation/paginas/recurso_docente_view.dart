import 'package:aula_plan/features/recursos_docentes/presentation/paginas/agregar_recurso_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entidades/recurso_docentes_entidad.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/recurso_card.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/modal_filtros.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/filtro_activo.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/tag.dart';


class RecursosDocenteScreen extends StatefulWidget {
  const RecursosDocenteScreen({super.key});

  @override
  State<RecursosDocenteScreen> createState() => _RecursosDocenteScreenState();
}

class _RecursosDocenteScreenState extends State<RecursosDocenteScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecursosDocenteCubit>().cargarRecursos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildActiveFiltersArea(), 
            const Expanded(child: _RecursosList()),
          ],
        ),
      ),
  floatingActionButton: BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
        builder: (context, state) {
          final tieneSeleccion = state.seleccionadosIds.isNotEmpty;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (tieneSeleccion) ...[
                FloatingActionButton.small(
                  heroTag: 'btn_delete',
                  backgroundColor: Colors.redAccent,
                  onPressed: () {
                    // borrar multiples
                    for (var id in state.seleccionadosIds) {
                      context.read<RecursosDocenteCubit>().eliminarRecurso(id);
                    }
                  },
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: 'btn_share',
                  backgroundColor: AppColors.accent,
                  onPressed: () => context.read<RecursosDocenteCubit>().exportarAZip(),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton(
                heroTag: 'btn_add',
                backgroundColor: AppColors.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgregarRecursoScreen()),
                ),
                child: Icon(tieneSeleccion ? Icons.close : Icons.add, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recursos docentes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: AppColors.primary),
                onPressed: () => _mostrarModalFiltros(context),
                tooltip: "Filtrar",
              )
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<RecursosDocenteCubit>().actualizarBusqueda(val),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                hintText: "Buscar material o autor...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersArea() {
    return BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
      builder: (context, state) {
        final cubit = context.read<RecursosDocenteCubit>();
        final List<Widget> chips = [];

        if (state.filtroArea != 'Todas') {
          chips.add(FiltroActivo(label: state.filtroArea, onDeleted: () => cubit.cambiarFiltroArea('Todas')));
        }
        if (state.filtroCampo != 'Todos') {
          chips.add(FiltroActivo(label: state.filtroCampo, onDeleted: () => cubit.cambiarFiltroCampo('Todos')));
        }
        if (state.filtroTipo != 'Todos') {
          chips.add(FiltroActivo(label: state.filtroTipo, onDeleted: () => cubit.cambiarFiltroTipo('Todos')));
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        return Container(
          color: AppColors.white,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: chips,
          ),
        );
      },
    );
  }

  void _mostrarModalFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalFiltros(),
    );
  }
}


class _RecursosList extends StatelessWidget {
  const _RecursosList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
      builder: (context, state) {
        if (state.cargando) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final items = state.recursosFiltrados;
        if (items.isEmpty) return const Center(child: Text("Sin resultados", style: TextStyle(color: AppColors.textLight)));
        return ListView.builder(
          padding: const EdgeInsets.only(top: 15, bottom: 80),
          itemCount: items.length,
          itemBuilder: (context, index) => RecursosCard(recurso: items[index]),
        );
      },
    );
  }
}
