import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/planeacion_servicio_pdf.dart';

class PlaneacionPreviewPdf extends StatelessWidget {
  final PlaneacionEntidad planeacion;
  final String nombre_archivo;

  const PlaneacionPreviewPdf({
    super.key, 
    required this.planeacion,
    required this.nombre_archivo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Previsualización PDF"),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        // generar los bytes desde el servicio de planeación
        build: (format) => PlaneacionServicioPdf.generarPdfPlaneacion(planeacion),
        
        // Configuraciones de visualización
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false, 
        
        // Nombre del archivo 
        pdfFileName: nombre_archivo,
        
        // Loader 
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
