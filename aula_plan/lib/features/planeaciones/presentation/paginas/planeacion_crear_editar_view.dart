import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_crear_editar_cubit.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/core/injection_container.dart' as di;

import 'package:aula_plan/features/planeaciones/presentation/widgets/fase_planeacion_widget.dart';

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

  late TextEditingController _nombreProyectoCtrl;
  late TextEditingController _nombreEscuelaCtrl;
  late TextEditingController _cicloCtrl;
  late TextEditingController _grupoCtrl;
  late TextEditingController _nivelCtrl;
  late TextEditingController _temporalidadCtrl;
  late TextEditingController _observacionesCtrl;
  late TextEditingController _camposCtrl;
  late TextEditingController _contenidosCtrl;
  late TextEditingController _pdaCtrl;
  late TextEditingController _escenariosCtrl;
  late TextEditingController _metodologiaCtrl;
  late TextEditingController _necesidadesCtrl;
  late TextEditingController _disciplinaCtrl;

  // Gestión de Fases (desarrollo de la planeación)
  late List<FasePlaneacionEntidad> _fases;

  PlaneacionEntidad? get planeacionExistente => widget.planeacionExistente;

  @override
  void initState() {
    super.initState();
    _nombreProyectoCtrl = TextEditingController(
      text: planeacionExistente?.nombreProyecto ?? '',
    );
    _nombreEscuelaCtrl = TextEditingController(
      text: planeacionExistente?.nombreEscuela ?? '',
    );
    _cicloCtrl = TextEditingController(
      text: planeacionExistente?.cicloEscolar ?? '',
    );
    _grupoCtrl = TextEditingController(text: planeacionExistente?.grupo ?? '');
    _nivelCtrl = TextEditingController(
      text: planeacionExistente?.nivelEducativo ?? '',
    );
    _temporalidadCtrl = TextEditingController(
      text: planeacionExistente?.temporalidad ?? '',
    );
    _observacionesCtrl = TextEditingController(
      text: planeacionExistente?.observaciones ?? '',
    );
    _camposCtrl = TextEditingController(
      text: planeacionExistente?.camposFormativos ?? '',
    );
    _contenidosCtrl = TextEditingController(
      text: planeacionExistente?.contenidos ?? '',
    );
    _pdaCtrl = TextEditingController(text: planeacionExistente?.pda ?? '');
    _escenariosCtrl = TextEditingController(
      text: planeacionExistente?.escenarios ?? '',
    );
    _metodologiaCtrl = TextEditingController(
      text: planeacionExistente?.metodologia ?? '',
    );
    _necesidadesCtrl = TextEditingController(
      text: planeacionExistente?.necesidadesBap ?? '',
    );
    _disciplinaCtrl = TextEditingController(
      text: planeacionExistente?.disciplina ?? '',
    );

    // Inicializar fases existentes (si las hay) para edición o conservarlas para creación
    _fases = List<FasePlaneacionEntidad>.from(planeacionExistente?.fases ?? []);
  }

  @override
  void dispose() {
    _nombreProyectoCtrl.dispose();
    _nombreEscuelaCtrl.dispose();
    _cicloCtrl.dispose();
    _grupoCtrl.dispose();
    _nivelCtrl.dispose();
    _temporalidadCtrl.dispose();
    _observacionesCtrl.dispose();
    _camposCtrl.dispose();
    _contenidosCtrl.dispose();
    _pdaCtrl.dispose();
    _escenariosCtrl.dispose();
    _metodologiaCtrl.dispose();
    _necesidadesCtrl.dispose();
    _disciplinaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = planeacionExistente != null;

    return BlocProvider(
      create: (_) => di.sl<PlaneacionCrearEditarCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Editar Planeación' : 'Nueva Planeación'),
        ),
        body:
            BlocListener<
              PlaneacionCrearEditarCubit,
              PlaneacionCrearEditarState
            >(
              listener: (context, state) {
                if (state.status == FormStatus.exito) {
                  // Devolvemos true para que la lista sepa que debe refrescarse
                  Navigator.pop(context, true);
                } else if (state.status == FormStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.mensajeError ?? 'Error')),
                  );
                }
              },
              child: Builder(
                // Builder para que context.watch funcione correctamente
                builder: (context) {
                  final status = context
                      .watch<PlaneacionCrearEditarCubit>()
                      .state
                      .status;

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              _buildTextFields(),
                              const SizedBox(height: 20),
                              _buildBotones(
                                context,
                              ), // Pasamos el context del Builder
                            ],
                          ),
                        ),
                      ),
                      if (status == FormStatus.cargando)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  );
                },
              ),
            ),
      ),
    );
  }

  Widget _buildBotones(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validar el formulario antes de procesar
            if (_formKey.currentState?.validate() ?? false) {
              // Si hay fases añadidas por el usuario en la UI, las usamos;
              // de lo contrario mantener las fases existentes de la planeación (si es edición).
              final fasesGuardadas = _fases.isNotEmpty
                  ? _fases
                  : widget.planeacionExistente?.fases ?? [];

              final entidad = PlaneacionEntidad(
                id: widget.planeacionExistente?.id,
                cicloEscolar: _cicloCtrl.text,
                nombreEscuela: _nombreEscuelaCtrl.text,
                nombreProyecto: _nombreProyectoCtrl.text,
                fechaEntrega: DateTime.now().toIso8601String(),
                nivelEducativo: _nivelCtrl.text,
                faseEducativa: widget.planeacionExistente?.faseEducativa ?? '',
                grupo: _grupoCtrl.text,
                condicionAlumnado:
                    widget.planeacionExistente?.condicionAlumnado ?? '',
                temporalidad: _temporalidadCtrl.text,
                necesidadesBap: _necesidadesCtrl.text,
                disciplina: _disciplinaCtrl.text,
                camposFormativos: _camposCtrl.text,
                contenidos: _contenidosCtrl.text,
                pda: _pdaCtrl.text,
                ejesArticuladores:
                    widget.planeacionExistente?.ejesArticuladores ?? '',
                escenarios: _escenariosCtrl.text,
                metodologia: _metodologiaCtrl.text,
                observaciones: _observacionesCtrl.text,
                fases: fasesGuardadas,
              );

              context.read<PlaneacionCrearEditarCubit>().procesarPlaneacion(
                entidad,
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nombreProyectoCtrl,
          decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
        ),
        TextFormField(
          controller: _nombreEscuelaCtrl,
          decoration: const InputDecoration(labelText: 'Nombre de la Escuela'),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cicloCtrl,
                decoration: const InputDecoration(labelText: 'Ciclo Escolar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _grupoCtrl,
                decoration: const InputDecoration(labelText: 'Grupo'),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _nivelCtrl,
          decoration: const InputDecoration(labelText: 'Nivel Educativo'),
        ),
        TextFormField(
          controller: _temporalidadCtrl,
          decoration: const InputDecoration(labelText: 'Temporalidad'),
        ),
        TextFormField(
          controller: _necesidadesCtrl,
          decoration: const InputDecoration(labelText: 'Necesidades BAP'),
        ),
        TextFormField(
          controller: _disciplinaCtrl,
          decoration: const InputDecoration(labelText: 'Disciplina'),
        ),
        TextFormField(
          controller: _camposCtrl,
          decoration: const InputDecoration(labelText: 'Campos Formativos'),
        ),
        TextFormField(
          controller: _contenidosCtrl,
          decoration: const InputDecoration(labelText: 'Contenidos'),
        ),
        TextFormField(
          controller: _pdaCtrl,
          decoration: const InputDecoration(labelText: 'PDA'),
        ),
        TextFormField(
          controller: _escenariosCtrl,
          decoration: const InputDecoration(labelText: 'Escenarios'),
        ),
        TextFormField(
          controller: _metodologiaCtrl,
          decoration: const InputDecoration(labelText: 'Metodología'),
        ),
        TextFormField(
          controller: _observacionesCtrl,
          decoration: const InputDecoration(labelText: 'Observaciones'),
          maxLines: 3,
        ),
        // Espacio para las fases dinámicas
        const SizedBox(height: 16),
        _buildFasesSection(),
      ],
    );
  }

  Widget _buildFasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FASES DE DESARROLLO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        // Renderiza cada fase existente/actualizada
        ..._fases.asMap().entries.map((entry) {
          final index = entry.key;
          final fase = entry.value;
          return FasePlaneacionWidget(
            index: index + 1,
            fase: fase,
            onChanged: (nueva) {
              setState(() {
                _fases[index] = nueva;
              });
            },
            onDelete: (idx) {
              setState(() {
                _fases.removeAt(idx);
              });
            },
          );
        }).toList(),
        // Botón para agregar una nueva fase
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _agregarNuevaFase,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('AGREGAR FASE'),
        ),
      ],
    );
  }

  void _agregarNuevaFase() {
    setState(() {
      _fases.add(FasePlaneacionEntidad(
        id: null,
        idPlaneacion: null,
        fasesDesarrollo: '',
        actividades: '',
        materialesRecursos: '',
        organizacionGrupo: '',
        espacio: '',
        tiempo: '',
        responsables: '',
        evaluacionIndicadores: '',
        evaluacionInstrumentos: '',
      ));
    });
  }
}
