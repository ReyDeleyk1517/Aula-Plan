import 'package:aula_plan/features/bitacora/presentation/paginas/pagina_preview_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:aula_plan/core/injection_container.dart';

// Imports de dominio y lógica
import 'package:aula_plan/features/bitacora/domain/entidades/entidad_bitacora.dart';
import '../bloc/cubit_bitacora.dart'; 
import '../bloc/cubit_formulario_bitacora.dart';

// Imports de presentación
import '../widgets/tarjeta_actividad.dart';
import 'pagina_registro_bitacora.dart';

class PaginaBitacora extends StatelessWidget {
  const PaginaBitacora({super.key});

  

  Future<void> _irARegistro(BuildContext context, {EntidadBitacora? registro, required DateTime fecha}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          // Pedir el Cubit directamente a GetIt. 
          // GetIt se encarga de inyectar los Casos de Uso por nosotros.
          create: (context) => sl<CubitFormularioBitacora>(),
          child: PaginaRegistroBitacora(
            registroExistente: registro,
            fechaSeleccionada: fecha,
          ),
        ),
      ),
    );
    

    if (resultado == true) {
      if (context.mounted) {
        context.read<CubitBitacora>().cargarRegistros(fecha);
      }
    }
  }

  // --- Funciones de Lógica de Fechas ---

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
      context.read<CubitBitacora>().cambiarFecha(seleccionado);
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
              context.read<CubitBitacora>().borrarSeleccionados();
              Navigator.pop(innerContext);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  // --- Construcción de la Interfaz ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      floatingActionButton: BlocBuilder<CubitBitacora, BitacoraState>(
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

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaginaPreviewPdf(registrosSeleccionados: registrosParaPdf),
                      ),
                    );
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
    return BlocBuilder<CubitBitacora, BitacoraState>(
      builder: (context, estado) {
        String textoFecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(estado.fechaSeleccionada);
        textoFecha = textoFecha[0].toUpperCase() + textoFecha.substring(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              const Text("Bitácora Docente", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 5),
              Text(textoFecha, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        );
      },
    );
  }

  Widget _tiraDias() {
    return BlocBuilder<CubitBitacora, BitacoraState>(
      builder: (context, estado) {
        final semana = _generarSemana(estado.fechaSeleccionada);
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: semana.map((fecha) {
              bool esSeleccionado = DateUtils.isSameDay(fecha, estado.fechaSeleccionada);
              return GestureDetector(
                onTap: () => context.read<CubitBitacora>().cambiarFecha(fecha),
                onLongPress: () => _seleccionarFechaCalendario(context, estado.fechaSeleccionada),
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
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _filtros() {
    return BlocBuilder<CubitBitacora, BitacoraState>(
      builder: (context, estado) {
        final listaFiltros = ["Todos", "Incidencias", "Evaluaciones", "Clases"];
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
                onTap: () => context.read<CubitBitacora>().seleccionarFiltro(f),
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
    return BlocBuilder<CubitBitacora, BitacoraState>(
      builder: (context, estado) {
        if (estado.cargando) return const Center(child: CircularProgressIndicator());
        if (estado.error != null) return Center(child: Text(estado.error!));
        if (estado.registros.isEmpty) {
          return const Center(child: Text("No hay actividades registradas.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: estado.registros.length,
          itemBuilder: (context, i) {
            final registro = estado.registros[i];
            return GestureDetector(
              onTap: () => _irARegistro(
                context, 
                registro: registro, 
                fecha: estado.fechaSeleccionada
              ),
              child: TarjetaActividad(registro: registro, 
              estaSeleccionado: estado.registrosSeleccionados.contains(registro.id), 
              onToggleSeleccion: () => context.read<CubitBitacora>().toggleSeleccion(registro.id!),),
            );
          },
        );
      },
    );
  }
}