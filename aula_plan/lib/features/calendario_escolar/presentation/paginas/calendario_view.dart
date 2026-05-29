import 'package:aula_plan/features/calendario_escolar/presentation/widgets/evento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entidades/evento_entidad.dart';
import '../bloc/evento_cubit.dart';
import 'package:aula_plan/core/injection_container.dart';
import 'evento_crear_editar_view.dart';

class EventoView extends StatelessWidget {
  const EventoView({super.key});

  final Color zacTinto = const Color(0xFF8B1D1D);

  // colores en los puntitos del calendario
  Color _getEventoColor(String tipo) {
    switch (tipo) {
      case "Académico":
        return const Color(0xFF3B82F6);
      case "Cívico":
        return const Color(0xFF10B981);
      case "Social":
        return const Color(0xFF8B5CF6);
      case "Urgente":
        return const Color(0xFFEF4444);
      case "Otros":
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EventoCubit>()
        ..cargarEventos(DateTime.now())
        ..inicializarCalendarioDesdeAssets(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: const Text(
            'Calendario escolar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _calendarioMensual(),
              _filtros(),
              const Divider(height: 1),
              Expanded(child: _listaEventos()),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _calendarioMensual() {
    return BlocBuilder<EventoCubit, EventoState>(
      builder: (context, estado) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime(2024),
            lastDay: DateTime(2027),
            focusedDay: estado.fechaSeleccionada,
            selectedDayPredicate: (day) =>
                isSameDay(estado.fechaSeleccionada, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,

            // Lógica para detectar eventos en un rango de fechas
            eventLoader: (day) {
              final d = DateTime(day.year, day.month, day.day);
              return estado.todosEventos.where((e) {
                try {
                  final inicio = DateTime.parse(e.fecha_inicio);
                  final fin = DateTime.parse(e.fecha_fin);
                  final inicioDate = DateTime(
                    inicio.year,
                    inicio.month,
                    inicio.day,
                  );
                  final finDate = DateTime(fin.year, fin.month, fin.day);

                  // Retorna verdadero si el día está dentro del rango inclusivo
                  return (d.isAtSameMomentAs(inicioDate) ||
                          d.isAfter(inicioDate)) &&
                      (d.isAtSameMomentAs(finDate) || d.isBefore(finDate));
                } catch (_) {
                  return false;
                }
              }).toList();
            },

            onDaySelected: (selectedDay, focusedDay) {
              context.read<EventoCubit>().cambiarFecha(selectedDay);
            },

            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: zacTinto,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: zacTinto.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: zacTinto,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),

            calendarBuilders: CalendarBuilders(
              // Fondo para eventos oficiales (ICS)
              prioritizedBuilder: (context, day, focusedDay) {
                final d = DateTime(day.year, day.month, day.day);
                final oficiales = estado.eventosOficiales.where((e) {
                  final inicio = e['inicio'] as DateTime;
                  final fin = e['fin'] as DateTime;
                  return (d.isAtSameMomentAs(inicio) || d.isAfter(inicio)) &&
                      d.isBefore(fin);
                }).toList();

                if (!isSameDay(day, estado.fechaSeleccionada) &&
                    oficiales.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (oficiales.first['color'] as Color).withOpacity(
                        0.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  );
                }
                return null;
              },

              // Marcadores de colores según tipo de evento
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                return Positioned(
                  bottom: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(4).map((event) {
                      final e = event as EventoEntidad;
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: _getEventoColor(e.tipo_evento),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _filtros() {
    return BlocBuilder<EventoCubit, EventoState>(
      builder: (context, estado) {
        final listaFiltros = [
          "Todos",
          "Académico",
          "Cívico",
          "Social",
          "Urgente",
          "Otros",
        ];
        return Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: listaFiltros.length,
            itemBuilder: (context, index) {
              final String filtroNombre = listaFiltros[index];
              final bool esActivo =
                  (estado.filtroCategoria == null && filtroNombre == "Todos") ||
                  (estado.filtroCategoria == filtroNombre);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filtroNombre),
                  selected: esActivo,
                  onSelected: (_) => context
                      .read<EventoCubit>()
                      .seleccionarFiltro(filtroNombre),
                  selectedColor: zacTinto,
                  labelStyle: TextStyle(
                    color: esActivo ? Colors.white : zacTinto,
                    fontSize: 12,
                    fontWeight: esActivo ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: zacTinto.withOpacity(0.3)),
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listaEventos() {
    return BlocBuilder<EventoCubit, EventoState>(
      builder: (context, estado) {
        if (estado.cargando)
          return const Center(child: CircularProgressIndicator());

        final oficialesHoy = estado.eventosOficiales.where((e) {
          final inicio = e['inicio'] as DateTime;
          final fin = e['fin'] as DateTime;
          final dia = DateTime(
            estado.fechaSeleccionada.year,
            estado.fechaSeleccionada.month,
            estado.fechaSeleccionada.day,
          );
          return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) &&
              dia.isBefore(fin);
        }).toList();

        if (estado.eventos.isEmpty && oficialesHoy.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Text(
                  "No hay actividades programadas",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 150),
          children: [
            if (oficialesHoy.isNotEmpty) ...[
              _buildSectionHeader("CALENDARIO OFICIAL"),
              ...oficialesHoy.map((e) => _buildOficialCard(e)),
              const SizedBox(height: 24),
            ],
            if (estado.eventos.isNotEmpty) ...[
              _buildSectionHeader("MIS EVENTOS"),
              ...estado.eventos.map((evento) {
                final bool isSelected = estado.eventosSeleccionados.contains(
                  evento.id,
                );
                return EventoCard(
                  evento: evento,
                  estaSeleccionado: isSelected,
                  onToggleSeleccion: () =>
                      context.read<EventoCubit>().toggleSeleccion(evento.id!),
                  onTap: () {
                    if (estado.eventosSeleccionados.isNotEmpty) {
                      context.read<EventoCubit>().toggleSeleccion(evento.id!);
                    } else {
                      _irARegistro(
                        context,
                        registro: evento,
                        fecha: estado.fechaSeleccionada,
                      );
                    }
                  },
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOficialCard(Map<String, dynamic> e) {
    final Color color = e['color'] as Color;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 18,
          child: const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(
          e['titulo'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: const Text(
          "Secretaría de Educación",
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<EventoCubit, EventoState>(
      builder: (context, estado) {
        if (estado.eventosSeleccionados.isNotEmpty) {
          // Usamos Column para que se vean TODOS los botones dentro del if
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Botón de Eliminar
              FloatingActionButton.extended(
                heroTag: 'delete_eventos', // Agregamos heroTag por seguridad
                onPressed: () => _confirmarEliminacion(context),
                label: Text("Eliminar (${estado.eventosSeleccionados.length})"),
                icon: const Icon(Icons.delete_outline),
                backgroundColor: Colors.red,
              ),
              const SizedBox(height: 12), // Espacio entre botones
              // Botón de Cancelar Selección
              FloatingActionButton(
                heroTag: 'cancel_eventos', // HeroTag único
                mini: true,
                onPressed: () => context.read<EventoCubit>().limpiarSeleccion(),
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          );
        }

       
        return FloatingActionButton(
          heroTag: 'add_evento',
          backgroundColor: zacTinto,
          onPressed: () =>
              _irARegistro(context, fecha: estado.fechaSeleccionada),
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }

  Future<void> _irARegistro(
    BuildContext context, {
    EventoEntidad? registro,
    required DateTime fecha,
  }) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventoCrearEditarView(
          registroExistente: registro,
          fechaSeleccionada: fecha,
        ),
      ),
    );
    if (resultado == true && context.mounted) {
      context.read<EventoCubit>().cargarEventos(fecha);
    }
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("¿Eliminar eventos?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<EventoCubit>().borrarSeleccionados();
              Navigator.pop(innerContext);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
