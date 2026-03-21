import 'package:aula_plan/features/recursos_docentes/presentation/paginas/recurso_agregar_editar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/recurso_card.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/modal_filtros.dart';


class RecursosDocenteView extends StatefulWidget {
  const RecursosDocenteView({super.key});

  @override
  State<RecursosDocenteView> createState() => _RecursosDocenteViewState();
}

class _RecursosDocenteViewState extends State<RecursosDocenteView> {
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
          // Si hay elementos seleccionados, mostramos acciones de exportar y eliminar, siguiendo el patrón de Bitácora
          if (state.seleccionadosIds.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'zip',
                  onPressed: () => context.read<RecursosDocenteCubit>().exportarAZip(),
                  label: Text('Exportar ZIP (${state.seleccionadosIds.length})'),
                  icon: const Icon(Icons.share),
                  backgroundColor: AppColors.accent,
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'delete',
                  onPressed: () => _confirmarEliminacion(context),
                  label: Text('Eliminar (${state.seleccionadosIds.length})'),
                  icon: const Icon(Icons.delete),
                  backgroundColor: Colors.red,
                ),
              ],
            );
          }

          // Botón principal para añadir recurso cuando no hay selección
          return FloatingActionButton(
            heroTag: 'btn_add',
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecursoAgregarEditarView()),
            ),
            child: Icon(Icons.add, color: Colors.white),
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
          chips.add(InputChip(
            label: Text(state.filtroArea, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            onDeleted: () => cubit.cambiarFiltroArea('Todas'),
            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary)),
          ));
        }
        if (state.filtroCampo != 'Todos') {
          chips.add(InputChip(
            label: Text(state.filtroCampo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            onDeleted: () => cubit.cambiarFiltroCampo('Todos'),
            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary)),
          ));
        }
        if (state.filtroTipo != 'Todos') {
          chips.add(InputChip(
            label: Text(state.filtroTipo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            onDeleted: () => cubit.cambiarFiltroTipo('Todos'),
            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary)),
          ));
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

  void _confirmarEliminacion(BuildContext context) {
    final seleccionados = context.read<RecursosDocenteCubit>().state.seleccionadosIds;
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('Eliminar recursos'),
        content: Text('¿Eliminar ${seleccionados.length} recursos seleccionados?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cubit = context.read<RecursosDocenteCubit>();
              for (var id in seleccionados) {
                cubit.eliminarRecurso(id);
              }
              Navigator.pop(innerContext);
            },
            child: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
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
          itemBuilder: (context, index) => RecursoCard(recurso: items[index]),
        );
      },
    );
  }
}
