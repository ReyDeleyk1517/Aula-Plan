import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_crear_editar_cubit.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/injection_container.dart' as di;
import 'package:aula_plan/features/planeaciones/presentation/widgets/actividades_widget.dart';
import 'package:aula_plan/features/planeaciones/presentation/widgets/buscador_contenido.dart';

class PlaneacionCrearEditarView extends StatefulWidget {
  final PlaneacionEntidad? planeacionExistente;

  const PlaneacionCrearEditarView({Key? key, this.planeacionExistente})
    : super(key: key);

  @override
  _PlaneacionCrearEditarViewState createState() =>
      _PlaneacionCrearEditarViewState();
}

class _PlaneacionCrearEditarViewState extends State<PlaneacionCrearEditarView> {
  final _formKey = GlobalKey<FormState>();
  final Color zacTinto = const Color(0xFF8B1D1D);

  // Agrupamos controladores para inicialización limpia
  late TextEditingController _nombreProyectoCtrl,
      _cicloEscolarCtrl,
      _FechaEntregaCtrl,
      _nombreEscuelaCtrl,
      _grupoCtrl,
      _disciplinaCtrl,
      _temporalidadCtrl,
      _observacionesCtrl,
      _contenidosLenguajeCtrl,
      _contenidosSaberesCtrl,
      _contenidosHumanosCtrl,
      _contenidosEticaCtrl,
      _pdaCtrl,
      _metodologiaCtrl,
      _necesidadesCtrl,
      _organizacionGrupoCtrl,
      _espacioCtrl,
      _tiempoCtrl,
      _responsablesCtrl,
      _indicadoresCtrl,
      _instrumentosCtrl,
      _problematicaCtrl,
      _faseMomentoEtapaCtrl;

  late List<String> _fasesSeleccionadas;
  late List<String> _condicionesSeleccionadas;

  late String _nivelEducativo, _ejesArticuladores;
  late bool _escAulicoSelected, _escEscolarSelected, _escComunitarioSelected;
  late List<Map<String, String>> _actividades;

  @override
  void initState() {
    super.initState();
    final p = widget.planeacionExistente;

    // Inicialización
    _nombreProyectoCtrl = TextEditingController(text: p?.nombreProyecto ?? '');
    _nombreEscuelaCtrl = TextEditingController(text: p?.nombreEscuela ?? '');
    _cicloEscolarCtrl = TextEditingController(text: p?.cicloEscolar ?? '');
    _FechaEntregaCtrl = TextEditingController(text: p?.fechaEntrega ?? '');
    _grupoCtrl = TextEditingController(text: p?.grupo ?? '');
    _disciplinaCtrl = TextEditingController(text: p?.disciplina ?? '');
    _temporalidadCtrl = TextEditingController(text: p?.temporalidad ?? '');
    _observacionesCtrl = TextEditingController(text: p?.observaciones ?? '');
    _contenidosLenguajeCtrl = TextEditingController(
      text: p?.contenidos_lenguaje ?? '',
    );
    _contenidosSaberesCtrl = TextEditingController(
      text: p?.contenidos_saberes_y_pensamiento_cientifico ?? '',
    );
    _contenidosHumanosCtrl = TextEditingController(
      text: p?.contenidos_de_lo_humano_y_comunitario ?? '',
    );
    _contenidosEticaCtrl = TextEditingController(
      text: p?.contenidos_etica_naturaleza_y_sociedad ?? '',
    );
    _pdaCtrl = TextEditingController(text: p?.pda ?? '');
    _metodologiaCtrl = TextEditingController(text: p?.metodologia ?? '');
    _necesidadesCtrl = TextEditingController(text: p?.necesidadesBap ?? '');
    _organizacionGrupoCtrl = TextEditingController(
      text: p?.organizacionGrupo ?? '',
    );
    _espacioCtrl = TextEditingController(text: p?.espacio ?? '');
    _tiempoCtrl = TextEditingController(text: p?.tiempo ?? '');
    _responsablesCtrl = TextEditingController(text: p?.responsables ?? '');
    _indicadoresCtrl = TextEditingController(
      text: p?.evaluacionIndicadores ?? '',
    );
    _instrumentosCtrl = TextEditingController(
      text: p?.evaluacionInstrumentos ?? '',
    );
    _problematicaCtrl = TextEditingController(text: p?.problematica ?? '');
    _faseMomentoEtapaCtrl = TextEditingController(
      text: p?.faseMomentoEtapa ?? '',
    );

    _nivelEducativo = p?.nivelEducativo ?? "INI";

    final fasesString = p?.faseEducativa ?? '';
    _fasesSeleccionadas = fasesString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final condicionesString = p?.condicionAlumnado ?? '';
    _condicionesSeleccionadas = condicionesString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _ejesArticuladores = p?.ejesArticuladores ?? "Inclusión";

    final tokens = (p?.escenarios ?? '').split(',').map((s) => s.trim());
    _escAulicoSelected = tokens.contains('Aulico');
    _escEscolarSelected = tokens.contains('Escolar');
    _escComunitarioSelected = tokens.contains('Comunitario');

    _actividades = (p?.actividades ?? [])
        .map(
          (a) => {
            'titulo': a.titulo,
            'descripcion': a.descripcion,
            'materiales': a.materiales,
          },
        )
        .toList();
  }

