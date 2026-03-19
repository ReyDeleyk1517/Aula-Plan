import 'package:aula_plan/core/db_helper.dart';
import 'package:aula_plan/features/recursos_docentes/data/modelos/recurso_docente_modelo.dart';
import 'package:sqflite/sqflite.dart';


abstract class RecursoDocenteLocalDataSource {
  Future<List<RecursoDocenteModelo>> obtenerRecursos();
  Future<void> insertarRecurso(RecursoDocenteModelo modelo);
  Future<void> borrarRecurso(int id);
  Future<void> actualizarRecurso(RecursoDocenteModelo modelo);
}

class ImplementacionRecursoDocenteLocalDataSource implements RecursoDocenteLocalDataSource {
  
  final String nombreTabla = "recursos_docentes";

  Future<Database> get _getDatabase async => await DbHelper().database;

  @override
  Future<void> insertarRecurso(RecursoDocenteModelo modelo) async {
    final db = await _getDatabase;
    await db.insert(
      nombreTabla,
      modelo.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<RecursoDocenteModelo>> obtenerRecursos() async {
    final db = await _getDatabase;
    final List<Map<String, dynamic>> mapas = await db.query(
      nombreTabla,
      orderBy: 'fecha_creacion DESC',
    );
    
    return mapas.map((m) => RecursoDocenteModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarRecurso(int id) async {
    final db = await _getDatabase;
    await db.delete(
      nombreTabla,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> actualizarRecurso(RecursoDocenteModelo modelo) async {
    final db = await _getDatabase;
    await db.update(
      nombreTabla,
      modelo.aMapa(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }
}