import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aula_plan/features/calendario_escolar/domain/entidades/evento_entidad.dart';
class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<EventoEntidad> allEvents;

  const MonthCalendar({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
    required this.allEvents,
  });

  @override
  Widget build(BuildContext context) {
    final int year = month.year;
    final int m = month.month;
    final int daysInMonth = DateTime(year, m + 1, 0).day;
    final int leadingBlanks = DateTime(year, m, 1).weekday - 1;

    final List<DateTime?> cells = List.generate(leadingBlanks, (_) => null)
      ..addAll(List.generate(daysInMonth, (i) => DateTime(year, m, i + 1)));

    while (cells.length % 7 != 0) { cells.add(null); }

    return Column(
      mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio necesario
      children: [
        Text(
          DateFormat('MMMM yyyy', 'es_ES').format(month).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        // GridView ahora con shrinkWrap para evitar errores de layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (ctx, idx) {
            final date = cells[idx];
            if (date == null) return const SizedBox.shrink();

            final isSelected = _isSameDay(date, selectedDate);
            final hasEvent = allEvents.any((e) => _dateInRange(date, e));

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (hasEvent)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  
  bool _dateInRange(DateTime date, EventoEntidad e) {
    try {
      final DateTime inicio = DateTime.parse(e.fecha_inicio);
      final DateTime fin = DateTime.parse(e.fecha_fin);
      final DateTime dia = DateTime(date.year, date.month, date.day);
      return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) &&
          (dia.isAtSameMomentAs(fin) || dia.isBefore(fin));
    } catch (_) {
      return false;
    }
  }
}