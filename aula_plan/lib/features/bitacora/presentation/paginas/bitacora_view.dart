import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Imports de dominio y lógica
import 'package:aula_plan/features/bitacora/domain/entidades/bitacora_entidad.dart';
import 'package:aula_plan/features/bitacora/presentation/bloc/bitacora_cubit.dart'; 
import 'package:aula_plan/core/injection_container.dart' as di;

// Imports de presentación
import 'package:aula_plan/features/bitacora/presentation/widgets/bitacora_card.dart';
import 'package:aula_plan/features/bitacora/presentation/paginas/bitacora_crear_editar_view.dart';
import 'package:aula_plan/features/bitacora/presentation/paginas/bitacora_preview_pdf_view.dart';

class BitacoraView extends StatelessWidget {
  const BitacoraView({super.key});

  // Navegación a creación o edición
  Future<void> _irARegistro(BuildContext context, {BitacoraEntidad? registro, required DateTime fecha}) async {
    // Limpiar selección antes de navegar para evitar estados inconsistentes 
    context.read<BitacoraCubit>().limpiarSeleccion();

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BitacoraCrearEditarView(
          registroExistente: registro,
          fechaSeleccionada: fecha,
        ),
      ),
    );

    if (resultado == true && context.mounted) {
      context.read<BitacoraCubit>().cargarRegistros(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<BitacoraCubit>()..cargarRegistros(DateTime.now()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Bitácora Docente', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _cabecera(),
              _tiraDias(),
              _filtros(),
              Expanded(child: _listaFeed()),
            ],
          ),
        ),
        floatingActionButton: _BotonFlotanteDinamico(irARegistro: _irARegistro),
      ),
    );
  }

  // --- Widgets Internos ---

  Widget _cabecera() {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        String textoFecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(estado.fechaSeleccionada);
        textoFecha = textoFecha[0].toUpperCase() + textoFecha.substring(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(textoFecha, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
        );
      },
    );
  }

  Widget _tiraDias() {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        final semana = _generarSemana(estado.fechaSeleccionada);
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...semana.map((fecha) {
                bool esSeleccionado = DateUtils.isSameDay(fecha, estado.fechaSeleccionada);
                return GestureDetector(
                  onTap: () => context.read<BitacoraCubit>().cambiarFecha(fecha),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E', 'es_ES').format(fecha).toUpperCase().replaceAll('.', ''),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: esSeleccionado ? const Color(0xFF6366F1) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: esSeleccionado ? const Color(0xFF6366F1) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          fecha.day.toString(),
                          style: TextStyle(
                            color: esSeleccionado ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF6366F1)),
                onPressed: () => _seleccionarFechaCalendario(context, estado.fechaSeleccionada),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filtros() {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        final listaFiltros = ["Todos", "Incidencias", "Evaluaciones", "Clases", "Otros"];
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: listaFiltros.length,
            itemBuilder: (context, index) {
              final f = listaFiltros[index];
              bool esActivo = (estado.filtroCategoria == null && f == "Todos") || (estado.filtroCategoria == f);
              return GestureDetector(
                onTap: () => context.read<BitacoraCubit>().seleccionarFiltro(f),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: esActivo ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(f, style: TextStyle(color: esActivo ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listaFeed() {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        if (estado.cargando) return const Center(child: CircularProgressIndicator());
        if (estado.registros.isEmpty) return const Center(child: Text("No hay actividades registradas."));

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 0, 
            bottom: 200, 
          ),
          itemCount: estado.registros.length,
          itemBuilder: (context, i) {
            final registro = estado.registros[i];
            final esSeleccionado = estado.registrosSeleccionados.contains(registro.id);

            return BitacoraCard(
              registro: registro, 
              estaSeleccionado: esSeleccionado,
              onTap: () {
                // Si hay elementos seleccionados, el tap normal selecciona/deselecciona
                if (estado.registrosSeleccionados.isNotEmpty) {
                  context.read<BitacoraCubit>().toggleSeleccion(registro.id!);
                } else {
                  // Si no hay nada seleccionado, abre edición
                  _irARegistro(context, registro: registro, fecha: estado.fechaSeleccionada);
                }
              },
              onToggleSeleccion: () => context.read<BitacoraCubit>().toggleSeleccion(registro.id!),
            );
          },
        );
      },
    );
  }

  // Metodo auxiliar

  List<DateTime> _generarSemana(DateTime fecha) {
    int diaActual = fecha.weekday;
    DateTime lunes = fecha.subtract(Duration(days: diaActual - 1));
    return List.generate(7, (index) => lunes.add(Duration(days: index)));
  }

  Future<void> _seleccionarFechaCalendario(BuildContext context, DateTime fechaInicial) async {
    final seleccionado = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (seleccionado != null) context.read<BitacoraCubit>().cambiarFecha(seleccionado);
  }
}


class _BotonFlotanteDinamico extends StatelessWidget {
  final Function(BuildContext, {BitacoraEntidad? registro, required DateTime fecha}) irARegistro;
  const _BotonFlotanteDinamico({required this.irARegistro});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        final seleccionados = estado.registrosSeleccionados;

        if (seleccionados.isNotEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: "pdf_bit",
                onPressed: () {
                  final registrosParaPdf = estado.registros.where((r) => seleccionados.contains(r.id)).toList();
                  _modalCrearPDF(context, registrosParaPdf);
                },
                label: const Text("Generar PDF"),
                icon: const Icon(Icons.picture_as_pdf),
                backgroundColor: Colors.orange,
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: "delete_bit",
                onPressed: () => _confirmarEliminacion(context),
                label: Text("Borrar (${seleccionados.length})"),
                icon: const Icon(Icons.delete),
                backgroundColor: Colors.red,
              ),
              const SizedBox(height: 12),
              // Botón Cancelar idéntico al de Planeaciones
              FloatingActionButton(
                heroTag: "cancel_bit",
                mini: true,
                onPressed: () => context.read<BitacoraCubit>().limpiarSeleccion(),
                backgroundColor: Colors.grey,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          );
        }

        return FloatingActionButton(
          backgroundColor: const Color(0xFF6366F1),
          onPressed: () => irARegistro(context, fecha: estado.fechaSeleccionada),
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("¿Eliminar registros?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("Cancelar")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BitacoraCubit>().borrarSeleccionados();
              Navigator.pop(innerContext);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void _modalCrearPDF(BuildContext context, List<BitacoraEntidad> registrosParaPdf) {
    final controller = TextEditingController(text: "Bitacora_${DateTime.now().day}_${DateTime.now().month}");
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Nombre del archivo"),
        content: TextField(controller: controller, decoration: const InputDecoration(suffixText: ".pdf")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final nombre = controller.text.trim();
              if (nombre.isNotEmpty) {
                Navigator.pop(innerContext);
                Navigator.push(context, MaterialPageRoute(builder: (_) => PaginaPreviewPdf(registrosSeleccionados: registrosParaPdf, nombre_archivo: "$nombre.pdf")));
              }
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }
}