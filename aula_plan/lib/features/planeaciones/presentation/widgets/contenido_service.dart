import 'dart:convert';
import 'package:flutter/services.dart';
import 'contenido_model.dart';

class ContenidosService {
  static const Map<String, String> faseFiles = {
    '2': 'assets/files/fase2_contenidos_pda.json',
    '3, 4 y 5': 'assets/files/fase345_contenidos_pda.json',
    '6': 'assets/files/fase6_contenidos_pda.json',
  };

  Future<Map<String, List<ContenidoBusqueda>>> cargarContenidos(
    String fase,
  ) async {
    try {
      final String response = await rootBundle.loadString(faseFiles[fase]!);
      final data = json.decode(response) as Map<String, dynamic>;

      if (fase == '2') {
        return _procesarPreescolar(data);
      } else if (fase == '3, 4 y 5') {
        return _procesarPrimaria(data);
      } else {
        return _procesarSecundaria(data);
      }
    } catch (e) {
      print("Error en ContenidosService: $e");
      return {};
    }
  }

  // MÉTODO PARA PREESCOLAR (Fase 2)
  Map<String, List<ContenidoPrescolar>> _procesarPreescolar(
    Map<String, dynamic> data,
  ) {
    Map<String, List<ContenidoPrescolar>> resultado = {};
    data.forEach((campo, grados) {
      List<ContenidoPrescolar> listaDelCampo = [];
      (grados as Map<String, dynamic>).forEach((grado, contenidos) {
        (contenidos as Map<String, dynamic>).forEach((titulo, info) {
          final mapaInfo = info as Map<String, dynamic>;
          listaDelCampo.add(
            ContenidoPrescolar(
              titulo: titulo,
              pdas: List<String>.from(mapaInfo['pda']),
              numero: mapaInfo['numero']?.toString(),
              grado: grado,
            ),
          );
        });
      });
      resultado[campo] = listaDelCampo;
    });
    return resultado;
  }

  // MÉTODO PARA PRIMARIA (Fase 3, 4, 5)
  Map<String, List<ContenidoPrimaria>> _procesarPrimaria(
    Map<String, dynamic> data,
  ) {
    Map<String, List<ContenidoPrimaria>> resultado = {};
    data.forEach((campo, grados) {
      List<ContenidoPrimaria> listaDelCampo = [];
      (grados as Map<String, dynamic>).forEach((grado, contenidos) {
        (contenidos as Map<String, dynamic>).forEach((titulo, info) {
          final listaInfo = info as List<dynamic>;
          if (listaInfo.isNotEmpty) {
            listaDelCampo.add(
              ContenidoPrimaria(
                titulo: titulo,
                pdas: listaInfo.map((i) => i['pda'].toString()).toList(),
                numero: listaInfo[0]['numero']?.toString(),
                grado: grado,
              ),
            );
          }
        });
      });
      resultado[campo] = listaDelCampo;
    });
    return resultado;
  }

  // MÉTODO PARA SECUNDARIA (Fase 6 )
  Map<String, List<ContenidoSecundaria>> _procesarSecundaria(
    Map<String, dynamic> data,
  ) {
    Map<String, List<ContenidoSecundaria>> resultado = {};

    data.forEach((campo, grados) {
      List<ContenidoSecundaria> listaDelCampo = [];
      (grados as Map<String, dynamic>).forEach((grado, contenidos) {
        (contenidos as Map<String, dynamic>).forEach((titulo, info) {
          final mapaInfo = info as Map<String, dynamic>;
          listaDelCampo.add(
            ContenidoSecundaria(
              titulo: titulo,
              pdas: List<String>.from(mapaInfo['pda']),
              numero: mapaInfo['numero']?.toString(),
              grado: grado,
            ),
          );
        });
      });
      resultado[campo] = listaDelCampo;
    });
    return resultado;
  }


}
