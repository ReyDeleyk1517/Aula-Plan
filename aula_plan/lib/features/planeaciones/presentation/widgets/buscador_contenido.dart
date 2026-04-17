import 'package:aula_plan/features/planeaciones/presentation/widgets/contenido_model.dart';
import 'package:flutter/material.dart';
import 'contenido_service.dart';
import 'item_contenido_card.dart';

class BuscadorContenidosDialog extends StatefulWidget {
  final List<String> fasesHabilitadas; // Recibimos las fases
  const BuscadorContenidosDialog({super.key, required this.fasesHabilitadas});

  @override
  _BuscadorContenidosDialogState createState() => _BuscadorContenidosDialogState();
}

class _BuscadorContenidosDialogState extends State<BuscadorContenidosDialog> {
  String? _faseSeleccionada;
  String? _campoSeleccionado;
  String? _gradoSeleccionado;
  Map<String, List<ContenidoBusqueda>>? _datosCargados;

  // NUEVA ESTRUCTURA: Mapa de Campos -> (Mapa de Títulos -> Lista de PDAs)
  // Esto permite recordar qué elegiste en cada campo formativo por separado
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
      _seleccionadosAgrupados.clear(); // Limpiamos al cambiar de fase por integridad
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
                // Devolvemos el mapa completo agrupado por campos
                Navigator.pop(context, _seleccionadosAgrupados);
              },
              child: const Text('GUARDAR', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: Column(
        children: [
          _buildSeccionFase(),
          if (_faseSeleccionada != null) _buildSeccionCampos(),
          if (_campoSeleccionado != null) _buildSeccionGrados(),
          const Divider(height: 1),
          Expanded(child: _buildCuerpoLista()),
        ],
      ),
    );
  }

Widget _buildSeccionFase() {
    // Definimos qué fases de la vista de edición activan qué botones aquí
    final todasLasOpciones = ['2', '3, 4 y 5', '6'];
    
    final opcionesVisibles = todasLasOpciones.where((faseBoton) {
      if (faseBoton == '2') return widget.fasesHabilitadas.contains('Fase 2');
      if (faseBoton == '6') return widget.fasesHabilitadas.contains('Fase 6');
      if (faseBoton == '3, 4 y 5') {
        // Si la lista tiene 3, 4 O 5, mostramos este botón
        return widget.fasesHabilitadas.any((f) => ['Fase 3', 'Fase 4', 'Fase 5'].contains(f));
      }
      return false;
    }).toList();

    if (opcionesVisibles.isEmpty) {
      return _filtroCard(
        titulo: "1. Selecciona la fase", 
        child: const Text("No hay fases seleccionadas en la planeación", 
          style: TextStyle(fontSize: 12, color: Colors.red))
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _campos.map((c) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _campoChip(c),
          )).toList(),
        ),
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
      child: Row(
        children: gradosDisponibles.map((g) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _gradoChip(g),
        )).toList(),
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
        // Obtenemos los PDAs seleccionados para este contenido específico dentro del campo actual
        final seleccionadosDelItem = _seleccionadosAgrupados[_campoSeleccionado!]?[item.titulo] ?? [];

        return ItemContenidoCard(
          item: item,
          colorTema: zacTinto,
          seleccionados: seleccionadosDelItem,
          onToggle: (pda, esSeleccionado) {
            setState(() {
              final campo = _campoSeleccionado!;
              
              // Inicializamos el mapa del campo si no existe
              _seleccionadosAgrupados.putIfAbsent(campo, () => {});
              
              if (esSeleccionado) {
                _seleccionadosAgrupados[campo]!.putIfAbsent(item.titulo, () => []).add(pda);
              } else {
                _seleccionadosAgrupados[campo]![item.titulo]?.remove(pda);
                // Limpieza de llaves vacías
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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