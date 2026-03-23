import 'package:aula_plan/features/planeaciones/data/modelos/planeacion_modelos.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/db_helper.dart';

abstract class PlaneacionLocalDataSource {
  Future<List<PlaneacionModelo>> obtenerTodas();
  Future<PlaneacionModelo?> obtenerPorId(int id);
  Future<void> insertarCompleta(PlaneacionModelo modelo);
  Future<void> eliminar(int id);
  Future<void> actualizarCompleta(PlaneacionModelo modelo);

  Future<void> actualizarFaseIndividual(FasePlaneacionModelo fase);
  Future<void> insertarFaseIndividual(FasePlaneacionModelo fase);
}

class ImplementacionPlaneacionLocalDataSource
    implements PlaneacionLocalDataSource {
  final String tablaPlaneacion = "planeacion";
  final String tablaFases = "fases_planeacion";

  Future<Database> get _getDatabase async => await DbHelper().database;

  @override
  Future<void> insertarCompleta(PlaneacionModelo modelo) async {
    final db = await _getDatabase;
    await db.transaction((txn) async {
      // Insertar datos generales
      int idGenerado = await txn.insert(
        tablaPlaneacion,
        modelo.aMapa(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insertar fases
      for (var fase in modelo.fases) {
        // modelo.fases es List<FasePlaneacionModelo>
        // pasar aMapa()
        final mapaFase = (fase as FasePlaneacionModelo).aMapa();
        mapaFase['id_planeacion'] = idGenerado;
        await txn.insert(tablaFases, mapaFase);
      }
    });
  }

  @override
  Future<List<PlaneacionModelo>> obtenerTodas() async {
    final db = await _getDatabase;

    // Obtenemos todas las planeaciones
    final List<Map<String, dynamic>> mapasPlaneacion = await db.query(
      tablaPlaneacion,
      orderBy: 'id DESC',
    );

    List<PlaneacionModelo> listaCompleta = [];

    for (var mapa in mapasPlaneacion) {
      final int id = mapa['id'];

      // Consultamos las fases de ESTA planeación específica
      final List<Map<String, dynamic>> mapasFases = await db.query(
        tablaFases,
        where: 'id_planeacion = ?',
        whereArgs: [id],
      );

      final fases = mapasFases
          .map((f) => FasePlaneacionModelo.desdeMapa(f))
          .toList();

      listaCompleta.add(PlaneacionModelo.desdeMapa(mapa, fases: fases));
    }

    return listaCompleta;
  }

  @override
  Future<PlaneacionModelo?> obtenerPorId(int id) async {
    final db = await _getDatabase;

    final List<Map<String, dynamic>> res = await db.query(
      tablaPlaneacion,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;

    final List<Map<String, dynamic>> mapasFases = await db.query(
      tablaFases,
      where: 'id_planeacion = ?',
      whereArgs: [id],
    );

    final fases = mapasFases
        .map((f) => FasePlaneacionModelo.desdeMapa(f))
        .toList();
    return PlaneacionModelo.desdeMapa(res.first, fases: fases);
  }

  @override
  Future<void> actualizarCompleta(PlaneacionModelo modelo) async {
    final db = await _getDatabase;

    await db.transaction((txn) async {
      // Actualizar datos generales
      await txn.update(
        tablaPlaneacion,
        modelo.aMapa(),
        where: 'id = ?',
        whereArgs: [modelo.id],
      );

      // Borrar fases antiguas (para evitar duplicados o huerfanos)
      await txn.delete(
        tablaFases,
        where: 'id_planeacion = ?',
        whereArgs: [modelo.id],
      );

      // insertar fases
      for (var fase in modelo.fases) {

        final faseModelo = fase as FasePlaneacionModelo;
        final mapaFase = faseModelo.aMapa();

        mapaFase['id'] = faseModelo.id;
        mapaFase['id_planeacion'] = modelo.id; // asegurar el vínculo a la planeacion

        await txn.insert(tablaFases, mapaFase);
      }
    });
  }

  @override
  Future<void> eliminar(int id) async {
    final db = await _getDatabase;

    await db.delete(tablaPlaneacion, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> actualizarFaseIndividual(FasePlaneacionModelo fase) async {
    final db = await _getDatabase;
    await db.update(
      tablaFases,
      fase.aMapa(),
      where: 'id = ?',
      whereArgs: [fase.id],
    );
  }

  @override
  Future<void> insertarFaseIndividual(FasePlaneacionModelo fase) async {
    final db = await _getDatabase;
    await db.insert(
      tablaFases,
      fase.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
