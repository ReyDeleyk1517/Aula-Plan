import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:aula_plan/features/bitacora/domain/entidades/entidad_bitacora.dart';

class ServicioPdf {
  static Future<Uint8List> generarPdfBitacora(List<EntidadBitacora> registros) async {
    final pdf = pw.Document();

    final estiloTitulo = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final estiloCelda = pw.TextStyle(fontSize: 8);

    // Ordenar cronológicamente
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
          // Encabezado
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text("BITÁCORA DOCENTE DE ACTIVIDADES", style: estiloTitulo.copyWith(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],
            ),
          ),

          // Tabla
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.8), // Fecha (Reducido)
              1: const pw.FlexColumnWidth(0.6), // Hora (Reducido)
              2: const pw.FlexColumnWidth(1.0), // Categoría (Reducido)
              3: const pw.FlexColumnWidth(1.0), // Título (Grande)
              4: const pw.FlexColumnWidth(2.5), // Actividad (Más grande)
              5: const pw.FlexColumnWidth(2.0), // Observaciones (Grande)
            },
            children: [
              // Fila de Encabezados
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _celdaHeader("FECHA", estiloCelda),
                  _celdaHeader("HORA", estiloCelda),
                  _celdaHeader("CATEGORIA", estiloCelda),
                  _celdaHeader("TÍTULO", estiloCelda),
                  _celdaHeader("ACTIVIDAD", estiloCelda),
                  _celdaHeader("OBSERVACIONES", estiloCelda),
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

          // Firmas
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _lineaFirma("Firma del Docente"),
              _lineaFirma("Sello Institucional"),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _celdaHeader(String texto, pw.TextStyle estilo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(texto, style: estilo.copyWith(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _celdaTexto(String texto, pw.TextStyle estilo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(texto, style: estilo),
    );
  }

  static pw.Widget _lineaFirma(String cargo) {
    return pw.Column(
      children: [
        pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5)))),
        pw.SizedBox(height: 2),
        pw.Text(cargo, style: const pw.TextStyle(fontSize: 7)),
      ],
    );
  }
}