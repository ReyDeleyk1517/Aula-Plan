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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Planeaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildActiveFiltersArea(),
            const Expanded(child: _RecursosList()),
          ],
        ),
      ),
      floatingActionButton:
          BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
            builder: (context, state) {
              if (state.seleccionadosIds.isNotEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'zip',
                      onPressed: () =>
                          context.read<RecursosDocenteCubit>().exportarAZip(),
                      label: Text(
                        'Exportar ZIP (${state.seleccionadosIds.length})',
                      ),
                      icon: const Icon(Icons.share),
                      backgroundColor: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'delete',
                      onPressed: () => _confirmarEliminacion(context),
                      label: Text(
                        'Eliminar (${state.seleccionadosIds.length})',
                      ),
                      icon: const Icon(Icons.delete),
                      backgroundColor: Colors.red,
                    ),
                  ],
                );
              }

              return FloatingActionButton(
                heroTag: 'btn_add',
                backgroundColor: AppColors.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecursoAgregarEditarView(),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              );
            },
          ),
    );
  }

  // barra de búsqueda
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), 
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  context.read<RecursosDocenteCubit>().actualizarBusqueda(val),
              decoration: InputDecoration(
                hintText: 'Buscar material o autor...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F5F9), // El gris de planeaciones
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () => _mostrarModalFiltros(context),
            icon: const Icon(Icons.tune, color: AppColors.primary),
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
          chips.add(
            _buildFilterChip(
              state.filtroArea,
              () => cubit.cambiarFiltroArea('Todas'),
            ),
          );
        }
        if (state.filtroCampo != 'Todos') {
          chips.add(
            _buildFilterChip(
              state.filtroCampo,
              () => cubit.cambiarFiltroCampo('Todos'),
            ),
          );
        }
        if (state.filtroTipo != 'Todos') {
          chips.add(
            _buildFilterChip(
              state.filtroTipo,
              () => cubit.cambiarFiltroTipo('Todos'),
            ),
          );
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        return Container(
          color: AppColors.white,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: chips
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: c,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return InputChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
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
    final seleccionados = context
        .read<RecursosDocenteCubit>()
        .state
        .seleccionadosIds;
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('Eliminar recursos'),
        content: Text(
          '¿Eliminar ${seleccionados.length} recursos seleccionados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final cubit = context.read<RecursosDocenteCubit>();
              for (var id in seleccionados) {
                cubit.eliminarRecurso(id);
              }
              Navigator.pop(innerContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
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
        if (state.cargando)
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        final items = state.recursosFiltrados;
        if (items.isEmpty)
          return const Center(
            child: Text(
              "Sin resultados",
              style: TextStyle(color: AppColors.textLight),
            ),
          );
        return ListView.builder(
          padding: const EdgeInsets.only(top: 15, bottom: 80),
          itemCount: items.length,
          itemBuilder: (context, index) => RecursoCard(recurso: items[index]),
        );
      },
    );
  }
}
