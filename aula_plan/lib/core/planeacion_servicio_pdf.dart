import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get_it/get_it.dart';
import 'package:aula_plan/features/Perfil/domain/casos%20de%20uso/perfil_casos_uso.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:flutter/services.dart' show rootBundle;

final sl = GetIt.instance;

class PlaneacionServicioPdf {
  static const List<String> _opcionesAcompanamiento = [
    "1. Ayudar a un alumno y sentarse a su lado",
    "2. Ayudar a un alumno aumentando progresivamente la distancia",
    "3. Se agrupan temporalmente unos alumnos dentro del aula",
    "4. La maestra especialista se va desplazando por el aula apoyando a todos los alumnos",
    "5. Trabajo en grupos heterogéneos: trabajo cooperativo",
    "6. Los dos maestros conducen la actividad conjuntamente y dirigen el grupo juntos",
    "7. La maestra especialista conduce la actividad",
    "8. La maestra especialista prepara material para la clase",
  ];

  static Future<Uint8List> generarPdfPlaneacion(
    PlaneacionEntidad planeacion,
  ) async {
    final pdf = pw.Document();

    //logo
    final ByteData bytes = await rootBundle.load(
      //'assets/images/logo_secretaria.jpg',
      'assets/images/logo_edu_esp_z18f.png',
    );
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImagen = pw.MemoryImage(logoBytes);

    final List<String> assetsCampos = [
      'assets/images/logo_lenguajes.png',
      'assets/images/logo_saberes_y_pensamiento_cientifico.png',
      'assets/images/logo_de_lo_humano.png',
      'assets/images/logo_etica_naturaleza_y_sociedad.png',
    ];

    List<pw.MemoryImage> logosCampos = [];
    for (String path in assetsCampos) {
      final data = await rootBundle.load(path);
      logosCampos.add(pw.MemoryImage(data.buffer.asUint8List()));
    }

    final obtenerPerfil = sl<ObtenerRegistrosPerfil>();
    final listaPerfiles = await obtenerPerfil();
    final perfil = listaPerfiles.isNotEmpty ? listaPerfiles.first : null;
    final nombreDocente = perfil != null
        ? "${perfil.nombre} ${perfil.apellidos}".toUpperCase()
        : "NOMBRE DEL DOCENTE";
    final zonaEscolar = perfil?.zona_escolar;

    final estiloTitulo = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final estiloCelda = pw.TextStyle(fontSize: 7);
    final estiloSigla = pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
    );

    final condicionesGuardadas = planeacion.condicionAlumnado
        .split(',')
        .map((e) => e.trim())
        .toSet(); // Usar Set para habilitar busqueda con .contains

