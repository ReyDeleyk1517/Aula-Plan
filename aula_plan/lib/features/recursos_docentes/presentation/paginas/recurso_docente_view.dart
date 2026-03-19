import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

// Imports de tu proyecto
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';
import '../../domain/entidades/recurso_docentes_entidad.dart';

class RecursosDocenteScreen extends StatefulWidget {
  const RecursosDocenteScreen({super.key});

  @override
  State<RecursosDocenteScreen> createState() => _RecursosDocenteScreenState();
}

class _RecursosDocenteScreenState extends State<RecursosDocenteScreen> {
  final List<String> areas = const [
    'Todas',
    'Historia',
    'Matemáticas',
    'Ciencias',
    'Lengua'
  ];

  @override
  void initState() {
    super.initState();
    // Cargamos los recursos una sola vez al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecursosDocenteCubit>().cargarRecursos();
    });
  }

  Future<void> _agregarRecursoDesdeArchivo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      final nuevoRecurso = RecursoDocenteEntidad(
        id: null, // Autoincrementable en DB
        nombre: file.name,
        area: 'Todas', // Podrías abrir un diálogo previo para elegir el área
        campoFormativo: 'General',
        tipoArchivo: file.extension ?? 'archivo',
        rutaArchivo: file.path,
        fechaCreacion: DateTime.now(),
      );

      if (context.mounted) {
        // Asumiendo que agregaste el método agregarRecurso al Cubit como sugerí antes
        context.read<RecursosDocenteCubit>().agregarRecurso(nuevoRecurso);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Recursos"),
        actions: [
          BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
            builder: (context, state) {
              if (state.seleccionadosIds.isEmpty) return const SizedBox();
              return IconButton(
                tooltip: 'Exportar seleccionados a ZIP',
                icon: const Icon(Icons.folder_zip),
                onPressed: () => context.read<RecursosDocenteCubit>().exportarAZip(),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          const Expanded(child: _RecursosList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarRecursoDesdeArchivo(context),
        tooltip: 'Añadir archivo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: areas.map((area) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(area),
                selected: state.filtroArea == area,
                onSelected: (_) => context.read<RecursosDocenteCubit>().cambiarFiltro(area),
              ),
            )).toList(),
          ),
        );
      },
    );
  }
}

class _RecursosList extends StatelessWidget {
  const _RecursosList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecursosDocenteCubit, RecursosDocenteState>(
      builder: (context, state) {
        if (state.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = state.recursos.where((r) => 
          state.filtroArea == 'Todas' || r.area == state.filtroArea
        ).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text("No se encontraron recursos en esta área"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) => _RecursoCard(recurso: items[index]),
        );
      },
    );
  }
}

class _RecursoCard extends StatelessWidget {
  final RecursoDocenteEntidad recurso;
  const _RecursoCard({required this.recurso});

  @override
  Widget build(BuildContext context) {
    // Usamos select para observar solo la lista de seleccionados
    final isSelected = context.select(
      (RecursosDocenteCubit cubit) => cubit.state.seleccionadosIds.contains(recurso.id)
    );

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? BorderSide(color: Theme.of(context).primaryColor, width: 2) 
          : BorderSide.none,
      ),
      child: ListTile(
        onTap: () async {
          if (recurso.enlace != null && recurso.enlace!.isNotEmpty) {
            final uri = Uri.parse(recurso.enlace!);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          } else if (recurso.rutaArchivo != null) {
            await OpenFile.open(recurso.rutaArchivo);
          }
        },
        leading: CircleAvatar(
          backgroundColor: recurso.enlace != null 
              ? Colors.blue.withOpacity(0.1) 
              : Colors.orange.withOpacity(0.1),
          child: Icon(
            recurso.enlace != null ? Icons.link : Icons.insert_drive_file,
            color: recurso.enlace != null ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          recurso.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text("${recurso.area} • ${recurso.campoFormativo}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (recurso.rutaArchivo != null)
              Checkbox(
                value: isSelected,
                onChanged: (_) => context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmarEliminacion(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("¿Eliminar recurso?"),
        content: Text("Se borrará '${recurso.nombre}' permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              context.read<RecursosDocenteCubit>().eliminarRecurso(recurso.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}