import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  // Singleton
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  // Acceso a la bd
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<void> initDatabase() async {
    await database;
  }


  static const String bitacoraTable = 'bitacora';
  static const String perfilTable = 'perfil';


  Future<bool> existePerfil() async {
    final db = await database;
    final List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $perfilTable');
    int? count = Sqflite.firstIntValue(x);
    return (count ?? 0) > 0;
  }

  Future<Database> _initDatabase() async {
    final ruta = join(await getDatabasesPath(), 'database_docente.db');
    return await openDatabase(
      ruta,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $perfilTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            apellidos TEXT,
            region TEXT,
            zona_escolar TEXT,
            funcion TEXT,
            centro_trabajo TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $bitacoraTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT,
            hora TEXT,
            categoria TEXT,
            titulo TEXT,
            actividad TEXT,
            observaciones TEXT,
            perfil_id INTEGER,
            FOREIGN KEY (perfil_id) REFERENCES $perfilTable(id)
          )
          ''',
        );
      },
    );
  }


  Future<int?> obtenerPerfilId() async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(perfilTable, limit: 1);
    if (res.isNotEmpty) {
      return res.first['id'] as int;
    }
    return null;
  }
}
