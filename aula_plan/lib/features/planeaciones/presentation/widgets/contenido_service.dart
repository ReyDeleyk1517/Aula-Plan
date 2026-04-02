import 'dart:convert';
import 'package:flutter/services.dart';

class ContenidoBusqueda {
  final String titulo;
  final List<String> pdas;
  ContenidoBusqueda({required this.titulo, required this.pdas});
}

class ContenidosService {
  // Mapeo de nombres de archivos
  static const Map<String, String> faseFiles = {
    '2': 'assets/files/fase2_contenidos_pda.json',
    '3, 4 y 5': 'assets/files/fase345_contenidos_pda.json',
    '6': 'assets/files/fase6_contenidos_pda.json',
  };

  Future<Map<String, List<ContenidoBusqueda>>> cargarContenidos(String fase) async {
    final String response = await rootBundle.loadString(faseFiles[fase]!);
    final data = json.decode(response) as Map<String, dynamic>;
    
    Map<String, List<ContenidoBusqueda>> resultado = {};
    
    data.forEach((campo, contenidosMap) {
      List<ContenidoBusqueda> listaContenidos = [];
      (contenidosMap as Map<String, dynamic>).forEach((titulo, pdasRaw) {
        listaContenidos.add(ContenidoBusqueda(
          titulo: titulo,
          pdas: List<String>.from(pdasRaw),
        ));
      });
      resultado[campo] = listaContenidos;
    });
    
    return resultado;
  }
}