import 'package:aula_plan/features/Perfil/data/modelos/perfil_modelo.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../../core/db_helper.dart';

abstract class PerfilLocalDataSource {
  Future<List<PerfilModelo>> obtenerRegistros();
  Future<void> insertarRegistro(PerfilModelo modelo);
  Future<void> borrarRegistro(int id);
  Future<void> actualizarRegistro(PerfilModelo modelo);
}

class ImplementacionPerfilLocalDataSource implements PerfilLocalDataSource {
  @override
  Future<void> insertarRegistro(PerfilModelo modelo) async {
    final db = await DbHelper().database;
    await db.insert(
      DbHelper.perfilTable,
      modelo.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PerfilModelo>> obtenerRegistros() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> mapas = await db.query(DbHelper.perfilTable);
    return mapas.map((m) => PerfilModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarRegistro(int id) async {
    final db = await DbHelper().database;
    await db.delete(
      DbHelper.perfilTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> actualizarRegistro(PerfilModelo modelo) async {
    final db = await DbHelper().database;
    await db.update(
      DbHelper.perfilTable,
      modelo.aMapa(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }
}
