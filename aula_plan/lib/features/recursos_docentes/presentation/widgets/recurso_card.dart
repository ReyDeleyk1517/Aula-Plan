import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:aula_plan/features/recursos_docentes/domain/entidades/recurso_docentes_entidad.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/app_colors.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/widgets/tag.dart';
import 'package:aula_plan/features/recursos_docentes/presentation/bloc/recurso_docente_cubit.dart';

class RecursosCard extends StatelessWidget {
  final RecursoDocenteEntidad recurso;
  const RecursosCard({required this.recurso});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select((RecursosDocenteCubit c) => c.state.seleccionadosIds.contains(recurso.id));
    final haySeleccionActiva = context.select((RecursosDocenteCubit c) => c.state.seleccionadosIds.isNotEmpty);

    bool esEnlace = recurso.tipoArchivo == 'enlace';
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
    } else if (recurso.tipoArchivo.toLowerCase().contains('jpg') || recurso.tipoArchivo.toLowerCase().contains('png')) {
      iconData = Icons.image;
      iconColor = Colors.green.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (haySeleccionActiva) {
            context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!);
          } else {
            _abrirRecurso(context);
          }
        },
        onLongPress: () => context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            if (isSelected)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
        title: Text(
          recurso.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (esEnlace && recurso.enlace != null)
                Text(
                  recurso.enlace!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Tag(text: recurso.area),
                  const SizedBox(width: 6),
                  Tag(text: recurso.campoFormativo),
                ],
              ),
            ],
          ),
        ),
        trailing: haySeleccionActiva
            ? Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => context.read<RecursosDocenteCubit>().toggleSeleccion(recurso.id!),
              )
            : IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                onPressed: () {
                  // Options (eliminar, etc) pueden ser handled in UI original
                },
              ),
      ),
    );
  }

  Future<void> _abrirRecurso(BuildContext context) async {
    try {
      if (recurso.tipoArchivo == 'enlace') {
        final String? urlOriginal = recurso.enlace;
        if (urlOriginal == null || urlOriginal.isEmpty) {
          _mostrarError(context, "El enlace está vacío");
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
          _mostrarError(context, "No se pudo abrir el enlace");
        }
      } else {
        if (recurso.rutaArchivo != null && recurso.rutaArchivo!.isNotEmpty) {
          final result = await OpenFile.open(recurso.rutaArchivo!);
          if (result.type != ResultType.done) {
            _mostrarError(context, "No se encontró una aplicación para abrir este archivo");
          }
        } else {
          _mostrarError(context, "Ruta de archivo no válida");
        }
      }
    } catch (e) {
      _mostrarError(context, "Ocurrió un error al intentar abrir el recurso");
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
