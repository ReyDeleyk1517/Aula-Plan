import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aula_plan/features/calendario_escolar/domain/entidades/evento_entidad.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<EventoEntidad> allEvents;
  final List<Map<String, dynamic>> officialEvents;

  const MonthCalendar({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
    required this.allEvents,
    required this.officialEvents,
  });

  @override
  Widget build(BuildContext context) {
    final int year = month.year;
    final int m = month.month;
    final int daysInMonth = DateTime(year, m + 1, 0).day;
    final int leadingBlanks = DateTime(year, m, 1).weekday - 1;

    final List<DateTime?> cells = List.generate(leadingBlanks, (_) => null)
      ..addAll(List.generate(daysInMonth, (i) => DateTime(year, m, i + 1)));

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'es_ES').format(month).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
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

            // Eventos personales 
            final hasUserEvent = allEvents.any((e) => _dateInRange(date, e));

            // Eventos oficiales (Fondo de celda)
            final oficialesDelDia = officialEvents.where((e) {
              final inicio = e['inicio'] as DateTime;
              final fin = e['fin'] as DateTime;
              final dia = DateTime(date.year, date.month, date.day);
              return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) && (dia.isBefore(fin));
            }).toList();

            Color backgroundColor = Colors.white;
            Color textColor = Colors.black;
            
            if (oficialesDelDia.isNotEmpty) {
              backgroundColor = (oficialesDelDia.first['color'] as Color).withOpacity(0.2);

            }

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withOpacity(0.3) : backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.blue 
                        : (oficialesDelDia.isNotEmpty 
                            ? oficialesDelDia.first['color'] as Color 
                            : Colors.grey.shade300),
                    width: (isSelected || oficialesDelDia.isNotEmpty) ? 2 : 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.blue.shade900 : textColor,
                        fontWeight: (isSelected || oficialesDelDia.isNotEmpty) 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                    // Solo mostramos el punto si hay eventos del USUARIO
                    if (hasUserEvent)
                      Positioned(
                        bottom: 6,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B1D1D), 
                            shape: BoxShape.circle,
                          ),
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _dateInRange(DateTime date, EventoEntidad e) {
    try {
      final DateTime inicio = DateTime.parse(e.fecha_inicio);
      final DateTime fin = DateTime.parse(e.fecha_fin);
      final DateTime dia = DateTime(date.year, date.month, date.day);
      final DateTime finInclusivo = DateTime(fin.year, fin.month, fin.day, 23, 59);
      return (dia.isAtSameMomentAs(inicio) || dia.isAfter(inicio)) && (dia.isBefore(finInclusivo));
    } catch (_) {
      return false;
    }
  }
}