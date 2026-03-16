import 'package:aula_plan/features/Perfil/data/modelos/perfil_modelo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class PerfilLocalDataSource {
  Future<List<PerfilModelo>> obtenerRegistros();
  Future<void> insertarRegistro(PerfilModelo modelo);
  Future<void> borrarRegistro(int id);
  Future<void> actualizarRegistro(PerfilModelo modelo);
}

class ImplementacionPerfilLocalDataSource implements PerfilLocalDataSource {
  Database? _db;
  // nombre de la tabla 
  final String nombreTabla = 'perfil';

  Future<Database> get baseDeDatos async {
    if (_db != null) return _db!;
    _db = await _inicializarBD();
    return _db!;
  }

  Future<Database> _inicializarBD() async {
    String ruta = join(await getDatabasesPath(), 'database_docente.db');
    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $nombreTabla ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "nombre TEXT, "
          "apellidos TEXT, "
          "region TEXT, "
          "zona_escolar TEXT, "
          "funcion TEXT, "
          "centro_trabajo TEXT"
          ")"
        );
      },
    );
  }

  @override
  Future<void> insertarRegistro(PerfilModelo modelo) async {
    final db = await baseDeDatos;
    
    await db.insert(
      nombreTabla, 
      modelo.aMapa(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  @override
  Future<List<PerfilModelo>> obtenerRegistros() async {
    final db = await baseDeDatos;
    // Consultamos la tabla perfil
    final List<Map<String, dynamic>> mapas = await db.query(nombreTabla);
    return mapas.map((m) => PerfilModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> borrarRegistro(int id) async {
    final db = await baseDeDatos;
    await db.delete(
      nombreTabla, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  @override
  Future<void> actualizarRegistro(PerfilModelo modelo) async {
    final db = await baseDeDatos;
    await db.update(
      nombreTabla,
      modelo.aMapa(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }
}