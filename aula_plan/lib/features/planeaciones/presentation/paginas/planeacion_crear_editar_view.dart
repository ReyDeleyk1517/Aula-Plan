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
      _faseEducativaCtrl,
      _grupoCtrl,
      _disciplinaCtrl,
      _temporalidadCtrl,
      _observacionesCtrl,
      _camposCtrl,
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
      _problematicaCtrl;

  late String _nivelEducativo, _condicionAlumnado, _ejesArticuladores;
  late bool _escAulicoSelected, _escEscolarSelected, _escComunitarioSelected;
  late List<Map<String, String>> _actividades;

  @override
  void initState() {
    super.initState();
    final p = widget.planeacionExistente;

    // Inicialización simplificada
    _nombreProyectoCtrl = TextEditingController(text: p?.nombreProyecto ?? '');
    _nombreEscuelaCtrl = TextEditingController(text: p?.nombreEscuela ?? '');
    _cicloEscolarCtrl = TextEditingController(text: p?.cicloEscolar ?? '');
    _FechaEntregaCtrl = TextEditingController(text: p?.fechaEntrega ?? '');
    _grupoCtrl = TextEditingController(text: p?.grupo ?? '');
    _faseEducativaCtrl = TextEditingController(text: p?.faseEducativa ?? '');
    _disciplinaCtrl = TextEditingController(text: p?.disciplina ?? '');
    _temporalidadCtrl = TextEditingController(text: p?.temporalidad ?? '');
    _observacionesCtrl = TextEditingController(text: p?.observaciones ?? '');
    _camposCtrl = TextEditingController(text: p?.camposFormativos ?? '');
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

    _nivelEducativo = p?.nivelEducativo ?? "INI";
    _condicionAlumnado = p?.condicionAlumnado ?? "AS";
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

  // Convierte texto en una lista de viñetas, separadas por una línea en blanco entre ítems
  String _bulletize(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    final bullets = lines.map((l) => '- $l').toList();
    return bullets.join('\n\n');
  }

  // Inserta el bloque de viñetas en el control correspondiente, asegurando separación
  void _smartAppend(TextEditingController ctrl, String nuevoTexto) {
    if (nuevoTexto.trim().isEmpty) return;
    final currentRaw = ctrl.text;
    final formatted = _bulletize(nuevoTexto);
    if (formatted.isEmpty) return;
    final prefix = currentRaw.trim().isEmpty ? '' : '\n\n';
    setState(() {
      ctrl.text = '$currentRaw$prefix$formatted';
    });
  }

  Future<void> _ejecutarBuscador() async {
    final result = await showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) => const BuscadorContenidosDialog(),
    );

    if (result != null && result is Map) {
      final String campo = result['campo'];
      final Map<String, List<String>> datos = result['datos'];

      // Determinar qué controlador de contenido usar
      TextEditingController? ctrlContenido;
      switch (campo) {
        case 'LEN':
          ctrlContenido = _contenidosLenguajeCtrl;
          break;
        case 'SyPC':
          ctrlContenido = _contenidosSaberesCtrl;
          break;
        case 'ENyS':
          ctrlContenido = _contenidosEticaCtrl;
          break;
        case 'DHyC':
          ctrlContenido = _contenidosHumanosCtrl;
          break;
      }

      // Iterar sobre cada contenido seleccionado
      datos.forEach((contenido, listaPdas) {
        // 1. Agregamos el título del contenido al controlador del campo formativo
        if (ctrlContenido != null) {
          _smartAppend(ctrlContenido, _bulletize(contenido));
        }

        // 2. Agregamos sus PDAs al controlador de PDAs
        // Formateamos cada PDA como viñeta y separamos con una línea en blanco
        final String pdasFormateados = listaPdas
            .map((pd) => '- $pd')
            .toList()
            .join('\n\n');
        _smartAppend(_pdaCtrl, pdasFormateados);
      });
    }
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
        body:
            BlocListener<
              PlaneacionCrearEditarCubit,
              PlaneacionCrearEditarState
            >(
              listener: (context, state) {
                if (state.status == FormStatus.exito)
                  Navigator.pop(context, true);
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
                        child: ListView(
                          padding: const EdgeInsets.all(16),
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
                                onTap: () =>
                                    _seleccionarFechaCalendario(context),
                              ),
                              _buildCustomDropdown(
                                value: _nivelEducativo,
                                label: "Nivel Educativo",
                                icon: Icons.layers,
                                options: ["INI", "PREE", "PRIM", "SEC", "BACH"],
                                onChanged: (val) =>
                                    setState(() => _nivelEducativo = val!),
                              ),
                              _buildCustomDropdown(
                                value: _condicionAlumnado,
                                label: "Condición Alumnado",
                                icon: Icons.psychology_alt,
                                options: ["AS", "D", "TEA", "TDAH", "TE"],
                                onChanged: (val) =>
                                    setState(() => _condicionAlumnado = val!),
                              ),
                              _customField(
                                _cicloEscolarCtrl,
                                "Ciclo Escolar",
                                Icons.calendar_month,
                                "2024-2025",
                              ),
                              _customField(
                                _faseEducativaCtrl,
                                "Fase Educativa",
                                Icons.category,
                                "Fase...",
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

                            _buildSeccionTitulo("CONTENIDO PEDAGÓGICO"),
                            _cardWrapper([
                              _customField(
                                _camposCtrl,
                                "Campos Formativos",
                                Icons.category,
                                "Lenguajes, Saberes...",
                                maxLines: 2,
                              ),
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
                                "Contenidos - De lo humno y comunitario",
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

                              // BOTÓN DE BÚSQUEDA PROPIO
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
                                    // Efecto visual al presionar
                                    padding: const EdgeInsets.symmetric(horizontal: 20), 
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
                                "Necesidades BAP",
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
                      if (status == FormStatus.cargando)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Text(
            "Escenarios",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), 
          Row(
            children: [
              Expanded(
                child: _buildChip(
                  "Aulico",
                  _escAulicoSelected,
                  (v) => setState(() => _escAulicoSelected = v),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildChip(
                  "Escolar",
                  _escEscolarSelected,
                  (v) => setState(() => _escEscolarSelected = v),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildChip(
                  "Comunitario",
                  _escComunitarioSelected,
                  (v) => setState(() => _escComunitarioSelected = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 11,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: zacTinto,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // Agrega el parámetro BuildContext
  Widget _buildBotonGuardar(BuildContext context) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        // Pasamos el contexto aquí
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
        condicionAlumnado: _condicionAlumnado,
        faseEducativa: _faseEducativaCtrl.text,
        grupo: _grupoCtrl.text,
        temporalidad: _temporalidadCtrl.text,
        necesidadesBap: _necesidadesCtrl.text,
        disciplina: _disciplinaCtrl.text,
        camposFormativos: _camposCtrl.text,
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
      );
      context.read<PlaneacionCrearEditarCubit>().procesarPlaneacion(entidad);
    }
  }
}
