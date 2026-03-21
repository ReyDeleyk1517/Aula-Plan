import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planeacion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B1D1D),
          primary: const Color(0xFF8B1D1D),
        ),
      ),
      home: const PlaneacionScreen(),
    );
  }
}

class PlaneacionScreen extends StatefulWidget {
  const PlaneacionScreen({super.key});

  @override
  State<PlaneacionScreen> createState() => _PlaneacionScreenState();
}

class _PlaneacionScreenState extends State<PlaneacionScreen> {
  final Color zacTinto = const Color(0xFF8B1D1D);
  
  // Lista dinámica para manejar los datos de las fases (Tabla FasesPlaneacion)
  List<int> fasesCount = [1]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fondo gris azulado suave
      appBar: AppBar(
        backgroundColor: zacTinto,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: const [
            Text("Planeaciones", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSeccionTitulo("DATOS DE LA PLANEACIÓN"),
                  _buildDatosGenerales(),
                  
                  _buildSeccionTitulo("CONTEXTO Y CURRÍCULO"),
                  _buildContenidoPedagogico(),
                  
                  _buildSeccionTitulo("PROYECTO Y METODOLOGÍA"),
                  _buildMetodologiaEstructura(),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  
                  _buildSeccionTitulo("FASES DE DESARROLLO"),
                  ...fasesCount.asMap().entries.map((entry) => _buildFaseForm(entry.key + 1)).toList(),
                  
                  _buildBotonAgregarFase(),
                  const SizedBox(height: 100), // Espacio para no chocar con el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      // Botón de acción principal flotante (más estilo App moderna)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            // Aquí iría la lógica para guardar en la DB
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Guardando Planeación..."))
            );
          },
          icon: const Icon(Icons.cloud_upload, color: Colors.white),
          label: const Text("GUARDAR", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: zacTinto,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE SECCIÓN ---

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
      child: Text(titulo, 
        style: TextStyle(color: zacTinto.withOpacity(0.8), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1)),
    );
  }

  Widget _buildDatosGenerales() {
    return _cardWrapper([
      _customField("Nombre de la Escuela", Icons.apartment, "Escriba el nombre..."),
      Row(
        children: [
          Expanded(child: _customField("Ciclo Escolar", Icons.calendar_today, "2024-2025")),
          const SizedBox(width: 12),
          Expanded(child: _customField("Grupo", Icons.group_work, "6º B")),
        ],
      ),
      _customField("Condición del Alumnado", Icons.accessibility_new, "AS, TDAH, TEA..."),
    ]);
  }

  Widget _buildContenidoPedagogico() {
    return _cardWrapper([
      _customField("Campos Formativos", Icons.category, "Lenguajes, Ética...", maxLines: 2),
      _customField("Contenidos / PDA", Icons.assignment, "Procesos de desarrollo...", maxLines: 3),
      _customField("Ejes Articuladores", Icons.interests, "Vida saludable..."),
      _customField("Necesidades BAP", Icons.warning_amber_rounded, "Describa barreras..."),
    ]);
  }

  Widget _buildMetodologiaEstructura() {
    return _cardWrapper([
      _customField("Metodología Sugerida", Icons.account_tree, "ABP, STEAM, etc."),
      _customField("Nombre del Proyecto", Icons.rocket_launch, "Título del proyecto"),
      _customField("Escenarios", Icons.location_on, "Aula, Escuela, Comunidad"),
    ]);
  }

  Widget _buildFaseForm(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade300, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("FASE #$index", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                Icon(Icons.edit_note, color: Colors.orange.shade900, size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _customField("Actividades", Icons.play_arrow, "Describa el desarrollo...", maxLines: 3),
                _customField("Evaluación / Instrumentos", Icons.fact_check, "Rúbrica, lista de cotejo..."),
                Row(
                  children: [
                    Expanded(child: _customField("Materiales", Icons.inventory_2, "Recursos")),
                    const SizedBox(width: 10),
                    Expanded(child: _customField("Tiempo", Icons.timer, "Minutos")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTONES ---

  Widget _buildBotonAgregarFase() {
    return TextButton.icon(
      onPressed: () => setState(() => fasesCount.add(fasesCount.length + 1)),
      icon: const Icon(Icons.add_circle),
      label: const Text("AGREGAR NUEVA FASE", style: TextStyle(fontWeight: FontWeight.bold)),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange.shade900,
        backgroundColor: Colors.orange.shade100.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- ESTILOS REUTILIZABLES ---

  Widget _cardWrapper(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _customField(String label, IconData icon, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: zacTinto.withOpacity(0.6)),
          hintText: hint,
          alignLabelWithHint: true,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}