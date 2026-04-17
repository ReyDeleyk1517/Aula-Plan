import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_cubit.dart';
import 'package:aula_plan/features/planeaciones/presentation/widgets/planeacion_card.dart';
import 'package:aula_plan/features/planeaciones/presentation/paginas/planeacion_preview_pdf_view.dart';
import 'package:aula_plan/features/planeaciones/presentation/paginas/planeacion_crear_editar_view.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/injection_container.dart' as di;

class PlaneacionListView extends StatelessWidget {
  const PlaneacionListView({Key? key}) : super(key: key);


  Future<void> _irAPlaneacion(BuildContext context, {PlaneacionEntidad? planeacion}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaneacionCrearEditarView(
          planeacionExistente: planeacion,
        ),
      ),
    );

    // Si regresamos con un cambio exitoso, refrescamos la lista
    if (resultado == true) {
      if (context.mounted) {
        context.read<PlaneacionCubit>().cargarPlaneaciones();
      }
    }
  }

  //Construcción de la Interfaz 
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PlaneacionCubit>()..cargarPlaneaciones(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: const Text('Planeaciones', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildHeaderFiltros(),
            const Expanded(child: _PlaneacionListBuilder()),
          ],
        ),
        floatingActionButton: _BotonFlotanteDinamico(irAPlaneacion: _irAPlaneacion),
      ),
    );
  }

  Widget _buildHeaderFiltros() {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(child: _QuickSearchField()),
            const SizedBox(width: 12),
            _AdvancedFilterBtn(),
          ],
        ),
      );
    });
  }
}

class _PlaneacionListBuilder extends StatelessWidget {
  const _PlaneacionListBuilder();

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorWidgetOfExactType<PlaneacionListView>();

    return BlocBuilder<PlaneacionCubit, PlaneacionState>(
      builder: (context, estado) {
        if (estado.cargando) return const Center(child: CircularProgressIndicator());
        
        final lista = estado.planeacionesFiltradas;
        if (lista.isEmpty) return const Center(child: Text("Sin resultados"));

        return ListView.builder(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final p = lista[i];
            final esSeleccionado = estado.selectedPlaneacionIds.contains(p.id);

            return PlaneacionCard(
              planeacion: p,
              selected: esSeleccionado,
              onSelected: () => context.read<PlaneacionCubit>().toggleSeleccion(p.id!),
              onTap: () {
                if (estado.selectedPlaneacionIds.isNotEmpty) {
                  context.read<PlaneacionCubit>().toggleSeleccion(p.id!);
                } else {
                  parent?._irAPlaneacion(context, planeacion: p);
                }
              },
            );
          },
        );
      },
    );
  }
}

class _BotonFlotanteDinamico extends StatelessWidget {
  final Function(BuildContext, {PlaneacionEntidad? planeacion}) irAPlaneacion;
  
  const _BotonFlotanteDinamico({required this.irAPlaneacion});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaneacionCubit, PlaneacionState>(
      builder: (context, estado) {
        final seleccionados = estado.selectedPlaneacionIds;

        if (seleccionados.isNotEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // BOTÓN PDF: Solo si hay exactamente 1
              if (seleccionados.length == 1) ...[
                FloatingActionButton.extended(
                  heroTag: "fab_pdf",
                  onPressed: () {
                    final planeacion = estado.planeacionesFiltradas.firstWhere((p) => p.id == seleccionados.first);
                    _mostrarModalNombrePdf(context, planeacion);
                  },
                  label: const Text("Generar PDF"),
                  icon: const Icon(Icons.picture_as_pdf),
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 12),
              ],
              
              // BOTÓN BORRAR: 1 o mas
              FloatingActionButton.extended(
                heroTag: "fab_borrar",
                onPressed: () => _confirmarEliminacion(context),
                label: Text("Borrar (${seleccionados.length})"),
                icon: const Icon(Icons.delete),
                backgroundColor: Colors.red,
              ),
              const SizedBox(height: 12),

              // BOTÓN CERRAR SELECCIÓN
              FloatingActionButton(
                heroTag: "fab_cancelar",
                mini: true,
                onPressed: () => context.read<PlaneacionCubit>().limpiarSeleccion(),
                backgroundColor: Colors.grey,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          );
        }

        // Estado inicial: Botón Agregar
        return FloatingActionButton(
          backgroundColor: const Color(0xFF8B1D1D),
          onPressed: () => irAPlaneacion(context),
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("¿Eliminar planeaciones?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("Cancelar")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PlaneacionCubit>().eliminarSeleccionados();
              Navigator.pop(innerContext);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void _mostrarModalNombrePdf(BuildContext context, PlaneacionEntidad planeacion) {
    final TextEditingController _controller = TextEditingController(
      text: planeacion.nombreProyecto.replaceAll(RegExp(r'\\s+'), '_'),
    );

    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Nombre del archivo PDF"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del archivo',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("Cancelar")),
          FilledButton(
            onPressed: () {
              final archivo = _controller.text.trim();
              if (archivo.isNotEmpty) {
                final nombre_pdf = '$archivo.pdf';
                Navigator.pop(innerContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaneacionPreviewPdf(
                      planeacion: planeacion,
                      nombre_archivo: nombre_pdf,
                    ),
                  ),
                );
              }
            },
            child: const Text("Generar"),
          ),
        ],
      ),
    );
  }
}

// Widgets de búsqueda y filtros 

class _QuickSearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (v) => context.read<PlaneacionCubit>().setFiltroProyecto(v),
      decoration: InputDecoration(
        hintText: 'Buscar planeacion...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _AdvancedFilterBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          builder: (_) => BlocProvider.value(
            value: context.read<PlaneacionCubit>(),
            child: const _FiltersSheet(),
          ),
        );
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlaneacionCubit>();
    final s = cubit.state;
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filtros Avanzados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _field("Escuela", Icons.school, s.filtroNombreEscuela, cubit.setFiltroEscuela),
          _field("Ciclo Escolar", Icons.calendar_month, s.filtroCicloEscolar, cubit.setFiltroCiclo),
          Row(children: [
            Expanded(child: _field("Grado y Grupo", Icons.group, s.filtroGradoGrupo, cubit.setFiltroGrupo)),
            const SizedBox(width: 10),
            Expanded(child: _field("Fase", Icons.category, s.filtroFaseEducativa, cubit.setFiltroFase)),
          ]),
          _dropdownField(
            label: "Nivel",
            icon: Icons.layers,
            value: s.filtroNivelEducativo.isEmpty ? null : s.filtroNivelEducativo,
            options: ["","INI", "PREE", "PRIM", "SEC", "BACH"],
            onChanged: (val) => cubit.setFiltroNivel(val ?? ""),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B1D1D), minimumSize: const Size(double.infinity, 45)),
            child: const Text("Ver resultados", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: Text("Seleccionar $label"), 
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option.isEmpty ? null : option,
                child: Text(
                  option.isEmpty ? "Todos los niveles" : option, 
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
          filled: true,
          fillColor: const Color(0xFFF1F5F9), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon, String val, Function(String) fn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: TextEditingController(text: val)..selection = TextSelection.collapsed(offset: val.length),
        onChanged: fn,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon, size: 20),
          filled: true, fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _DeleteActionBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final count = context.watch<PlaneacionCubit>().state.selectedPlaneacionIds.length;
    return count > 0 ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => context.read<PlaneacionCubit>().eliminarSeleccionados()) : const SizedBox();
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF8B1D1D),
      onPressed: () async {
        final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaneacionCrearEditarView()));
        if (res == true) context.read<PlaneacionCubit>().cargarPlaneaciones();
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
