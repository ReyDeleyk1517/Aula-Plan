import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get_it/get_it.dart';

import 'package:aula_plan/features/bitacora/domain/entidades/bitacora_entidad.dart';
import 'package:aula_plan/features/Perfil/domain/casos de uso/perfil_casos_uso.dart';

final sl = GetIt.instance;

class BitacoraServicioPdf {
  static Future<Uint8List> generarPdfBitacora(List<BitacoraEntidad> registros) async {
    final pdf = pw.Document();

    // Obtener datos del perfil 
    final obtenerPerfil = sl<ObtenerRegistrosPerfil>();
    final listaPerfiles = await obtenerPerfil();
    final perfil = listaPerfiles.isNotEmpty ? listaPerfiles.first : null;

    // Estilos
    final estiloTituloBold = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    final estiloSubtitulo = pw.TextStyle(fontSize: 9, color: PdfColors.black);
    final estiloHeaderTabla = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
    final estiloCelda = pw.TextStyle(fontSize: 8);

    // Ordenar registros por fecha y hora
    registros.sort((a, b) {
      int compFecha = a.fecha.compareTo(b.fecha);
      if (compFecha != 0) return compFecha;
      return a.hora.compareTo(b.hora);
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(25),
        build: (context) => [
          //  ENCABEZADO 
          pw.Header(
            level: 0,
            child: pw.Column(
              children: [
                pw.Center(
                  child: pw.Text("BITÁCORA DOCENTE DE ACTIVIDADES", style: estiloTituloBold),
                ),
                pw.SizedBox(height: 10),
                if (perfil != null) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("DOCENTE: ${perfil.nombre} ${perfil.apellidos}", style: estiloSubtitulo),
                      pw.Text("ZONA ESCOLAR: ${perfil.zona_escolar}", style: estiloSubtitulo),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("CENTRO DE TRABAJO: ${perfil.centro_trabajo}", style: estiloSubtitulo),
                      pw.Text("FUNCIÓN: ${perfil.funcion}", style: estiloSubtitulo),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text("REGIÓN: ${perfil.region}", style: estiloSubtitulo),
                ] else ...[
                  pw.Center(child: pw.Text("DATOS DEL DOCENTE NO CONFIGURADOS", style: estiloSubtitulo.copyWith(color: PdfColors.red))),
                ],
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
              ],
            ),
          ),

          // --- TABLA DE DATOS ---
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.8), // Fecha
              1: const pw.FlexColumnWidth(0.6), // Hora
              2: const pw.FlexColumnWidth(1.0), // Categoría
              3: const pw.FlexColumnWidth(1.0), // Título
              4: const pw.FlexColumnWidth(2.5), // Actividad
              5: const pw.FlexColumnWidth(2.0), // Observaciones
            },
            children: [
              // Fila de Encabezados
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _celdaHeader("FECHA", estiloHeaderTabla),
                  _celdaHeader("HORA", estiloHeaderTabla),
                  _celdaHeader("CATEGORÍA", estiloHeaderTabla),
                  _celdaHeader("TÍTULO", estiloHeaderTabla),
                  _celdaHeader("ACTIVIDAD", estiloHeaderTabla),
                  _celdaHeader("OBSERVACIONES", estiloHeaderTabla),
                ],
              ),
              // Filas de Datos
              ...registros.map((r) => pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.top,
                    children: [
                      _celdaTexto(r.fecha, estiloCelda),
                      _celdaTexto(r.hora, estiloCelda),
                      _celdaTexto(r.categoria, estiloCelda),
                      _celdaTexto(r.titulo, estiloCelda),
                      _celdaTexto(r.actividad, estiloCelda),
                      _celdaTexto(r.observaciones, estiloCelda),
                    ],
                  )),
            ],
          ),

          // firmas
          pw.SizedBox(height: 50),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              //_lineaFirma(perfil != null ? "${perfil.nombre} ${perfil.apellidos}" : "Firma del Docente"),
              _lineaFirma("Firma del Docente"),
              _lineaFirma("Sello Institucional"),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            "Página ${context.pageNumber} de ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // Widgets auxiliares

  static pw.Widget _celdaHeader(String texto, pw.TextStyle estilo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(texto, style: estilo, textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _celdaTexto(dynamic valor, pw.TextStyle estilo) {
    final String contenido = (valor == null) ? "" : valor.toString();
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(contenido, style: estilo),
    );
  }

  static pw.Widget _lineaFirma(String cargoOdocente) {
    return pw.Column(
      children: [
        pw.Container(
          width: 160,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(cargoOdocente, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}