import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_crear_editar_cubit.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/injection_container.dart' as di;
import 'package:aula_plan/features/planeaciones/presentation/widgets/actividades_widget.dart';

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

  // Controladores
  late TextEditingController _nombreProyectoCtrl,
      _cicloEscolarCtrl,
      _FechaEntregaCtrl,
      _nombreEscuelaCtrl,
      _faseEducativaCtrl,
      _grupoCtrl;

  late String _nivelEducativo;
  late String _condicionAlumnado;

  late TextEditingController _temporalidadCtrl,
      _observacionesCtrl,
      _camposCtrl,
      _contenidosCtrl,
      _pdaCtrl,
      _metodologiaCtrl,
      _necesidadesCtrl,
      _disciplinaCtrl;
  late String _ejesArticuladores;
  late String _escenarios;

  late TextEditingController _organizacionGrupoCtrl,
      _espacioCtrl,
      _tiempoCtrl,
      _responsablesCtrl;
  late TextEditingController _indicadoresCtrl, _instrumentosCtrl;

  late List<Map<String, String>> _actividades;

  @override
  void initState() {
    super.initState();
    final p = widget.planeacionExistente;
    _nombreProyectoCtrl = TextEditingController(text: p?.nombreProyecto ?? '');
    _nombreEscuelaCtrl = TextEditingController(text: p?.nombreEscuela ?? '');
    _cicloEscolarCtrl = TextEditingController(text: p?.cicloEscolar ?? '');
    _FechaEntregaCtrl = TextEditingController(text: p?.fechaEntrega ?? '');
    _grupoCtrl = TextEditingController(text: p?.grupo ?? '');
    _nivelEducativo = p?.nivelEducativo ?? "INI";
    _condicionAlumnado = p?.condicionAlumnado ?? "AS";
    _faseEducativaCtrl = TextEditingController(text: p?.faseEducativa ?? '');
    _temporalidadCtrl = TextEditingController(text: p?.temporalidad ?? '');
    _observacionesCtrl = TextEditingController(text: p?.observaciones ?? '');
    _camposCtrl = TextEditingController(text: p?.camposFormativos ?? '');
    _contenidosCtrl = TextEditingController(text: p?.contenidos ?? '');
    _pdaCtrl = TextEditingController(text: p?.pda ?? '');
    _ejesArticuladores = p?.ejesArticuladores ?? "Inclusión";
    _escenarios = p?.escenarios ?? "Aulico";
    _metodologiaCtrl = TextEditingController(text: p?.metodologia ?? '');
    _necesidadesCtrl = TextEditingController(text: p?.necesidadesBap ?? '');
    _disciplinaCtrl = TextEditingController(text: p?.disciplina ?? '');
    _actividades = (p?.actividades ?? [])
        .map(
          (a) => {
            'titulo': a.titulo,
            'descripcion': a.descripcion,
            'materiales': a.materiales,
          },
        )
        .toList();
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
                            "Selecciona una fecha...",
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
                            "Diciplina",
                            Icons.air,
                            "Diciplina...",
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
                            _contenidosCtrl,
                            "Contenidos",
                            Icons.list_alt,
                            "Procesos...",
                            maxLines: 2,
                          ),
                          _customField(
                            _pdaCtrl,
                            "PDA",
                            Icons.ads_click,
                            "Procesos de desarrollo...",
                            maxLines: 2,
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
                              "Apropiación de las culturas a través de la lectura y la escritura",
                              "Igualdad de género",
                              "Vida saludable",
                            ],
                            onChanged: (val) =>
                                setState(() => _ejesArticuladores = val!),
                          ),
                          _buildCustomDropdown(
                            value: _escenarios,
                            label: "Escenario",
                            icon: Icons.location_on,
                            options: ["Aulico", "Escolar", "Comunitario"],
                            onChanged: (val) =>
                                setState(() => _escenarios = val!),
                          ),
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

                        _buildSeccionTitulo("ACTIVIDADES Y LOGÍSTICA"),
                        ActividadesWidget(
                          initial: _actividades,
                          onChanged: (nuevas) => _actividades = nuevas,
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
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildBotonGuardar(),
      ),
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

  //widget campos de texto
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
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          prefixIcon: Icon(icon, size: 22, color: zacTinto.withOpacity(0.7)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
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

  //widget campos de seleccion
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
              (option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontSize: 14),
                ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: zacTinto,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formato simple: YYYY-MM-DD
        _FechaEntregaCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildBotonGuardar() {
    return Builder(
      builder: (context) => Container(
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
            elevation: 5,
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
        contenidos: _contenidosCtrl.text,
        pda: _pdaCtrl.text,
        ejesArticuladores: _ejesArticuladores,
        escenarios: _escenarios,
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
      );
      context.read<PlaneacionCrearEditarCubit>().procesarPlaneacion(entidad);
    }
  }
}
