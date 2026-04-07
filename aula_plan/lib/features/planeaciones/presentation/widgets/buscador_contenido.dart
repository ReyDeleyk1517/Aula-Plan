import 'package:flutter/material.dart';
import 'contenido_service.dart';
import 'item_contenido.dart';

class BuscadorContenidosDialog extends StatefulWidget {
  const BuscadorContenidosDialog({super.key});

  @override
  _BuscadorContenidosDialogState createState() => _BuscadorContenidosDialogState();
}

class _BuscadorContenidosDialogState extends State<BuscadorContenidosDialog> {
  String? _faseSeleccionada;
  String? _campoSeleccionado;
  String? _gradoFiltro; // Filtro para primaria
  Map<String, List<dynamic>>? _datosCargados;
  final Map<String, List<String>> _seleccionados = {};

  final Color zacTinto = const Color(0xFF8B1D1D);
  final List<String> _campos = ['LEN', 'SyPC', 'ENyS', 'DHyC'];

  void _cargarFase(String fase) async {
    setState(() {
      _faseSeleccionada = fase;
      _campoSeleccionado = null;
      _gradoFiltro = null;
      _seleccionados.clear();
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
          if (_seleccionados.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, {'datos': _seleccionados}),
              child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Column(
        children: [
          _buildSeccionFase(),
          if (_faseSeleccionada != null) _buildSeccionCampos(),
          if (_faseSeleccionada == '3, 4 y 5' && _campoSeleccionado != null) _buildSeccionGrados(),
          const Divider(),
          Expanded(child: _buildCuerpoLista()),
        ],
      ),
    );
  }

  // --- WIDGETS DE FILTROS ---

  Widget _buildSeccionFase() {
    return _cardFiltro("1. Fase", Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['2', '3, 4 y 5', '6'].map((f) => ChoiceChip(
        label: Text("Fase $f"),
        selected: _faseSeleccionada == f,
        onSelected: (_) => _cargarFase(f),
      )).toList(),
    ));
  }

  Widget _buildSeccionCampos() {
    return _cardFiltro("2. Campo Formativo", SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _campos.map((c) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ChoiceChip(
            label: Text(c),
            selected: _campoSeleccionado == c,
            onSelected: (val) => setState(() { 
              _campoSeleccionado = val ? c : null;
              _seleccionados.clear();
            }),
          ),
        )).toList(),
      ),
    ));
  }

  Widget _buildSeccionGrados() {
    return _cardFiltro("3. Grado (Primaria)", Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['1', '2', '3', '4', '5', '6'].map((g) => ChoiceChip(
        label: Text("$g°"),
        selected: _gradoFiltro == g,
        onSelected: (val) => setState(() => _gradoFiltro = val ? g : null),
      )).toList(),
    ));
  }

  // --- LÓGICA DE LA LISTA ---

  Widget _buildCuerpoLista() {
    if (_datosCargados == null || _campoSeleccionado == null) {
      return const Center(child: Text("Selecciona fase y campo"));
    }

    final rawList = _datosCargados![_campoSeleccionado] ?? [];

    // SEPARACIÓN DE LÓGICA POR FASE
    if (_faseSeleccionada == '3, 4 y 5') {
      // Manejo como ContenidoPrimaria
      final listaPrimaria = rawList.cast<ContenidoPrimaria>();
      final filtrada = _gradoFiltro == null 
          ? listaPrimaria 
          : listaPrimaria.where((e) => e.grado == _gradoFiltro).toList();

      return _renderList(filtrada);
    } else {
      // Manejo como ContenidoSimple (Fase 2 y 6)
      final listaSimple = rawList.cast<ContenidoBusqueda>();
      return _renderList(listaSimple);
    }
  }

  Widget _renderList(List<dynamic> lista) {
    if (lista.isEmpty) return const Center(child: Text("Sin resultados"));
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        // Aquí ItemContenidoCard debe ser capaz de recibir titulo y pdas
        return ItemContenidoCard(
          item: item, 
          colorTema: zacTinto,
          seleccionados: _seleccionados[item.titulo] ?? [],
          onToggle: (pda, isSel) {
             setState(() {
              if (isSel) {
                _seleccionados.putIfAbsent(item.titulo, () => []).add(pda);
              } else {
                _seleccionados[item.titulo]?.remove(pda);
              }
            });
          },
        );
      },
    );
  }

  Widget _cardFiltro(String titulo, Widget child) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: TextStyle(color: zacTinto, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        child
      ]),
    );
  }
}