    final nivelesSeleccionados = planeacion.nivelEducativo
        .split(',')
        .map(
          (e) => e.trim().toUpperCase(),
        ) // Forzamos mayúsculas para evitar errores
        .toSet();

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
              width: 150,
              height: 150,
            ), // Ajusta el tamaño
          ),
          // ENCABEZADO INSTITUCIONAL ---
          pw.Center(
            child: pw.Column(
              children: [
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
                  "ZONA ESCOLAR ${zonaEscolar} EDUCACIÓN ESPECIAL",
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

          // FECHA DE ENTREGA
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
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _cuadritoConSigla(
                        "INI",
                        nivelesSeleccionados,
                        estiloSigla,
                      ),
                      _cuadritoConSigla(
                        "PREE",
                        nivelesSeleccionados,
                        estiloSigla,
                      ),
                      _cuadritoConSigla(
                        "PRIM",
                        nivelesSeleccionados,
                        estiloSigla,
                      ),
                      _cuadritoConSigla(
                        "SEC",
                        nivelesSeleccionados,
                        estiloSigla,
                      ),
                      _cuadritoConSigla(
                        "BACH",
                        nivelesSeleccionados,
                        estiloSigla,
                      ),
                    ],
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
                          condicionesGuardadas,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "D",
                          condicionesGuardadas,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TEA",
                          condicionesGuardadas,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TDAH",
                          condicionesGuardadas,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "TE",
                          condicionesGuardadas,
                          estiloSigla,
                        ),
                        _cuadritoConSigla(
                          "Regular",
                          condicionesGuardadas,
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
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Temporalidad", estiloCelda),
                  _celdaDatoLateral(planeacion.temporalidad, estiloCelda),
                ],
              ),
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral(
                    "Necesidades, Intereses, Problematicas (NIP) y Barreras para el Aprendizaje y la Participación (BAP) identificadas en el Programa analítico.",
                    estiloCelda.copyWith(fontSize: 6.5),
                  ),
                  _celdaDatoLateral(planeacion.necesidadesBap, estiloCelda),
                ],
              ),
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
              pw.TableRow(
                children: [
                  _celdaCampo("Lenguajes", logosCampos[0], estiloSigla),
                  _celdaCampo(
                    "Saberes y pensamiento científico",
                    logosCampos[1],
                    estiloSigla,
                  ),
                  _celdaCampo(
                    "De lo humano y lo comunitario.",
                    logosCampos[2],
                    estiloSigla,
                  ),
                  _celdaCampo(
                    "Ética, Naturaleza y sociedades",
                    logosCampos[3],
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
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  _celdaHeader(
                    "Proceso (s) de desarrollo de aprendizaje (PDA)",
                    estiloCelda,
                  ),
                  _celdaHeader("Problemática", estiloCelda),
                ],
              ),
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
              0: const pw.FlexColumnWidth(0.3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(0.3),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(0.3),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(0.3),
              7: const pw.FlexColumnWidth(1),
            },
            children: [
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
                    "Campana de género", // Mantenemos tu texto exacto de BD
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
                  pw.Container(),
                  pw.Container(),
                ],
              ),
            ],
          ),

          // ESCENARIOS
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(0.3),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(0.3),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(0.3),
              6: const pw.FlexColumnWidth(1),
              7: const pw.FlexColumnWidth(0.3),
              8: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  //Escenarios pero en texto debe decir contextos
                  _celdaEtiquetaLateral("Contexto (s):", estiloCelda),
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
                  _cuadroCheckboxDinamico(
                    "Familiar",
                    planeacion.escenarios,
                    estiloSigla,
                  ),
                  _cuadroTituloCentrado("Familiar", estiloSigla),
                ],
              ),
            ],
          ),

          // --- NUEVA SECCIÓN DE ACOMPAÑAMIENTOS CON CUADRO PROPIO ---
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                children: [
                  _celdaHeader("Tipos de Acompañamiento", estiloCelda),
                ],
              ),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.12), // Checkbox Col 1
              1: const pw.FlexColumnWidth(1.0), // Texto Col 1
              2: const pw.FlexColumnWidth(0.12), // Checkbox Col 2
              3: const pw.FlexColumnWidth(1.0), // Texto Col 2
            },
            children: [
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[0],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[0],
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[1],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[1],
                    estiloSigla,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[2],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[2],
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[3],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[3],
                    estiloSigla,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[4],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[4],
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[5],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[5],
                    estiloSigla,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[6],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[6],
                    estiloSigla,
                  ),
                  _cuadroCheckboxDinamico(
                    _opcionesAcompanamiento[7],
                    planeacion.acompanamientos ?? "",
                    estiloSigla,
                  ),
                  _cuadroTextoAcompanamiento(
                    _opcionesAcompanamiento[7],
                    estiloSigla,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 2), // Separador sutil pos-tabla
          // METODOLOGIA Y PROYECTO
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.77),
              1: const pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Metodologia:", estiloCelda),
                  _celdaDatoLateral(planeacion.metodologia, estiloCelda),
                ],
              ),
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("Nombre del proyecto:", estiloCelda),
                  _celdaDatoLateral(planeacion.nombreProyecto, estiloCelda),
                ],
              ),
              pw.TableRow(
                children: [
                  _celdaEtiquetaLateral("FASE/MOMENTO/ETAPA", estiloCelda),
                  _celdaDatoLateral(
                    planeacion.faseMomentoEtapa ?? "",
                    estiloCelda,
                  ),
                ],
              ),
            ],
          ),

          // SECCIÓN DINÁMICA: ACTIVIDADES Y MATERIALES
          ...planeacion.actividades.map((actividad) {
            return pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    _celdaHeader("Actividad", estiloCelda),
                    _celdaHeader("Materiales y/o recursos", estiloCelda),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _celdaContenidoActividad(
                      actividad.titulo,
                      actividad.descripcion,
                      estiloCelda,
                    ),
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
              pw.TableRow(
                children: [
                  _celdaHeader("Organización del grupo", estiloCelda),
                  _celdaHeader("Espacio", estiloCelda),
                  _celdaHeader("Tiempo de realización", estiloCelda),
                  _celdaHeader("Responsable(s)", estiloCelda),
                ],
              ),
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
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _celdaHeader("Indicadores", estiloCelda),
                  _celdaHeader("Instrumentos", estiloCelda),
                ],
              ),
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

          pw.SizedBox(height: 5),

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
    Set<String> condiciones,
    pw.TextStyle estilo,
  ) {
    bool marcado = condiciones.contains(sigla);

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

  static pw.Widget _celdaDatoLateral(String texto, pw.TextStyle estilo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(texto, style: estilo),
    );
  }

  static pw.Widget _celdaCampo(
    String nombre,
    pw.MemoryImage logo,
    pw.TextStyle estilo,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      height: 45,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(logo, width: 20, height: 20),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(nombre, style: estilo.copyWith(fontSize: 6)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _celdaTextoContenido(String texto, pw.TextStyle estilo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      constraints: const pw.BoxConstraints(minHeight: 50),
      alignment: pw.Alignment.topLeft,
      child: pw.Text(texto, style: estilo.copyWith(fontSize: 6.5)),
    );
  }

  static pw.Widget _cuadroCheckboxDinamico(
    String nombreEje,
    String valorBD,
    pw.TextStyle estilo,
  ) {
    bool marcado = false;
    if (valorBD.trim().isNotEmpty) {
      // Usamos una expresión regular para separar ya sea por coma (,) o por punto y coma (;)
      final partes = valorBD
          .split(RegExp(r'[,;]'))
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

  static pw.Widget _cuadroTituloCentrado(String nombre, pw.TextStyle estilo) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: pw.Text(nombre, style: estilo.copyWith(fontSize: 5.5)),
    );
  }

  // Helper adaptado para los textos largos de acompañamiento alineados a la izquierda
  static pw.Widget _cuadroTextoAcompanamiento(
    String nombre,
    pw.TextStyle estilo,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(nombre, style: estilo.copyWith(fontSize: 5.5)),
    );
  }

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
