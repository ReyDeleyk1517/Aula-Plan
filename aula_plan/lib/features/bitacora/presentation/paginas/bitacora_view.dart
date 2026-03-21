import 'package:aula_plan/features/bitacora/presentation/paginas/preview_pdf_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:aula_plan/core/injection_container.dart';

// Imports de dominio y lógica
import 'package:aula_plan/features/bitacora/domain/entidades/bitacora_entidad.dart';
import '../bloc/bitacora_cubit.dart'; 
import '../bloc/bitacora_crear_editar_cubit.dart';

// Imports de presentación
import '../widgets/tarjeta_registro_bitacora.dart';
import 'bitacora_crear_editar_view.dart';

class BitacoraView extends StatelessWidget {
  const BitacoraView({super.key});

  

  Future<void> _irARegistro(BuildContext context, {BitacoraEntidad? registro, required DateTime fecha}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          // Pedir el Cubit directamente a GetIt. 
          // GetIt se encarga de inyectar los Casos de Uso por nosotros.
          create: (context) => sl<BitacoraCrearEditarCubit>(),
          child: BitacoraCrearEditarView(
            registroExistente: registro,
            fechaSeleccionada: fecha,
          ),
        ),
      ),
    );
    

    if (resultado == true) {
      if (context.mounted) {
        context.read<BitacoraCubit>().cargarRegistros(fecha);
      }
    }
  }

  // Funciones de Lógica de Fechas 

  List<DateTime> _generarSemana(DateTime fecha) {
    int diaActual = fecha.weekday;
    DateTime lunes = fecha.subtract(Duration(days: diaActual - 1));
    return List.generate(7, (index) => lunes.add(Duration(days: index)));
  }

  Future<void> _seleccionarFechaCalendario(BuildContext context, DateTime fechaInicial) async {
    final DateTime? seleccionado = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    if (seleccionado != null) {
      context.read<BitacoraCubit>().cambiarFecha(seleccionado);
    }
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("¿Eliminar registros?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancelar"),
          ),
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

  // Construcción de la Interfaz

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
          title: const Text("Bitacora Docente"),
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
      floatingActionButton: BlocBuilder<BitacoraCubit, BitacoraState>(
        builder: (context, estado) {

          if (estado.registrosSeleccionados.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: "pdf",
                  onPressed: () {
                    final registrosParaPdf = estado.registros
                        .where((r) => estado.registrosSeleccionados.contains(r.id))
                        .toList();

                    _modalCrearPDF(context, registrosParaPdf);
                  },
                  label: const Text("Generar PDF"),
                  icon: const Icon(Icons.picture_as_pdf),
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: "borrar",
                  onPressed: () => _confirmarEliminacion(context),
                  label: Text("Borrar (${estado.registrosSeleccionados.length})"),
                  icon: const Icon(Icons.delete),
                  backgroundColor: Colors.red,
                ),
              ],
            );
          }

          return FloatingActionButton(
            backgroundColor: const Color(0xFF6366F1),
            onPressed: () => _irARegistro(context, fecha: estado.fechaSeleccionada),
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _cabecera() {
    return BlocBuilder<BitacoraCubit, BitacoraState>(
      builder: (context, estado) {
        String textoFecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(estado.fechaSeleccionada);
        textoFecha = textoFecha[0].toUpperCase() + textoFecha.substring(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              //const Text("Bitácora Docente", 
              //  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 5),
              Text(textoFecha, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
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
              // Lista de dias
              ...semana.map((fecha) {
                bool esSeleccionado = DateUtils.isSameDay(fecha, estado.fechaSeleccionada);
                return GestureDetector(
                  onTap: () => context.read<BitacoraCubit>().cambiarFecha(fecha),
                  //onLongPress: () => _seleccionarFechaCalendario(context, estado.fechaSeleccionada),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                          // Añadí un borde sutil cuando no está seleccionado para dar feedback visual
                          border: Border.all(
                            color: esSeleccionado ? const Color(0xFF6366F1) : Colors.transparent,
                          ),
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
              // boton calendario
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF6366F1)),
                onPressed: () => _seleccionarFechaCalendario(context, estado.fechaSeleccionada),
                tooltip: "Seleccionar fecha",
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
        final listaFiltros = ["Todos", "Incidencias", "Evaluaciones", "Clases","Otros"];
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
                  child: Text(
                    f,
                    style: TextStyle(
                      color: esActivo ? Colors.white : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
        if (estado.error != null) return Center(child: Text(estado.error!));
        if (estado.registros.isEmpty) {
          return const Center(child: Text("No hay actividades registradas.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 0, 
            bottom: 150 
          ),
          itemCount: estado.registros.length,
          itemBuilder: (context, i) {
            final registro = estado.registros[i];
            return TarjetaRegistroBitacora(
              registro: registro, 
              estaSeleccionado: estado.registrosSeleccionados.contains(registro.id),
              // Pasamos la función de navegación directamente aquí
              onTap: () => _irARegistro(
                context, 
                registro: registro, 
                fecha: estado.fechaSeleccionada
              ),
              onToggleSeleccion: () => context.read<BitacoraCubit>().toggleSeleccion(registro.id!),
            );
          },
        );
      },
    );
  }

  void _modalCrearPDF(BuildContext context, List<BitacoraEntidad> registrosParaPdf) {
    final controller = TextEditingController(
      // Nombre por defecto con la fecha actual
      text: "Bitacora_${DateTime.now().day}_${DateTime.now().month}",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nombre del archivo"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Ej: Reporte_Marzo",
              suffixText: ".pdf",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final nombreFinal = controller.text.trim();
                if (nombreFinal.isNotEmpty) {
                  Navigator.pop(context);
                  
                  // Navegar a la preview pasando el nombre
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaginaPreviewPdf(
                        registrosSeleccionados: registrosParaPdf,
                        nombre_archivo: "$nombreFinal.pdf", 
                      ),
                    ),
                  );
                }
              },
              child: const Text("Continuar"),
            ),
          ],
        );
      },
    );
  }
}