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

  // Nombres de tablas
  static const String perfilTable = 'perfil';
  static const String bitacoraTable = 'bitacora';
  static const String recursosTable = 'recursos_docentes';
  static const String planeacionTable = 'planeacion';
  static const String fasesPlaneacionTable = 'fases_planeacion';
  static const String actividadesTable = 'actividades_planeacion';
  static const String eventoTable = 'evento';

  Future<Database> _initDatabase() async {
    final ruta = join(await getDatabasesPath(), 'database_docente.db');
    
    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        // --- Tabla Perfil ---
        await db.execute('''
          CREATE TABLE $perfilTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            apellidos TEXT,
            region TEXT,
            zona_escolar TEXT,
            funcion TEXT,
            centro_trabajo TEXT
          )
        ''');

        // --- Tabla Bitácora ---
        await db.execute('''
          CREATE TABLE $bitacoraTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT,
            hora TEXT,
            categoria TEXT,
            titulo TEXT,
            actividad TEXT,
            observaciones TEXT,
            perfil_id INTEGER,
            FOREIGN KEY (perfil_id) REFERENCES $perfilTable(id) ON DELETE CASCADE
          )
        ''');

        // --- Tabla Recursos ---
        await db.execute('''
          CREATE TABLE $recursosTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            area TEXT,
            campo_formativo TEXT,
            tipo_archivo TEXT,
            ruta_archivo TEXT,
            enlace TEXT,
            fecha_creacion TEXT,
            perfil_id INTEGER,
            FOREIGN KEY (perfil_id) REFERENCES $perfilTable(id) ON DELETE CASCADE
          )
        ''');

        // --- Tabla Planeación ---
        await db.execute('''
          CREATE TABLE $planeacionTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perfil_id INTEGER,
            ciclo_escolar TEXT,
            fecha_entrega TEXT,
            nombre_escuela TEXT,
            nivel_educativo TEXT,
            fase_educativa TEXT,
            grupo TEXT,
            condicion_alumnado TEXT,
            temporalidad TEXT,
            necesidades_bap TEXT,
            disciplina TEXT,
            campos_formativos TEXT,
            contenidos TEXT,
            pda TEXT,
            ejes_articuladores TEXT,
            escenarios TEXT,
            metodologia TEXT,
            nombre_proyecto TEXT,
            organizacion_grupo TEXT,
            espacio TEXT,
            tiempo TEXT,
            responsables TEXT,
            evaluacion_indicadores TEXT,
            evaluacion_instrumentos TEXT,
            observaciones TEXT,
            FOREIGN KEY (perfil_id) REFERENCES $perfilTable(id) ON DELETE CASCADE
          )
        ''');

        // --- Tabla Actividades Planeacion ---
        await db.execute('''
          CREATE TABLE $actividadesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_planeacion INTEGER,
            titulo TEXT,
            descripcion TEXT,
            materiales TEXT,
            FOREIGN KEY (id_planeacion) REFERENCES $planeacionTable(id) ON DELETE CASCADE
          )
        ''');

        // --- Tabla Evento ---
        await db.execute('''
          CREATE TABLE $eventoTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perfil_id INTEGER,
            titulo TEXT,
            descripcion TEXT,
            fecha_inicio TEXT,
            fecha_fin TEXT,
            tipo_evento TEXT,
            lugar TEXT,
            FOREIGN KEY (perfil_id) REFERENCES $perfilTable(id) ON DELETE CASCADE
          )
        ''');
      },
      onConfigure: (db) async {
        // Habilitar claves foráneas para que ON DELETE CASCADE funcione
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Métodos de utilidad
  Future<bool> existePerfil() async {
    final db = await database;
    final List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $perfilTable');
    int? count = Sqflite.firstIntValue(x);
    return (count ?? 0) > 0;
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
