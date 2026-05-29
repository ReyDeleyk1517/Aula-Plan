import 'package:aula_plan/features/planeaciones/presentation/widgets/contenido_model.dart';
import 'package:flutter/material.dart';
import 'contenido_service.dart';
import 'item_contenido_card.dart';

class BuscadorContenidosDialog extends StatefulWidget {
  final List<String> fasesHabilitadas; 
  const BuscadorContenidosDialog({super.key, required this.fasesHabilitadas});

  @override
  _BuscadorContenidosDialogState createState() => _BuscadorContenidosDialogState();
}

class _BuscadorContenidosDialogState extends State<BuscadorContenidosDialog> {
  String? _faseSeleccionada;
  String? _campoSeleccionado;
  String? _gradoSeleccionado;
  Map<String, List<ContenidoBusqueda>>? _datosCargados;

  // NUEVA VARIABLE: Controla si el panel de filtros está expandido u oculto
  bool _mostrarFiltros = true;

  final Map<String, Map<String, List<String>>> _seleccionadosAgrupados = {};
  final List<String> _campos = ['LEN', 'SyPC', 'ENyS', 'DHyC'];
  final Color zacTinto = const Color(0xFF8B1D1D);

  final Map<String, String> _nombresCompletosCampos = {
    'LEN': 'Lenguajes',
    'SyPC': 'Saberes y pensamiento Científico',
    'ENyS': 'Ética naturaleza y Sociedad',
    'DHyC': 'De lo humano y lo Comunitario',
  };

  void _cargarFase(String fase) async {
    setState(() {
      _faseSeleccionada = fase;
      _campoSeleccionado = null;
      _gradoSeleccionado = null;
      _seleccionadosAgrupados.clear(); 
      _datosCargados = null;
    });

    final datos = await ContenidosService().cargarContenidos(fase);
    setState(() => _datosCargados = datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Contenidos'),
        backgroundColor: zacTinto,
        foregroundColor: Colors.white,
        actions: [
          if (_seleccionadosAgrupados.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _seleccionadosAgrupados);
              },
              child: const Text('GUARDAR', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: Column(
        children: [
          // 1. Barra superior para ocultar/mostrar los filtros de forma intuitiva
          _buildBarraControlFiltros(),
          
          // 2. Contenedor animado que esconde o muestra el bloque completo de opciones
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSeccionFase(),
                if (_faseSeleccionada != null) _buildSeccionCampos(),
                if (_campoSeleccionado != null) _buildSeccionGrados(),
                const SizedBox(height: 4),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _mostrarFiltros ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          ),
          
          const Divider(height: 1),
          Expanded(child: _buildCuerpoLista()),
        ],
      ),
    );
  }

