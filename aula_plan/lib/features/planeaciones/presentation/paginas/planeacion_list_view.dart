import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula_plan/features/planeaciones/presentation/bloc/planeacion_cubit.dart';
import 'package:aula_plan/features/planeaciones/domain/entidades/planeacion_entidades.dart';
import 'package:aula_plan/features/planeaciones/presentation/widgets/planeacion_card.dart';
import 'package:aula_plan/features/planeaciones/presentation/paginas/planeacion_crear_editar_view.dart';
import 'package:aula_plan/core/injection_container.dart' as di;

class PlaneacionListView extends StatelessWidget {
  const PlaneacionListView({Key? key}) : super(key: key);

  Future<void> _irAEditor(BuildContext context, {PlaneacionEntidad? planeacion}) async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaneacionCrearEditarView(planeacionExistente: planeacion),
      ),
    );

    // Si el resultado de la creacion o edicion es true recargar pagina
    if (resultado == true && context.mounted) {
      context.read<PlaneacionCubit>().cargarPlaneaciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PlaneacionCubit>()..cargarPlaneaciones(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Planeaciones')),
        body: BlocBuilder<PlaneacionCubit, PlaneacionState>(
          builder: (context, estado) {
            if (estado.cargando) {
              return const Center(child: CircularProgressIndicator());
            }
            if (estado.error != null) {
              return Center(child: Text(estado.error!));
            }
            
            final planeaciones = estado.planeaciones;
            if (planeaciones.isEmpty) {
              return const Center(child: Text('No hay planeaciones creadas.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: planeaciones.length,
              itemBuilder: (context, i) {
                final p = planeaciones[i];
                return PlaneacionCard(
                  planeacion: p, 
                  onTap: () => _irAEditor(context, planeacion: p),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (fabContext) => FloatingActionButton(
            onPressed: () => _irAEditor(fabContext),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}