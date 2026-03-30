import 'package:aula_plan/core/db_helper.dart';
import 'package:aula_plan/features/calendario_escolar/data/modelos/evento_modelo.dart';
import 'package:sqflite/sqflite.dart';



abstract class EventoLocalDataSource {
  Future<List<EventoModelo>> obtenerEventos();
  Future<void> insertarEvento(EventoModelo modelo);
  Future<void> borrarEvento(int id);
  Future<void> actualizarEvento(EventoModelo modelo);
}

class ImplementacionEventoLocalDataSource implements EventoLocalDataSource {
  
  final String nombreTabla = "evento";

  
  Future<Database> get _getDatabase async => await DbHelper().database;

  @override
  Future<void> insertarEvento(EventoModelo modelo) async {
    final db = await _getDatabase;
    await db.insert(
      nombreTabla,
      modelo.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EventoModelo>> obtenerEventos() async {
    final db = await _getDatabase;
    final List<Map<String, dynamic>> mapas = await db.query(
      nombreTabla,
      orderBy: 'id DESC',
    );
    return mapas.map((m) => EventoModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarEvento(int id) async {
    final db = await _getDatabase;
    await db.delete(
      nombreTabla,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> actualizarEvento(EventoModelo modelo) async {
    final db = await _getDatabase;
    await db.update(
      nombreTabla,
      modelo.aMapa(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }
}