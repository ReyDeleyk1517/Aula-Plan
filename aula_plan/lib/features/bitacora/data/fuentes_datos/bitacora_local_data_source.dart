import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/modelo_bitacora.dart';

abstract class BitacoraLocalDataSource {
  Future<List<ModeloBitacora>> obtenerRegistros();
  Future<void> insertarRegistro(ModeloBitacora modelo);
  Future<void> borrarRegistro(int id);
  Future<void> actualizarRegistro(ModeloBitacora modelo); 
}

class ImplementacionBitacoraLocalDataSource implements BitacoraLocalDataSource {
  Database? _db;

  Future<Database> get baseDeDatos async {
    if (_db != null) return _db!;
    _db = await _inicializarBD();
    return _db!;
  }

  Future<Database> _inicializarBD() async {
    String ruta = join(await getDatabasesPath(), 'organizador_docente.db');
    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE bitacora(id INTEGER PRIMARY KEY AUTOINCREMENT, fecha TEXT, hora TEXT, categoria TEXT, titulo TEXT, actividad TEXT, observaciones TEXT)"
        );
      },
    );
  }

  @override
  Future<void> insertarRegistro(ModeloBitacora modelo) async {
    final db = await baseDeDatos;
    await db.insert('bitacora', modelo.aMapa(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<ModeloBitacora>> obtenerRegistros() async {
    final db = await baseDeDatos;
    final List<Map<String, dynamic>> mapas = await db.query('bitacora', orderBy: 'id DESC');
    return mapas.map((m) => ModeloBitacora.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarRegistro(int id) async {
    final db = await baseDeDatos;
    await db.delete('bitacora', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> actualizarRegistro(ModeloBitacora modelo) async {
    final db = await baseDeDatos;
    
    // Convertir objeto a mapa
    await db.update(
      'bitacora',
      modelo.aMapa(), 
      where: 'id = ?', 
      whereArgs: [modelo.id], 
    );
  }
}