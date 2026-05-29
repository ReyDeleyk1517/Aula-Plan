import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_cubit.dart';
import 'package:aula_plan/features/planeaciones/presentation/widgets/planeacion_card.dart';
import 'package:aula_plan/features/planeaciones/presentation/paginas/planeacion_preview_pdf_view.dart';
import 'package:aula_plan/features/planeaciones/presentation/paginas/planeacion_crear_editar_view.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/injection_container.dart' as di;

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aula_plan/core/planeacion_servicio_pdf.dart'; // Asegúrate de que esta ruta sea correcta

class PlaneacionListView extends StatelessWidget {
  const PlaneacionListView({Key? key}) : super(key: key);

  Future<void> _irAPlaneacion(
    BuildContext context, {
    PlaneacionEntidad? planeacion,
  }) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlaneacionCrearEditarView(planeacionExistente: planeacion),
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
          title: const Text(
            'Planeaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildHeaderFiltros(),
            const Expanded(child: _PlaneacionListBuilder()),
          ],
        ),
        floatingActionButton: _BotonFlotanteDinamico(
          irAPlaneacion: _irAPlaneacion,
        ),
      ),
    );
  }

  Widget _buildHeaderFiltros() {
    return Builder(
      builder: (context) {
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
      },
    );
  }
}

class _PlaneacionListBuilder extends StatelessWidget {
  const _PlaneacionListBuilder();

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorWidgetOfExactType<PlaneacionListView>();

