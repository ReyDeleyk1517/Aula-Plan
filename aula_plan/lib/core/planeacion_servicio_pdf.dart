import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get_it/get_it.dart';
import 'package:aula_plan/features/Perfil/domain/casos%20de%20uso/perfil_casos_uso.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:flutter/services.dart' show rootBundle;

final sl = GetIt.instance;

class PlaneacionServicioPdf {
  static Future<Uint8List> generarPdfPlaneacion(
    PlaneacionEntidad planeacion,
  ) async {
    final pdf = pw.Document();

    //logo
    final ByteData bytes = await rootBundle.load(
      'assets/images/logo_secretaria.jpg',
    );
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImagen = pw.MemoryImage(logoBytes);

    final obtenerPerfil = sl<ObtenerRegistrosPerfil>();
    final listaPerfiles = await obtenerPerfil();
    final perfil = listaPerfiles.isNotEmpty ? listaPerfiles.first : null;
    final nombreDocente = perfil != null
        ? "${perfil.nombre} ${perfil.apellidos}".toUpperCase()
        : "NOMBRE DEL DOCENTE";

    final estiloTitulo = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final estiloCelda = pw.TextStyle(fontSize: 7);
    final estiloSigla = pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
    );

    final condicionesGuardadas = planeacion.condicionAlumnado.split(',').map((e) => e.trim());

