import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entidades/planeacion_entidades.dart';
import '../../domain/casos_uso/planeacion_casos_uso.dart';

class PlaneacionState {
  final bool cargando;
  final List<PlaneacionEntidad> planeaciones; // Lista original (master)
  final List<PlaneacionEntidad> planeacionesFiltradas; // Lista para la UI
  final String? error;

  // Valores de los filtros
  final String filtroNombreProyecto;
  final String filtroNombreEscuela;
  final String filtroFechaEntrega;
  final String filtroFechaCreacionDesde;
  final String filtroFechaCreacionHasta;
  final String filtroFaseMomentoEtapa;
  final String filtroCicloEscolar;
  final String filtroNivelEducativo;
  final String filtroGradoGrupo;
  final String filtroFaseEducativa;

  final List<int> selectedPlaneacionIds;

  PlaneacionState({
    this.cargando = false,
    this.planeaciones = const [],
    this.planeacionesFiltradas = const [],
    this.error,
    this.filtroNombreProyecto = "",
    this.filtroNombreEscuela = "",
    this.filtroFechaEntrega = "",
    this.filtroFechaCreacionDesde = "",
    this.filtroFechaCreacionHasta = "",
    this.filtroFaseMomentoEtapa = "",
    this.filtroCicloEscolar = "",
    this.filtroNivelEducativo = "",
    this.filtroGradoGrupo = "",
    this.filtroFaseEducativa = "",
    this.selectedPlaneacionIds = const [],
  });

  PlaneacionState copyWith({
    bool? cargando,
    List<PlaneacionEntidad>? planeaciones,
    List<PlaneacionEntidad>? planeacionesFiltradas,
    String? error,
    String? filtroNombreProyecto,
    String? filtroNombreEscuela,
    String? filtroFechaEntrega,
    String? filtroFechaCreacionDesde,
    String? filtroFechaCreacionHasta,
    String? filtroFaseMomentoEtapa,
    String? filtroCicloEscolar,
    String? filtroNivelEducativo,
    String? filtroGradoGrupo,
    String? filtroFaseEducativa,
    List<int>? selectedPlaneacionIds,
  }) {
    return PlaneacionState(
      cargando: cargando ?? this.cargando,
      planeaciones: planeaciones ?? this.planeaciones,
      planeacionesFiltradas:
          planeacionesFiltradas ?? this.planeacionesFiltradas,
      error: error ?? this.error,
      filtroNombreProyecto: filtroNombreProyecto ?? this.filtroNombreProyecto,
      filtroNombreEscuela: filtroNombreEscuela ?? this.filtroNombreEscuela,
      filtroFechaEntrega: filtroFechaEntrega ?? this.filtroFechaEntrega,
      filtroFechaCreacionDesde:
          filtroFechaCreacionDesde ?? this.filtroFechaCreacionDesde,
      filtroFechaCreacionHasta:
          filtroFechaCreacionHasta ?? this.filtroFechaCreacionHasta,
      filtroFaseMomentoEtapa:
          filtroFaseMomentoEtapa ?? this.filtroFaseMomentoEtapa,
      filtroCicloEscolar: filtroCicloEscolar ?? this.filtroCicloEscolar,
      filtroNivelEducativo: filtroNivelEducativo ?? this.filtroNivelEducativo,
      filtroGradoGrupo: filtroGradoGrupo ?? this.filtroGradoGrupo,
      filtroFaseEducativa: filtroFaseEducativa ?? this.filtroFaseEducativa,
      selectedPlaneacionIds:
          selectedPlaneacionIds ?? this.selectedPlaneacionIds,
    );
  }
}

class PlaneacionCubit extends Cubit<PlaneacionState> {
  final ObtenerPlaneaciones obtenerPlaneaciones;
  final EliminarPlaneacion eliminarPlaneacion;

  PlaneacionCubit({
    required this.obtenerPlaneaciones,
    required this.eliminarPlaneacion,
  }) : super(PlaneacionState(cargando: true));

  Future<void> cargarPlaneaciones() async {
    emit(state.copyWith(cargando: true, error: null));
    try {
      final lista = await obtenerPlaneaciones();
      emit(
        state.copyWith(
          cargando: false,
          planeaciones: lista,
          planeacionesFiltradas: _aplicarFiltrosInternos(lista, state),
        ),
      );
    } catch (e) {
      emit(state.copyWith(cargando: false, error: 'Error al cargar datos'));
    }
  }

