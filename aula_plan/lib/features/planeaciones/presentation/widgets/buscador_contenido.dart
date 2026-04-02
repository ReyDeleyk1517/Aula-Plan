import 'package:flutter/material.dart';
import 'package:aula_plan/features/planeaciones/presentation/widgets/contenido_service.dart';

class BuscadorContenidosDialog extends StatefulWidget {
  const BuscadorContenidosDialog({super.key});

  @override
  _BuscadorContenidosDialogState createState() => _BuscadorContenidosDialogState();
}

class _BuscadorContenidosDialogState extends State<BuscadorContenidosDialog> {
  String? _faseSeleccionada;
  String? _campoSeleccionado;
  Map<String, List<ContenidoBusqueda>>? _datosCargados;

  // Nueva estructura para rastrear selecciones agrupadas por contenido
  // { 'Titulo del Contenido': ['PDA 1', 'PDA 2'] }
  final Map<String, List<String>> _seleccionados = {};

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
      _seleccionados.clear(); // Limpiamos al cambiar de fase
      _datosCargados = null;
    });

    final datos = await ContenidosService().cargarContenidos(fase);
    setState(() => _datosCargados = datos);
  }

  // UI Widgets
  Widget _filtroCard({required String titulo, required Widget child}) {
    return Container(
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
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: zacTinto,
              letterSpacing: 1.1,
            ),
          ),
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
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) {
        setState(() {
          _campoSeleccionado = c;
          _seleccionados.clear(); // Limpiamos si cambia el campo formativo
        });
      },
    );
  }

  Widget _buildListaContenidos() {
    if (_campoSeleccionado == null || _datosCargados == null) {
      return const Center(child: Text("Selecciona un campo formativo"));
    }

    final lista = _datosCargados![_campoSeleccionado] ?? [];
    if (lista.isEmpty) return const Center(child: Text("Sin contenidos disponibles"));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        
        // Lógica de conteo basada en el Mapa
        final seleccionadosEnEsteContenido = _seleccionados[item.titulo] ?? [];
        final seleccionadosCount = seleccionadosEnEsteContenido.length;
        final tieneSeleccionados = seleccionadosCount > 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: tieneSeleccionados ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: tieneSeleccionados ? zacTinto.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: ExpansionTile(
            key: PageStorageKey(item.titulo),
            title: Text(
              item.titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: tieneSeleccionados ? FontWeight.bold : FontWeight.w500,
                color: tieneSeleccionados ? zacTinto : Colors.black87,
              ),
            ),
            subtitle: Text(
              "$seleccionadosCount de ${item.pdas.length} PDAs seleccionados",
              style: TextStyle(
                fontSize: 12,
                color: tieneSeleccionados ? zacTinto : Colors.grey.shade600,
              ),
            ),
            children: item.pdas.map((pda) {
              final esSeleccionado = seleccionadosEnEsteContenido.contains(pda);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: esSeleccionado ? zacTinto.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: esSeleccionado ? zacTinto.withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.platform,
                  activeColor: zacTinto,
                  title: Text(
                    pda,
                    style: TextStyle(
                      fontSize: 13,
                      color: esSeleccionado ? zacTinto : Colors.black87,
                      fontWeight: esSeleccionado ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  value: esSeleccionado,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        // Aseguramos que exista la lista para este contenido
                        _seleccionados.putIfAbsent(item.titulo, () => []);
                        _seleccionados[item.titulo]!.add(pda);
                      } else {
                        _seleccionados[item.titulo]?.remove(pda);
                        // Si se queda vacío, eliminamos la llave para mantener limpio el mapa
                        if (_seleccionados[item.titulo]?.isEmpty ?? false) {
                          _seleccionados.remove(item.titulo);
                        }
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
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
              onPressed: () {
                // Devolvemos el mapa completo para procesarlo en la vista principal
                Navigator.pop(context, {
                  'campo': _campoSeleccionado,
                  'datos': _seleccionados, 
                });
              },
              child: const Text(
                'GUARDAR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          _filtroCard(
            titulo: "1. Selecciona la fase",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['2', '3, 4 y 5', '6'].map((f) => _faseChip(f)).toList(),
            ),
          ),
          if (_faseSeleccionada != null)
            _filtroCard(
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
            ),
          const Divider(height: 1),
          Expanded(
            child: _faseSeleccionada == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                        const Text("Selecciona una fase para comenzar", 
                          style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _buildListaContenidos(),
          ),
        ],
      ),
    );
  }
}