  void _smartAppend(TextEditingController ctrl, String nuevoTexto) {
    if (nuevoTexto.trim().isEmpty) return;

    final formatted = _bulletize(nuevoTexto);
    if (formatted.isEmpty) return;

    final currentRaw = ctrl.text.trim();
    final prefix = currentRaw.isEmpty ? '' : '\n\n';

    setState(() {
      ctrl.text = '$currentRaw$prefix$formatted';
    });
  }

  String _bulletize(String text) {
    return text
        .split('\n')
        .map((linea) => linea.trim())
        .where((linea) => linea.isNotEmpty)
        .map((linea) => linea.startsWith('-') ? linea : '- $linea')
        .join('\n\n');
  }

  void _ejecutarBuscador() async {
    final resultado = await showDialog<Map<String, Map<String, List<String>>>>(
      context: context,
      builder: (context) => BuscadorContenidosDialog(
        fasesHabilitadas: _fasesSeleccionadas,
      ),
    );

    if (resultado != null && resultado.isNotEmpty) {
      resultado.forEach((campo, contenidosMap) {
        final String contenidosTexto = contenidosMap.keys.join('\n');
        final String pdasTexto = contenidosMap.values
            .expand((lista) => lista)
            .join('\n');

        switch (campo) {
          case 'LEN':
            _smartAppend(_contenidosLenguajeCtrl, contenidosTexto);
            break;
          case 'SyPC':
            _smartAppend(_contenidosSaberesCtrl, contenidosTexto);
            break;
          case 'ENyS':
            _smartAppend(_contenidosEticaCtrl, contenidosTexto);
            break;
          case 'DHyC':
            _smartAppend(_contenidosHumanosCtrl, contenidosTexto);
            break;
        }

        if (pdasTexto.isNotEmpty) {
          _smartAppend(
            _pdaCtrl,
            "PDA de ${_nombresCompletos(campo)}:\n$pdasTexto",
          );
        }
      });
    }
  }

