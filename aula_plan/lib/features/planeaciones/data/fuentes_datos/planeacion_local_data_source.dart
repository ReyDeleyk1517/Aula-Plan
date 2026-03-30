import 'package:aula_plan/features/planeaciones/data/modelos/planeacion_modelos.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/db_helper.dart';

abstract class PlaneacionLocalDataSource {
  Future<List<PlaneacionModelo>> obtenerTodas();
  Future<PlaneacionModelo?> obtenerPorId(int id);
  Future<void> insertarCompleta(PlaneacionModelo modelo);
  Future<void> eliminar(int id);
  Future<void> actualizarCompleta(PlaneacionModelo modelo);

  // Nuevas: Actividades de una planeación (tabla independiente)
  Future<List<ActividadPlaneacionModelo>> obtenerActividadesPorPlaneacion(int idPlaneacion);
  Future<void> insertarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionModelo> actividades);
  Future<void> actualizarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionModelo> actividades);
}

class ImplementacionPlaneacionLocalDataSource
    implements PlaneacionLocalDataSource {
  final String tablaPlaneacion = "planeacion";

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

      // Insertar actividades asociadas a la planeación
      for (var act in modelo.actividades) {
        final mapaAct = (act as ActividadPlaneacionModelo).aMapa();
        mapaAct['id_planeacion'] = idGenerado;
        await txn.insert(DbHelper.actividadesTable, mapaAct);
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
      // Consultamos las actividades de ESTA planeación específica
      final List<Map<String, dynamic>> mapasActividades = await db.query(
        DbHelper.actividadesTable,
        where: 'id_planeacion = ?',
        whereArgs: [id],
      );

      final actividades = mapasActividades
          .map((a) => ActividadPlaneacionModelo.desdeMapa(a))
          .toList();

      listaCompleta.add(PlaneacionModelo.desdeMapa(mapa, actividades: actividades));
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

    final List<Map<String, dynamic>> mapasActividades = await db.query(
      DbHelper.actividadesTable,
      where: 'id_planeacion = ?',
      whereArgs: [id],
    );
    final actividades = mapasActividades
        .map((a) => ActividadPlaneacionModelo.desdeMapa(a))
        .toList();
    return PlaneacionModelo.desdeMapa(res.first, actividades: actividades);
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

      // Borrar actividades antiguas para evitar duplicados
      await txn.delete(
        DbHelper.actividadesTable,
        where: 'id_planeacion = ?',
        whereArgs: [modelo.id],
      );
      // insertar actividades
      for (var a in modelo.actividades) {
        final acto = a as ActividadPlaneacionModelo;
        final mapaActividad = acto.aMapa();
        mapaActividad['id'] = acto.id;
        mapaActividad['id_planeacion'] = modelo.id; // asegurar el vínculo a la planeacion
        await txn.insert(DbHelper.actividadesTable, mapaActividad);
      }
    });
  }

  @override
  Future<void> eliminar(int id) async {
    final db = await _getDatabase;

    await db.delete(tablaPlaneacion, where: 'id = ?', whereArgs: [id]);
  }
  
  @override
  Future<List<ActividadPlaneacionModelo>> obtenerActividadesPorPlaneacion(int idPlaneacion) async {
    final db = await _getDatabase;
    final List<Map<String, dynamic>> res = await db.query(
      DbHelper.actividadesTable,
      where: 'id_planeacion = ?',
      whereArgs: [idPlaneacion],
    );
    return res.map((m) => ActividadPlaneacionModelo.desdeMapa(m)).toList();
  }

  @override
  Future<void> insertarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionModelo> actividades) async {
    final db = await _getDatabase;
    await db.transaction((txn) async {
      for (final a in actividades) {
        final mapa = a.aMapa();
        mapa['id_planeacion'] = idPlaneacion;
        await txn.insert(DbHelper.actividadesTable, mapa,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<void> actualizarActividadesParaPlaneacion(int idPlaneacion, List<ActividadPlaneacionModelo> actividades) async {
    final db = await _getDatabase;
    await db.transaction((txn) async {
      await txn.delete(DbHelper.actividadesTable, where: 'id_planeacion = ?', whereArgs: [idPlaneacion]);
      for (final a in actividades) {
        final mapa = a.aMapa();
        mapa['id_planeacion'] = idPlaneacion;
        await txn.insert(DbHelper.actividadesTable, mapa, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
