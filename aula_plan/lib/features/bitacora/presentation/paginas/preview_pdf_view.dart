import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:aula_plan/features/bitacora/domain/entidades/bitacora_entidad.dart';
import 'package:aula_plan/core/servicio_pdf.dart';

class PaginaPreviewPdf extends StatelessWidget {
  final List<BitacoraEntidad> registrosSeleccionados;

  const PaginaPreviewPdf({super.key, required this.registrosSeleccionados});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Previsualización PDF"),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        // recibir directamente los bytes del servicio
        build: (format) => ServicioPdf.generarPdfBitacora(registrosSeleccionados),
        
        // Configuraciones de visualización
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false, 
        
        // Nombre del archivo 
        pdfFileName: "Bitacora_${DateTime.now().day}_${DateTime.now().month}.pdf",
        
        // Loader 
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}