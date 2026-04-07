import 'dart:convert';
import 'package:flutter/services.dart';

class ContenidoBusqueda {
  final String titulo;
  final List<String> pdas;
  ContenidoBusqueda({required this.titulo, required this.pdas});
}

class ContenidosService {
  static const Map<String, String> faseFiles = {
    '2': 'assets/files/fase2_contenidos_pda.json',
    '3, 4 y 5': 'assets/files/fase345_contenidos_pda.json',
    '6': 'assets/files/fase6_contenidos_pda.json',
  };

  Future<Map<String, List<ContenidoBusqueda>>> cargarContenidos(String fase) async {
    final String response = await rootBundle.loadString(faseFiles[fase]!);
    final data = json.decode(response) as Map<String, dynamic>;

    switch (fase) {
      case '2':
        return _procesarFase2(data);
      case '3, 4 y 5':
        return _procesarFase345(data);
      case '6':
        return _procesarFase6(data);
      default:
        return {};
    }
  }

  // Lógica específica para Fase 2
  Map<String, List<ContenidoBusqueda>> _procesarFase2(Map<String, dynamic> data) {
    Map<String, List<ContenidoBusqueda>> resultado = {};
    data.forEach((campo, contenidos) {
      resultado[campo] = (contenidos as Map<String, dynamic>).entries.map((e) {
        return ContenidoBusqueda(titulo: e.key, pdas: List<String>.from(e.value));
      }).toList();
    });
    return resultado;
  }

  // Lógica específica para Fase 3, 4 y 5
  Map<String, List<ContenidoBusqueda>> _procesarFase345(Map<String, dynamic> data) {
    Map<String, List<ContenidoBusqueda>> resultado = {};
    data.forEach((campo, contenidos) {
      resultado[campo] = (contenidos as Map<String, dynamic>).entries.map((e) {
        return ContenidoBusqueda(titulo: e.key, pdas: List<String>.from(e.value));
      }).toList();
    });
    return resultado;
  }

  // Lógica específica para Fase 6 (Secundaria)
  // Nota: Aquí se maneja la jerarquía Campo -> Disciplina -> Contenido
  Map<String, List<ContenidoBusqueda>> _procesarFase6(Map<String, dynamic> data) {
    Map<String, List<ContenidoBusqueda>> resultado = {};
    data.forEach((campo, contenidos) {
      resultado[campo] = (contenidos as Map<String, dynamic>).entries.map((e) {
        return ContenidoBusqueda(titulo: e.key, pdas: List<String>.from(e.value));
      }).toList();
    });
    return resultado;
  }
}