    bool tieneAS = condicionesGuardadas.contains("AS");
    bool tieneD = condicionesGuardadas.contains("D");
    bool tieneTEA = condicionesGuardadas.contains("TEA");
    bool tieneTDAH = condicionesGuardadas.contains("TDAH");
    bool tieneTE = condicionesGuardadas.contains("TE");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          // LOGO EN LA ESQUINA SUPERIOR DERECHA
          pw.Positioned(
            right: 0,
            top: 0,
            child: pw.Image(
              logoImagen,
              width: 100,
              height: 100,
            ), // Ajusta el tamaño
          ),
          // ENCABEZADO INSTITUCIONAL ---
          pw.Center(
            child: pw.Column(
              children: [
                //pw.Text("SECRETARÍA DE EDUCACIÓN", style: estiloTitulo),
                //pw.Text("ESTADO DE ZACATECAS", style: estiloTitulo),
                pw.Text(
                  "UNIDAD DE SERVICIOS DE APOYO A LA EDUCACIÓN REGULAR",
                  style: estiloTitulo.copyWith(fontSize: 9),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  nombreDocente,
                  style: estiloTitulo.copyWith(fontSize: 10),
                ),
                pw.Text(
                  "ZONA ESCOLAR 18 EDUCACIÓN ESPECIAL",
                  style: estiloTitulo,
                ),
                pw.Text(
                  "CICLO ESCOLAR ${planeacion.cicloEscolar}",
                  style: estiloTitulo,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "PLANEACIÓN DIDÁCTICA",
                  style: estiloTitulo.copyWith(
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          // ECHA DE ENTREGA
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Fecha de entrega: ${planeacion.fechaEntrega}",
              style: estiloCelda.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 5),

          // DATOS GENERALES
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(3.5),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.0),
              4: const pw.FlexColumnWidth(4.5),
            },
            children: [
              pw.TableRow(
                children: [
                  _celdaHeader("Nombre de la Escuela", estiloCelda),
                  _celdaHeader("Nivel educativo", estiloCelda),
                  _celdaHeader("Fase", estiloCelda),
                  _celdaHeader("Grupo", estiloCelda),
                  _celdaHeader("Condición del alumnado", estiloCelda),
                ],
              ),
              pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  _celdaTexto(planeacion.nombreEscuela, estiloCelda),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        _cuadritoConSigla(
                          "INI",
                          planeacion.nivelEducativo.contains("INI"),
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "PREE",
                          planeacion.nivelEducativo.contains("PREE"),
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "PRIM",
                          planeacion.nivelEducativo.contains("PRIM"),
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "SEC",
                          planeacion.nivelEducativo.contains("SEC"),
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "BACH",
                          planeacion.nivelEducativo.contains("BACH"),
                          estiloSigla,
                        ),
                      ],
                    ),
                  ),
                  _celdaTexto(planeacion.faseEducativa, estiloCelda),
                  _celdaTexto(planeacion.grupo, estiloCelda),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        _cuadritoConSigla(
                          "AS",
                          tieneAS,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "D",
                          tieneD,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TEA",
                          tieneTEA,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TDAH",
                          tieneTDAH,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TE",
                          tieneTE,
                          estiloSigla,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // (Temporalidad, NIP/BAP, Disciplina)
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // 25% (1 de 4 partes)
              1: const pw.FlexColumnWidth(3), // 75% (3 de 4 partes)
            },
            children: [
              // Fila Temporalidad
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Temporalidad", estiloCelda),
                  _celdaDatoLateral(planeacion.temporalidad, estiloCelda),
                ],
              ),
              // Fila NIP y BAP
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral(
                    "Necesidades, Intereses, Problematicas (NIP) y Barreras para el Aprendizaje y la Participación (BAP) identificadas en el Programa analítico.",
                    estiloCelda.copyWith(fontSize: 6.5),
                  ),
                  _celdaDatoLateral(planeacion.necesidadesBap, estiloCelda),
                ],
              ),
              // Fila Disciplina
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral(
                    "Disciplina (sólo SEC/BACH)",
                    estiloCelda,
                  ),
                  _celdaDatoLateral(planeacion.disciplina, estiloCelda),
                ],
              ),
            ],
          ),
          // CAMPOS FORMATIVOS
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Fila 1: Título centrado que abarca todo
              pw.TableRow(
                children: [
                  _celdaHeader(
                    "Campo (s) formativos que se trabajarán",
                    estiloCelda,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              // Fila 2: 4 cuadros con etiquetas y checkboxes (25% cada uno)
              pw.TableRow(
                children: [
                  _celdaCampoCheck("Lenguajes", estiloSigla),
                  _celdaCampoCheck(
                    "Saberes y pensamiento científico",
                    estiloSigla,
                  ),
                  _celdaCampoCheck(
                    "De lo humano y lo comunitario.",
                    estiloSigla,
                  ),
                  _celdaCampoCheck(
                    "Ética, Naturaleza y sociedades",
                    estiloSigla,
                  ),
                ],
              ),
            ],
          ),

          // CONTENIDOS
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Fila 3: Título centrado que abarca todo
              pw.TableRow(
                children: [_celdaHeader("Contenido (s)", estiloCelda)],
              ),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              // Fila 4: 4 cuadros con el contenido de la BD (4 campos)
              pw.TableRow(
                children: [
                  _celdaTextoContenido(
                    planeacion.contenidos_lenguaje,
                    estiloCelda,
                  ),
                  _celdaTextoContenido(
                    planeacion.contenidos_saberes_y_pensamiento_cientifico,
                    estiloCelda,
                  ),
                  _celdaTextoContenido(
                    planeacion.contenidos_de_lo_humano_y_comunitario,
                    estiloCelda,
                  ),
                  _celdaTextoContenido(
                    planeacion.contenidos_etica_naturaleza_y_sociedad,
                    estiloCelda,
                  ),
                ],
              ),
            ],
          ),

          // PDA Y PROBLEMÁTICA
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2), // 50% del ancho
              1: const pw.FlexColumnWidth(2), // 50% del ancho
            },
            children: [
              // Fila de Títulos
              pw.TableRow(
                children: [
                  _celdaHeader(
                    "Proceso (s) de desarrollo de aprendizaje (PDA)",
                    estiloCelda,
                  ),
                  _celdaHeader("Problemática", estiloCelda),
                ],
              ),
              // Fila de Datos de la BD
              pw.TableRow(
                children: [
                  _celdaTextoContenido(planeacion.pda, estiloCelda),
                  _celdaTextoContenido(planeacion.problematica, estiloCelda),
                ],
              ),
            ],
          ),
          // EJES ARTICULADORES (TÍTULO)
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                children: [_celdaHeader("Ejes articuladores", estiloCelda)],
              ),
            ],
          ),

          // CUADRÍCULA DE EJES
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.3), // Cuadro X 1
              1: const pw.FlexColumnWidth(1), // Texto Eje 1
              2: const pw.FlexColumnWidth(0.3), // Cuadro X 2
              3: const pw.FlexColumnWidth(1), // Texto Eje 2
              4: const pw.FlexColumnWidth(0.3), // Cuadro X 3
              5: const pw.FlexColumnWidth(1), // Texto Eje 3
              6: const pw.FlexColumnWidth(0.3), // Cuadro X 4
              7: const pw.FlexColumnWidth(1), // Texto Eje 4
            },
            children: [
              // Fila 1
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    "Inclusión",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Inclusión.", estiloSigla),
                  _cuadroCheckboxDinamico(
                    "Artes y expresión estética",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado(
                    "Artes y expresión estética.",
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    "Interculturalidad crítica",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado(
                    "De interculturalidad crítica.",
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    "Pensamiento crítico",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Pensamiento Crítico.", estiloSigla),
                ],
              ),
              // Fila 2
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    "Apropiación de las culturas a través de la lectura y la escritura",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado(
                    "Apropiación de las culturas a través de la lectura y la escritura.",
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    "Igualdad de género",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Igualdad de género.", estiloSigla),
                  _cuadroCheckboxDinamico(
                    "Vida saludable",
                    planeacion.ejesArticuladores,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Vida saludable.", estiloSigla),
                  pw.Container(), // Espacios vacíos para mantener la cuadrícula de 8
                  pw.Container(),
                ],
              ),
            ],
          ),

          //ESCENARIOS
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // Cuadro X 1
              1: const pw.FlexColumnWidth(0.3), // Texto Eje 1
              2: const pw.FlexColumnWidth(1), // Cuadro X 2
              3: const pw.FlexColumnWidth(0.3), // Texto Eje 2
              4: const pw.FlexColumnWidth(1), // Cuadro X 3
              5: const pw.FlexColumnWidth(0.3), // Texto Eje 3
              6: const pw.FlexColumnWidth(1), // Cuadro X 4
            },
            children: [
              // Fila Escenarios
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Escenario (s):", estiloCelda),
                  _cuadroCheckboxDinamico(
                    "Aulico",
                    planeacion.escenarios,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Aulico", estiloSigla),
                  _cuadroCheckboxDinamico(
                    "Escolar",
                    planeacion.escenarios,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Escolar", estiloSigla),
                  _cuadroCheckboxDinamico(
                    "Comunitario",
                    planeacion.escenarios,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Comunitario", estiloSigla),
                ],
              ),
            ],
          ),
          // METODOLOGIA Y PROYECTO
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.77), // 25% (1 de 4 partes)
              1: const pw.FlexColumnWidth(3), // 75% (3 de 4 partes)
            },
            children: [
              // Fila metodologia
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Metodologia:", estiloCelda),
                  _celdaDatoLateral(planeacion.metodologia, estiloCelda),
                ],
              ),
              // Fila nombre proyecto
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Nombre del proyecto:", estiloCelda),
                  _celdaDatoLateral(planeacion.nombreProyecto, estiloCelda),
                ],
              ),
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("FASE/MOMENTO/ETAPA", estiloCelda),
                  _celdaDatoLateral("", estiloCelda),
                ],
              ),
            ],
          ),

          // SECCIÓN DINÁMICA: ACTIVIDADES Y MATERIALES
          // Iteramos por cada actividad guardada en la planeación
          ...planeacion.actividades.map((actividad) {
            return pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(
                  3,
                ), // Más espacio para la descripción
                1: const pw.FlexColumnWidth(1), // Menos espacio para materiales
              },
              children: [
                // Fila 1: Títulos de la Actividad
                pw.TableRow(
                  children: [
                    _celdaHeader("Actividad", estiloCelda),
                    _celdaHeader("Materiales y/o recursos", estiloCelda),
                  ],
                ),
                // Fila 2: Contenido de la BD
                pw.TableRow(
                  children: [
                    // Cuadro de Actividad (Título en negritas + Descripción)
                    _celdaContenidoActividad(
                      actividad.titulo,
                      actividad.descripcion,
                      estiloCelda,
                    ),
                    // Cuadro de Materiales
                    _celdaTextoContenido(actividad.materiales, estiloCelda),
                  ],
                ),
              ],
            );
          }).toList(),

          // ORGANIZACIÓN, ESPACIO, TIEMPO Y RESPONSABLE
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              // Primera fila: Títulos
              pw.TableRow(
                children: [
                  _celdaHeader("Organización del grupo", estiloCelda),
                  _celdaHeader("Espacio", estiloCelda),
                  _celdaHeader("Tiempo de realización", estiloCelda),
                  _celdaHeader("Responsable(s)", estiloCelda),
                ],
              ),
              // Segunda fila: Datos de la BD
              pw.TableRow(
                children: [
                  _celdaTextoContenido(
                    planeacion.organizacionGrupo,
                    estiloCelda,
                  ),
                  _celdaTextoContenido(planeacion.espacio, estiloCelda),
                  _celdaTextoContenido(planeacion.tiempo, estiloCelda),
                  _celdaTextoContenido(planeacion.responsables, estiloCelda),
                ],
              ),
            ],
          ),
          // EVALUACIÓN FORMATIVA
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {0: const pw.FlexColumnWidth(1)},
            children: [
              pw.TableRow(
                children: [_celdaHeader("Evaluación formativa", estiloCelda)],
              ),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // Columna Indicadores
              1: const pw.FlexColumnWidth(1), // Columna Instrumentos
            },
            children: [
              // Subtítulos
              pw.TableRow(
                children: [
                  _celdaHeader("Indicadores", estiloCelda),
                  _celdaHeader("Instrumentos", estiloCelda),
                ],
              ),
              // Datos de la BD
              pw.TableRow(
                children: [
                  _celdaTextoContenido(
                    planeacion.evaluacionIndicadores,
                    estiloCelda,
                  ),
                  _celdaTextoContenido(
                    planeacion.evaluacionInstrumentos,
                    estiloCelda,
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 5), // Espacio
          // Observaciones
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {0: const pw.FlexColumnWidth(1)},
            children: [
              pw.TableRow(
                children: [_celdaHeader("Observaciones", estiloCelda)],
              ),
              pw.TableRow(
                children: [
                  _celdaTextoContenido(planeacion.observaciones, estiloCelda),
                ],
              ),
            ],
          ),

          // Firmas
          pw.SizedBox(height: 60),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _lineaFirma("Nombre y Firma del Docente"),
              _lineaFirma("Vo.Bo. de la Dirección"),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // --- HELPERS ---

  static pw.Widget _celdaHeader(String texto, pw.TextStyle estilo) {
    return pw.Container(
      color: PdfColors.grey200,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        texto,
        style: estilo.copyWith(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _celdaTexto(String texto, pw.TextStyle estilo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(texto, style: estilo, textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _cuadritoConSigla(
    String sigla,
    bool marcado,
    pw.TextStyle estilo,
  ) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(sigla, style: estilo.copyWith(fontSize: 5)),
        pw.Container(
          width: 9,
          height: 9,
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
          child: marcado
              ? pw.Center(
                  child: pw.Text("X", style: estilo.copyWith(fontSize: 7)),
                )
              : null,
        ),
      ],
    );
  }



  // Helper para las etiquetas laterales (25% ancho, gris)
  static pw.Widget _celdaEtiquetaLateral(String texto, pw.TextStyle estilo) {
    return pw.Container(
      color: PdfColors.grey200,
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        texto,
        style: estilo.copyWith(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Helper para la información de la base de datos (75% ancho, blanco)
  static pw.Widget _celdaDatoLateral(String texto, pw.TextStyle estilo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(texto, style: estilo),
    );
  }

  // Helper para la fila de campos formativos (con checkbox)
  static pw.Widget _celdaCampoCheck(String nombre, pw.TextStyle estilo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      height: 45, // Altura fija para uniformidad
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(nombre, style: estilo.copyWith(fontSize: 6)),
          ),
        ],
      ),
    );
  }

  // Helper para la fila de contenidos de la BD
  static pw.Widget _celdaTextoContenido(String texto, pw.TextStyle estilo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      constraints: const pw.BoxConstraints(minHeight: 50),
      alignment: pw.Alignment.topLeft,
      child: pw.Text(texto, style: estilo.copyWith(fontSize: 6.5)),
    );
  }


  // Genera el cuadrito y pone una "X" si el texto de la BD coincide con el nombre del eje
  static pw.Widget _cuadroCheckboxDinamico(
    String nombreEje,
    String valorBD,
    pw.TextStyle estilo,
  ) {
    // Interpretar lista separada por comas en valorBD para marcar los que correspondan
    bool marcado = false;
    if (valorBD.trim().isNotEmpty) {
      final partes = valorBD
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      marcado = partes.contains(nombreEje.trim());
    }

    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(top: 5, bottom: 5, left: 5),
      child: pw.Container(
        width: 10,
        height: 10,
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
        child: marcado
            ? pw.Center(
                child: pw.Text("X", style: estilo.copyWith(fontSize: 7)),
              )
            : null,
      ),
    );
  }

  // Genera el texto del eje articulador
  static pw.Widget _cuadroTituloCentrado(String nombre, pw.TextStyle estilo) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: pw.Text(nombre, style: estilo.copyWith(fontSize: 5.5)),
    );
  }

  // Helper específico para mostrar Título (Negrita) + Descripción
  static pw.Widget _celdaContenidoActividad(
    String titulo,
    String descripcion,
    pw.TextStyle estiloBase,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      constraints: const pw.BoxConstraints(minHeight: 60),
      alignment: pw.Alignment.topLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: estiloBase.copyWith(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            descripcion,
            style: estiloBase.copyWith(
              fontWeight: pw.FontWeight.normal,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _lineaFirma(String textofirma) {
    return pw.Column(
      children: [
        pw.Container(
          width: 160,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(textofirma, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