  // Genera un botón plano ancho que actúa como pestaña colapsable
  Widget _buildBarraControlFiltros() {
    return InkWell(
      onTap: () => setState(() => _mostrarFiltros = !_mostrarFiltros),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 18, color: zacTinto),
                const SizedBox(width: 8),
                Text(
                  _mostrarFiltros ? "OCULTAR PANEL DE FILTROS" : "MOSTRAR PANEL DE FILTROS",
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5
                  ),
                ),
              ],
            ),
            // Flecha dinámica que apunta arriba si está abierto o abajo si está cerrado
            Icon(
              _mostrarFiltros ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionFase() {
    final todasLasOpciones = ['2', '3, 4 y 5', '6'];
    
    final opcionesVisibles = todasLasOpciones.where((faseBoton) {
      if (faseBoton == '2') return widget.fasesHabilitadas.contains('Fase 2');
      if (faseBoton == '6') return widget.fasesHabilitadas.contains('Fase 6');
      if (faseBoton == '3, 4 y 5') {
        return widget.fasesHabilitadas.any((f) => ['Fase 3', 'Fase 4', 'Fase 5'].contains(f));
      }
      return false;
    }).toList();

    if (opcionesVisibles.isEmpty) {
      return _filtroCard(
        titulo: "1. Selecciona la fase", 
        child: Wrap(
          spacing: 8.0, 
          runSpacing: 4.0, 
          alignment: WrapAlignment.start,
          children: opcionesVisibles.map((f) => _faseChip(f)).toList(),
        ),
      );
    }

    return _filtroCard(
      titulo: "1. Selecciona la fase",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: opcionesVisibles.map((f) => _faseChip(f)).toList(),
      ),
    );
  }

  Widget _buildSeccionCampos() {
    return _filtroCard(
      titulo: "2. Campo formativo",
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: _campos.map((c) => _campoChip(c)).toList(),
      ),
    );
  }

  Widget _buildSeccionGrados() {
    if (_datosCargados == null || _campoSeleccionado == null) return const SizedBox.shrink();
    
    final listaCompleta = _datosCargados![_campoSeleccionado] ?? [];
    final gradosDisponibles = listaCompleta.map((e) {
      if (e is ContenidoPrimaria) return e.grado;
      if (e is ContenidoPrescolar) return e.grado;
      if (e is ContenidoSecundaria) return e.grado;
      return null;
    }).whereType<String>().toSet().toList()..sort();

    if (gradosDisponibles.isEmpty) return const SizedBox.shrink();

    return _filtroCard(
      titulo: "3. Selecciona el grado",
      child: Wrap(
        spacing: 8.0, 
        runSpacing: 8.0, 
        children: gradosDisponibles.map((g) => _gradoChip(g)).toList(),
      ),
    );
  }

  Widget _buildCuerpoLista() {
    if (_faseSeleccionada == null) return _placeholder("Selecciona una fase para comenzar");
    if (_campoSeleccionado == null) return _placeholder("Selecciona un campo formativo");

    List<ContenidoBusqueda> lista = _datosCargados?[_campoSeleccionado] ?? [];

    if (_gradoSeleccionado != null) {
      lista = lista.where((e) {
        if (e is ContenidoPrimaria) return e.grado == _gradoSeleccionado;
        if (e is ContenidoPrescolar) return e.grado == _gradoSeleccionado;
        if (e is ContenidoSecundaria) return e.grado == _gradoSeleccionado;
        return true;
      }).toList();
    }

    lista.sort((a, b) {
      int numA = int.tryParse(a.numero ?? '0') ?? 0;
      int numB = int.tryParse(b.numero ?? '0') ?? 0;
      return numA.compareTo(numB);
    });

    if (lista.isEmpty) return const Center(child: Text("Sin contenidos disponibles"));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        final seleccionadosDelItem = _seleccionadosAgrupados[_campoSeleccionado!]?[item.titulo] ?? [];

        return ItemContenidoCard(
          item: item,
          colorTema: zacTinto,
          seleccionados: seleccionadosDelItem,
          onToggle: (pda, esSeleccionado) {
            setState(() {
              final campo = _campoSeleccionado!;
              _seleccionadosAgrupados.putIfAbsent(campo, () => {});
              
              if (esSeleccionado) {
                _seleccionadosAgrupados[campo]!.putIfAbsent(item.titulo, () => []).add(pda);
              } else {
                _seleccionadosAgrupados[campo]![item.titulo]?.remove(pda);
                if (_seleccionadosAgrupados[campo]![item.titulo]!.isEmpty) {
                  _seleccionadosAgrupados[campo]!.remove(item.titulo);
                }
                if (_seleccionadosAgrupados[campo]!.isEmpty) {
                  _seleccionadosAgrupados.remove(campo);
                }
              }
            });
          },
        );
      },
    );
  }

  Widget _placeholder(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
          Text(mensaje, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _filtroCard({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(), 
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: zacTinto, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _faseChip(String f) {
    final selected = _faseSeleccionada == f;
    return ChoiceChip(
      label: Text('Fase $f'),
      selected: selected,
      selectedColor: zacTinto,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
      onSelected: (_) => _cargarFase(f),
    );
  }

  Widget _campoChip(String c) {
    final selected = _campoSeleccionado == c;
    return ChoiceChip(
      label: Text(_nombresCompletosCampos[c] ?? c),
      selected: selected,
      selectedColor: zacTinto,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12),
      onSelected: (_) => setState(() {
        _campoSeleccionado = c;
        _gradoSeleccionado = null;
      }),
    );
  }

  Widget _gradoChip(String g) {
    final selected = _gradoSeleccionado == g;
    return ChoiceChip(
      label: Text("Grado $g"),
      selected: selected,
      selectedColor: zacTinto,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) => setState(() => _gradoSeleccionado = val ? g : null),
    );
  }
}