    return BlocBuilder<PlaneacionCubit, PlaneacionState>(
      builder: (context, estado) {
        if (estado.cargando)
          return const Center(child: CircularProgressIndicator());

        final lista = estado.planeacionesFiltradas;
        if (lista.isEmpty) return const Center(child: Text("Sin resultados"));

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: 250,
          ),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final p = lista[i];
            final esSeleccionado = estado.selectedPlaneacionIds.contains(p.id);

            return PlaneacionCard(
              planeacion: p,
              selected: esSeleccionado,
              onSelected: () =>
                  context.read<PlaneacionCubit>().toggleSeleccion(p.id!),
              onEditTap: () {
                // Al tocar el lápiz, navega directo a la pantalla de edición
                parent?._irAPlaneacion(context, planeacion: p);
              },
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

  Future<void> _compartirPdfDirecto(
    BuildContext context,
    PlaneacionEntidad planeacion,
    String nombreDesdeModal,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preparando archivo..."),
          duration: Duration(seconds: 2),
        ),
      );

      final directory = await getTemporaryDirectory();

      // 1. Sanitizar el nombre que viene del modal
      String nombreLimpio = nombreDesdeModal.trim().replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      if (nombreLimpio.isEmpty) nombreLimpio = "Planeacion";
      if (!nombreLimpio.toLowerCase().endsWith('.pdf')) nombreLimpio += '.pdf';

      final String rutaCompleta = p.join(directory.path, nombreLimpio);

      // 2. Generar bytes
      final Uint8List pdfBytes =
          await PlaneacionServicioPdf.generarPdfPlaneacion(planeacion);

      // 3. Escritura física
      final File archivoTemporal = File(rutaCompleta);
      await archivoTemporal.writeAsBytes(pdfBytes);

      final box = context.findRenderObject() as RenderBox?;

      // 4. Compartir
      await Share.shareXFiles(
        [XFile(rutaCompleta, mimeType: 'application/pdf')],
        subject: 'Planeación: ${planeacion.nombreProyecto}',
        text: 'Adjunto envío la planeación docente.',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al compartir: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                    final planeacion = estado.planeacionesFiltradas.firstWhere(
                      (p) => p.id == seleccionados.first,
                    );
                    _mostrarModalNombreArchivo(
                      context: context,
                      nombreSugerido: planeacion.nombreProyecto,
                      alConfirmar: (nombrePdf) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaneacionPreviewPdf(
                            planeacion: planeacion,
                            nombre_archivo: nombrePdf,
                          ),
                        ),
                      ),
                    );
                  },
                  label: const Text("Vista Previa PDF"),
                  icon: const Icon(Icons.picture_as_pdf),
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 12),

                FloatingActionButton.extended(
                  heroTag: "fab_share",
                  onPressed: () {
                    final planeacion = estado.planeacionesFiltradas.firstWhere(
                      (p) => p.id == seleccionados.first,
                    );
                    _mostrarModalNombreArchivo(
                      context: context,
                      nombreSugerido: planeacion.nombreProyecto,
                      alConfirmar: (nombrePdf) =>
                          _compartirPdfDirecto(context, planeacion, nombrePdf),
                    );
                  },
                  label: const Text("Compartir PDF"),
                  icon: const Icon(Icons.share),
                  backgroundColor: Colors.blueAccent,
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
                onPressed: () =>
                    context.read<PlaneacionCubit>().limpiarSeleccion(),
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
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancelar"),
          ),
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

  void _mostrarModalNombreArchivo({
    required BuildContext context,
    required String nombreSugerido,
    required Function(String nombreFinal) alConfirmar,
  }) {
    // Sanitizamos el nombre inicial para que no tenga espacios problemáticos
    final TextEditingController _controller = TextEditingController(
      text: nombreSugerido.replaceAll(RegExp(r'\s+'), '_'),
    );

    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Nombre del archivo PDF"),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre del archivo',
            suffixText: '.pdf',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              final nombre = _controller.text.trim();
              if (nombre.isNotEmpty) {
                Navigator.pop(innerContext);
                alConfirmar("$nombre.pdf");
              }
            },
            child: const Text("Aceptar"),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
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

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Filtros Avanzados",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Usamos BlocBuilder para que los cambios en el estado
          // se reflejen en tiempo real en los campos del modal.
          BlocBuilder<PlaneacionCubit, PlaneacionState>(
            builder: (context, state) {
              return Column(
                children: [
                  _field(
                    "Escuela",
                    Icons.school,
                    state.filtroNombreEscuela,
                    cubit.setFiltroEscuela,
                  ),
                  _field(
                    "Ciclo Escolar",
                    Icons.calendar_month,
                    state.filtroCicloEscolar,
                    cubit.setFiltroCiclo,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          "Grado y Grupo",
                          Icons.group,
                          state.filtroGradoGrupo,
                          cubit.setFiltroGrupo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          "Fase",
                          Icons.category,
                          state.filtroFaseEducativa,
                          cubit.setFiltroFase,
                        ),
                      ),
                    ],
                  ),
                  _field(
                    "Fase Momento Etapa",
                    Icons.timeline,
                    state.filtroFaseMomentoEtapa,
                    cubit.setFiltroFaseMomentoEtapa,
                  ),
                  _dropdownField(
                    label: "Nivel",
                    icon: Icons.layers,
                    value: state.filtroNivelEducativo.isEmpty
                        ? null
                        : state.filtroNivelEducativo,
                    options: ["", "INI", "PREE", "PRIM", "SEC", "BACH"],
                    onChanged: (val) => cubit.setFiltroNivel(val ?? ""),
                  ),
                  const SizedBox(height: 10),

                  // Fila de Fechas Reactiva
                  Row(
                    children: [
                      Expanded(
                        child: _datePickerField(
                          context,
                          label: 'Desde',
                          value: state.filtroFechaCreacionDesde,
                          onDateSelected: (v) =>
                              cubit.setFiltroFechaCreacionDesde(v),
                          onClear: () => cubit.setFiltroFechaCreacionDesde(""),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _datePickerField(
                          context,
                          label: 'Hasta',
                          value: state.filtroFechaCreacionHasta,
                          onDateSelected: (v) =>
                              cubit.setFiltroFechaCreacionHasta(v),
                          onClear: () => cubit.setFiltroFechaCreacionHasta(""),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1D1D),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text(
              "Ver resultados",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _datePickerField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onDateSelected,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: () async {
        DateTime initial = DateTime.now();
        if (value.isNotEmpty) {
          try {
            initial = DateTime.parse(value);
          } catch (_) {}
        }
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked.toIso8601String().substring(0, 10));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          suffixIcon: value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
        child: Text(
          value.isEmpty ? 'Seleccionar' : value,
          style: TextStyle(
            fontSize: 13,
            color: value.isEmpty ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon, String val, Function(String) fn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length),
        onChanged: fn,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
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
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt.isEmpty ? null : opt,
                child: Text(opt.isEmpty ? "Todos" : opt),
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
        ),
      ),
    );
  }
}
