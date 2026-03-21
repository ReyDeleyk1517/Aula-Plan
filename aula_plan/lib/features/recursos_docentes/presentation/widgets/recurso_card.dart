import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:aula_plan/features/recursos_docentes/domain/entidades/recurso_docentes_entidad.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/paginas/recurso_agregar_editar_view.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/tag.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';

class RecursoCard extends StatelessWidget {
  final RecursoDocenteEntidad recurso;
  const RecursoCard({super.key, required this.recurso});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select((RecursosDocenteCubit c) => 
        c.state.seleccionadosIds.contains(recurso.id));
    
    const selectionColor = Color(0xFF6366F1);
    bool esEnlace = recurso.tipoArchivo == 'enlace';
    
    // Configuración de iconos según tipo
    IconData iconData = Icons.insert_drive_file;
    Color iconColor = AppColors.primary;

    if (esEnlace) {
      iconData = Icons.public;
      iconColor = Colors.blue.shade700;
    } else if (recurso.tipoArchivo.toLowerCase().contains('pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red.shade800;
    } else if (recurso.tipoArchivo.toLowerCase().contains('mp4')) {
      iconData = Icons.video_file;
      iconColor = Colors.orange.shade800;
    } else if (recurso.tipoArchivo.toLowerCase().contains('jpg') || 
               recurso.tipoArchivo.toLowerCase().contains('png')) {
      iconData = Icons.image;
      iconColor = Colors.green.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: InkWell( 
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirRecurso(context),
        onLongPress: () => context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // Seccion izquierda icono
              _buildLeadingIcon(iconColor, iconData, isSelected),
              
              const SizedBox(width: 12),

              // Seccion central texto y tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recurso.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textDark
                      ),
                    ),
                    if (esEnlace && recurso.enlace != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        recurso.enlace!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.blue.shade600, 
                          decoration: TextDecoration.underline
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Wrap para que los tags no se amontonen
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Tag(text: recurso.area),
                        Tag(text: recurso.campoFormativo),
                      ],
                    ),
                  ],
                ),
              ),

              // Seccion derecha acciones
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(), 
                    icon: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked, 
                      color: isSelected ? selectionColor : Colors.grey.shade400, 
                      size: 24
                    ),
                    onPressed: () => context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => RecursoAgregarEditarView(recursoEditar: recurso),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para el icono con el check de selección
  Widget _buildLeadingIcon(Color color, IconData icon, bool selected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        if (selected)
          Positioned(
            top: -5,
            left: -5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.primary, 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  // Lógica de apertura 
  Future<void> _abrirRecurso(BuildContext context) async {
    try {
      if (recurso.tipoArchivo == 'enlace') {
        final String? urlOriginal = recurso.enlace;
        if (urlOriginal == null || urlOriginal.isEmpty) {
          _mostrarError(context, 'El enlace está vacío');
          return;
        }
        String urlLimpia = urlOriginal.trim();
        if (!urlLimpia.startsWith('http://') && !urlLimpia.startsWith('https://')) {
          urlLimpia = 'https://$urlLimpia';
        }
        final Uri url = Uri.parse(urlLimpia);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _mostrarError(context, 'No se pudo abrir el enlace');
        }
      } else {
        if (recurso.rutaArchivo != null && recurso.rutaArchivo!.isNotEmpty) {
          final result = await OpenFile.open(recurso.rutaArchivo!);
          if (result.type != ResultType.done) {
            _mostrarError(context, 'No se encontró una aplicación para abrir este archivo');
          }
        } else {
          _mostrarError(context, 'Ruta de archivo no válida');
        }
      }
    } catch (e) {
      _mostrarError(context, 'Error al abrir recurso');
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje), 
        backgroundColor: Colors.redAccent, 
        behavior: SnackBarBehavior.floating
      ),
    );
  }
}