import 'package:aula_plan/core/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../modelos/bitacora_modelo.dart';


abstract class BitacoraLocalDataSource {
  Future<List<BitacoraModelo>> obtenerRegistros();
  Future<void> insertarRegistro(BitacoraModelo modelo);
  Future<void> borrarRegistro(int id);
  Future<void> actualizarRegistro(BitacoraModelo modelo);
}

class ImplementacionBitacoraLocalDataSource implements BitacoraLocalDataSource {
  
  final String nombreTabla = "bitacora";

  
  Future<Database> get _getDatabase async => await DbHelper().database;

  @override
  Future<void> insertarRegistro(BitacoraModelo modelo) async {
    final db = await _getDatabase;
    await db.insert(
      nombreTabla,
      modelo.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<BitacoraModelo>> obtenerRegistros() async {
    final db = await _getDatabase;
    final List<Map<String, dynamic>> mapas = await db.query(
      nombreTabla,
      orderBy: 'id DESC',
    );
    return mapas.map((m) => BitacoraModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarRegistro(int id) async {
    final db = await _getDatabase;
    await db.delete(
      nombreTabla,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> actualizarRegistro(BitacoraModelo modelo) async {
    final db = await _getDatabase;
    await db.update(
      nombreTabla,
      modelo.aMapa(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }
}