  // --- Lógica de filtrado centralizada ---
  void _actualizarYFiltrar(PlaneacionState nuevoEstadoConFiltros) {
    final filtradas = _aplicarFiltrosInternos(
      state.planeaciones,
      nuevoEstadoConFiltros,
    );
    emit(nuevoEstadoConFiltros.copyWith(planeacionesFiltradas: filtradas));
  }

  List<PlaneacionEntidad> _aplicarFiltrosInternos(
    List<PlaneacionEntidad> data,
    PlaneacionState s,
  ) {
    return data.where((p) {
      if (s.filtroFaseMomentoEtapa.isNotEmpty) {
        final v = p.faseMomentoEtapa ?? '';
        if (!v.toLowerCase().contains(s.filtroFaseMomentoEtapa.toLowerCase())) {
          return false;
        }
      }
      bool inDateRange = true;
      if (s.filtroFechaCreacionDesde.isNotEmpty) {
        final c = p.fechaCreacion ?? '';
        inDateRange = c.compareTo(s.filtroFechaCreacionDesde) >= 0;
      }
      if (inDateRange && s.filtroFechaCreacionHasta.isNotEmpty) {
        final c = p.fechaCreacion ?? '';
        inDateRange = c.compareTo(s.filtroFechaCreacionHasta) <= 0;
      }
      return p.nombreProyecto.toLowerCase().contains(
            s.filtroNombreProyecto.toLowerCase(),
          ) &&
          p.nombreEscuela.toLowerCase().contains(
            s.filtroNombreEscuela.toLowerCase(),
          ) &&
          p.cicloEscolar.toLowerCase().contains(
            s.filtroCicloEscolar.toLowerCase(),
          ) &&
          p.nivelEducativo.toLowerCase().contains(
            s.filtroNivelEducativo.toLowerCase(),
          ) &&
          p.grupo.toLowerCase().contains(s.filtroGradoGrupo.toLowerCase()) &&
          p.faseEducativa.toLowerCase().contains(
            s.filtroFaseEducativa.toLowerCase(),
          ) &&
          p.fechaEntrega.toLowerCase().contains(
            s.filtroFechaEntrega.toLowerCase(),
          ) &&
          inDateRange;
    }).toList();
  }

  // Setters que disparan el filtrado automáticamente
  void setFiltroProyecto(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroNombreProyecto: v));
  void setFiltroEscuela(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroNombreEscuela: v));
  void setFiltroFecha(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroFechaEntrega: v));
  void setFiltroCiclo(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroCicloEscolar: v));
  void setFiltroNivel(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroNivelEducativo: v));
  void setFiltroGrupo(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroGradoGrupo: v));
  void setFiltroFase(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroFaseEducativa: v));

  void setFiltroFaseMomentoEtapa(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroFaseMomentoEtapa: v));

  void setFiltroFechaCreacionDesde(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroFechaCreacionDesde: v));
  void setFiltroFechaCreacionHasta(String v) =>
      _actualizarYFiltrar(state.copyWith(filtroFechaCreacionHasta: v));

  void limpiarFiltros() {
    final estadoLimpio = state.copyWith(
      filtroNombreProyecto: "",
      filtroNombreEscuela: "",
      filtroFechaEntrega: "",
      filtroFechaCreacionDesde: "",
      filtroFechaCreacionHasta: "",
      filtroCicloEscolar: "",
      filtroNivelEducativo: "",
      filtroGradoGrupo: "",
      filtroFaseEducativa: "",
    );
    _actualizarYFiltrar(estadoLimpio);
  }

  // Selección y eliminación
  void toggleSeleccion(int id) {
    final actuales = List<int>.from(state.selectedPlaneacionIds);
    if (actuales.contains(id)) {
      actuales.remove(id);
    } else {
      actuales.add(id);
    }
    emit(state.copyWith(selectedPlaneacionIds: actuales));
  }

  void limpiarSeleccion() {
    emit(state.copyWith(selectedPlaneacionIds: []));
  }

  // Optimización del borrado múltiple
  Future<void> eliminarSeleccionados() async {
    emit(state.copyWith(cargando: true));
    try {
      for (var id in state.selectedPlaneacionIds) {
        await eliminarPlaneacion(id);
      }
      emit(state.copyWith(selectedPlaneacionIds: []));
      await cargarPlaneaciones();
    } catch (e) {
      emit(state.copyWith(cargando: false, error: "Error al eliminar"));
    }
  }
}