  String _nombresCompletos(String campo) {
    const nombres = {
      'LEN': 'Lenguajes',
      'SyPC': 'Saberes y P.C.',
      'ENyS': 'Ética, Nat. y Soc.',
      'DHyC': 'De lo Humano y Com.',
    };
    return nombres[campo] ?? campo;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.planeacionExistente != null;

    return BlocProvider(
      create: (_) => di.sl<PlaneacionCrearEditarCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: zacTinto,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isEdit ? 'Editar Planeación' : 'Nueva Planeación',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocListener<PlaneacionCrearEditarCubit, PlaneacionCrearEditarState>(
          listener: (context, state) {
            if (state.status == FormStatus.exito) Navigator.pop(context, true);
            if (state.status == FormStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.mensajeError ?? 'Error')),
              );
            }
          },
          child: Builder(
            builder: (context) {
              final status = context
                  .watch<PlaneacionCrearEditarCubit>()
                  .state
                  .status;
              return Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSeccionTitulo("DATOS GENERALES"),
                          _cardWrapper([
                            _customField(
                              _nombreProyectoCtrl,
                              "Proyecto",
                              Icons.auto_stories,
                              "Nombre del proyecto...",
                            ),
                            _customField(
                              _nombreEscuelaCtrl,
                              "Escuela",
                              Icons.school,
                              "Nombre de la escuela...",
                            ),
                            _customField(
                              _FechaEntregaCtrl,
                              "Fecha de entrega",
                              Icons.event_available,
                              "Selecciona...",
                              readOnly: true,
                              onTap: () => _seleccionarFechaCalendario(context),
                            ),
                            _buildCustomDropdown(
                              value: _nivelEducativo,
                              label: "Nivel Educativo",
                              icon: Icons.layers,
                              options: ["INI", "PREE", "PRIM", "SEC", "BACH"],
                              onChanged: (val) =>
                                  setState(() => _nivelEducativo = val!),
                            ),
                            _customField(
                              _cicloEscolarCtrl,
                              "Ciclo Escolar",
                              Icons.calendar_month,
                              "2024-2025",
                            ),
                            _buildMultiSelectSection(
                              titulo: "Condición del Alumnado",
                              opciones: [
                                "AS",
                                "D",
                                "TEA",
                                "TDAH",
                                "TE",
                                "Regular",
                              ],
                              seleccionados: _condicionesSeleccionadas,
                              onSelected: (opt, val) {
                                setState(() {
                                  val
                                      ? _condicionesSeleccionadas.add(opt)
                                      : _condicionesSeleccionadas.remove(opt);
                                });
                              },
                            ),
                            _buildMultiSelectSection(
                              titulo: "Fases Educativas",
                              opciones: [
                                "Fase 2",
                                "Fase 3",
                                "Fase 4",
                                "Fase 5",
                                "Fase 6",
                              ],
                              seleccionados: _fasesSeleccionadas,
                              onSelected: (opt, val) {
                                setState(() {
                                  val
                                      ? _fasesSeleccionadas.add(opt)
                                      : _fasesSeleccionadas.remove(opt);
                                });
                              },
                            ),
                            _customField(
                              _grupoCtrl,
                              "Grado y Grupo",
                              Icons.group,
                              "6B...",
                            ),
                            _customField(
                              _disciplinaCtrl,
                              "Disciplina",
                              Icons.air,
                              "Disciplina...",
                            ),
                          ]),

                          _buildSeccionTitulo("CAMPOS FORMATIVOS Y CONTENIDO PEDAGÓGICO"),
                          _cardWrapper([
                            _customField(
                              _contenidosLenguajeCtrl,
                              "Contenidos - Lenguaje",
                              Icons.list_alt,
                              "Contenido...",
                              maxLines: 5,
                            ),
                            _customField(
                              _contenidosSaberesCtrl,
                              "Contenidos - Saberes y pensamiento cientifico",
                              Icons.list_alt,
                              "Contenido...",
                              maxLines: 5,
                            ),
                            _customField(
                              _contenidosHumanosCtrl,
                              "Contenidos - De lo humano y comunitario",
                              Icons.list_alt,
                              "Contenido...",
                              maxLines: 5,
                            ),
                            _customField(
                              _contenidosEticaCtrl,
                              "Contenidos - Ética naturaleza y sociedad",
                              Icons.list_alt,
                              "Contenido...",
                              maxLines: 5,
                            ),
                            _customField(
                              _pdaCtrl,
                              "PDA",
                              Icons.ads_click,
                              "Procesos de desarrollo...",
                              maxLines: 8,
                            ),
                            _customField(
                              _problematicaCtrl,
                              "Problemática",
                              Icons.warning,
                              "Describe la problemática...",
                              maxLines: 3,
                            ),
                            _customField(
                              _faseMomentoEtapaCtrl,
                              "Fase Momento Etapa",
                              Icons.timeline,
                              "Describe la fase, momento o etapa...",
                              maxLines: 2,
                            ),

                            // BOTÓN DE BÚSQUEDA
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: ElevatedButton.icon(
                                onPressed: _ejecutarBuscador,
                                icon: const Icon(Icons.search_rounded, size: 24),
                                label: const Text(
                                  "BUSCAR CONTENIDOS Y PDA",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: zacTinto,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                ),
                              ),
                            ),
                            _buildCustomDropdown(
                              value: _ejesArticuladores,
                              label: "Ejes Articuladores",
                              icon: Icons.hub,
                              options: [
                                "Inclusión",
                                "Artes y expresión estética",
                                "Interculturalidad crítica",
                                "Pensamiento crítico",
                                "Apropiación de las culturas",
                                "Igualdad de género",
                                "Vida saludable",
                              ],
                              onChanged: (val) =>
                                  setState(() => _ejesArticuladores = val!),
                            ),
                            _buildEscenariosSection(),
                            _customField(
                              _necesidadesCtrl,
                              "Necesidades, Intereses, Problematicas (NIP) y Barreras para el Aprendizaje y la Participación (BAP)",
                              Icons.assist_walker,
                              "Describa barreras...",
                            ),
                            _customField(
                              _metodologiaCtrl,
                              "Metodología",
                              Icons.account_tree,
                              "ABP, STEAM...",
                            ),
                            _customField(
                              _temporalidadCtrl,
                              "Temporalidad",
                              Icons.timer,
                              "Quincenal...",
                            ),
                          ]),

                          _buildSeccionTitulo("ACTIVIDADES"),
                          ActividadesWidget(
                            initial: _actividades,
                            onChanged: (n) => _actividades = n,
                          ),
                          const SizedBox(height: 15),
                          _cardWrapper([
                            _customField(
                              _organizacionGrupoCtrl,
                              "Organización",
                              Icons.groups_3,
                              "Grupal, equipos...",
                            ),
                            _customField(
                              _espacioCtrl,
                              "Espacio",
                              Icons.place,
                              "Aula, patio...",
                            ),
                            _customField(
                              _tiempoCtrl,
                              "Tiempo estimado",
                              Icons.hourglass_top,
                              "45 min...",
                            ),
                            _customField(
                              _responsablesCtrl,
                              "Responsables",
                              Icons.person_search,
                              "Docente, apoyo...",
                            ),
                          ]),

                          _buildSeccionTitulo("EVALUACIÓN"),
                          _cardWrapper([
                            _customField(
                              _indicadoresCtrl,
                              "Indicadores",
                              Icons.checklist_rtl,
                              "Qué evaluar...",
                            ),
                            _customField(
                              _instrumentosCtrl,
                              "Instrumentos",
                              Icons.architecture,
                              "Rúbrica...",
                            ),
                            _customField(
                              _observacionesCtrl,
                              "Observaciones",
                              Icons.note_alt,
                              "Notas...",
                              maxLines: 3,
                            ),
                          ]),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  if (status == FormStatus.cargando)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(
          builder: (contextInner) {
            return _buildBotonGuardar(contextInner);
          },
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildMultiSelectSection({
    required String titulo,
    required List<String> opciones,
    required List<String> seleccionados,
    required Function(String, bool) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: zacTinto.withOpacity(0.8),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opciones.map((opt) {
              final isSelected = seleccionados.contains(opt);
              return GestureDetector(
                onTap: () => onSelected(opt, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? zacTinto : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? zacTinto : zacTinto.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: zacTinto.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        size: 16,
                        color: isSelected ? Colors.white : zacTinto,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        opt,
                        style: TextStyle(
                          color: isSelected ? Colors.white : zacTinto,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 15),
      child: Text(
        titulo,
        style: TextStyle(
          color: zacTinto,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _cardWrapper(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _customField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22, color: zacTinto.withOpacity(0.7)),
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildEscenariosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Escenarios",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: zacTinto.withOpacity(0.8),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildChip(
                "Aulico",
                _escAulicoSelected,
                (v) => setState(() => _escAulicoSelected = v),
              ),
              _buildChip(
                "Escolar",
                _escEscolarSelected,
                (v) => setState(() => _escEscolarSelected = v),
              ),
              _buildChip(
                "Comunitario",
                _escComunitarioSelected,
                (v) => setState(() => _escComunitarioSelected = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? zacTinto : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? zacTinto : zacTinto.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: zacTinto.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 16,
              color: isSelected ? Colors.white : zacTinto,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : zacTinto,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22, color: zacTinto.withOpacity(0.7)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaCalendario(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: zacTinto)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => _FechaEntregaCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
      );
    }
  }

  Widget _buildBotonGuardar(BuildContext context) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: () => _guardar(context),
        icon: const Icon(Icons.save_as, color: Colors.white),
        label: const Text(
          "GUARDAR PLANEACIÓN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: zacTinto,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  void _guardar(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final entidad = PlaneacionEntidad(
        id: widget.planeacionExistente?.id,
        cicloEscolar: _cicloEscolarCtrl.text,
        nombreEscuela: _nombreEscuelaCtrl.text,
        nombreProyecto: _nombreProyectoCtrl.text,
        fechaEntrega: _FechaEntregaCtrl.text,
        nivelEducativo: _nivelEducativo,
        faseEducativa: _fasesSeleccionadas.join(', '),
        condicionAlumnado: _condicionesSeleccionadas.join(', '),
        grupo: _grupoCtrl.text,
        temporalidad: _temporalidadCtrl.text,
        necesidadesBap: _necesidadesCtrl.text,
        disciplina: _disciplinaCtrl.text,
        camposFormativos: '',
        contenidos_lenguaje: _contenidosLenguajeCtrl.text,
        contenidos_saberes_y_pensamiento_cientifico:
            _contenidosSaberesCtrl.text,
        contenidos_de_lo_humano_y_comunitario: _contenidosHumanosCtrl.text,
        contenidos_etica_naturaleza_y_sociedad: _contenidosEticaCtrl.text,
        pda: _pdaCtrl.text,
        ejesArticuladores: _ejesArticuladores,
        escenarios: [
          _escAulicoSelected ? 'Aulico' : '',
          _escEscolarSelected ? 'Escolar' : '',
          _escComunitarioSelected ? 'Comunitario' : '',
        ].where((s) => s.isNotEmpty).join(', '),
        metodologia: _metodologiaCtrl.text,
        observaciones: _observacionesCtrl.text,
        organizacionGrupo: _organizacionGrupoCtrl.text,
        actividades: _actividades
            .map(
              (m) => ActividadPlaneacionEntidad(
                titulo: m['titulo'] ?? '',
                descripcion: m['descripcion'] ?? '',
                materiales: m['materiales'] ?? '',
                idPlaneacion: widget.planeacionExistente?.id,
              ),
            )
            .toList(),
        espacio: _espacioCtrl.text,
        tiempo: _tiempoCtrl.text,
        responsables: _responsablesCtrl.text,
        evaluacionIndicadores: _indicadoresCtrl.text,
        evaluacionInstrumentos: _instrumentosCtrl.text,
        problematica: _problematicaCtrl.text,
        faseMomentoEtapa: _faseMomentoEtapaCtrl.text,
      );
      context.read<PlaneacionCrearEditarCubit>().procesarPlaneacion(entidad);
    }
  }
}