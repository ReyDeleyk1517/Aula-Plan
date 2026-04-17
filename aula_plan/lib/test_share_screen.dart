import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart' hide XFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' hide XFile;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TestShareScreen extends StatefulWidget {
  const TestShareScreen({super.key});

  @override
  State<TestShareScreen> createState() => _TestShareScreenState();
}

class _TestShareScreenState extends State<TestShareScreen> {
  String text = '';
  String subject = '';
  String title = '';
  String uri = '';
  String fileName = '';
  String fileName2 = '';
  String filePath = '';
  List<CupertinoActivityType> excludedCupertinoActivityType = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Plus Plugin Demo'), elevation: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Share text',
                hintText: 'Enter some text and/or link to share',
              ),
              maxLines: null,
              onChanged: (String value) => setState(() => text = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Share Text as File',
                hintText: 'Enter the filename you want to share your text as',
              ),
              onChanged: (String value) => setState(() => fileName2 = value),
            ),
            const SizedBox(height: 16),

            // Logica de Selección de Archivos 
            ElevatedButton.icon(
              label: const Text('Add File (Image, PDF, etc.)'),
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                if (!kIsWeb &&
                    (Platform.isMacOS ||
                        Platform.isLinux ||
                        Platform.isWindows)) {

                  final typeGroups = <XTypeGroup>[
                    const XTypeGroup(
                      label: 'Soportados (Imágenes y PDF)',
                      extensions: [
                        'jpg',
                        'jpeg',
                        'png',
                        'gif',
                        'pdf',
                        'docx',
                        'txt',
                      ],
                    ),
                    const XTypeGroup(
                      label: 'Todos los archivos',
                      // No poner extensiones aquí 
                    ),
                  ];

                  final file = await openFile(acceptedTypeGroups: typeGroups);
                  if (file != null) {
                    setState(() {
                      filePath = file.path;
                      fileName = file.name;
                    });
                  }
                } else {
                  final typeGroups = <XTypeGroup>[
                    const XTypeGroup(
                      label: 'Soportados (Imágenes y PDF)',
                      extensions: [
                        'jpg',
                        'jpeg',
                        'png',
                        'gif',
                        'pdf',
                        'docx',
                        'txt',
                      ],
                    ),
                    const XTypeGroup(
                      label: 'Todos los archivos',
                      // No poner extensiones aquí 
                    ),
                  ];
                  final file = await openFile(acceptedTypeGroups: typeGroups);
                  if (file != null) {
                    setState(() {
                      filePath = file.path;
                      fileName = file.name;
                    });
                  }
                }
              },
            ),

            if (fileName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(fileName),
              ),
            const SizedBox(height: 32),

            Builder(
              builder: (ctx) => Column(
                children: [
                  _buildButton(
                    ctx,
                    'Share',
                    text.isEmpty && filePath.isEmpty
                        ? null
                        : () => _onShareWithResult(ctx),
                  ),

                  const SizedBox(height: 16),
                  _buildButton(
                    ctx,
                    'Share text as XFile',
                    fileName2.isEmpty || text.isEmpty
                        ? null
                        : () => _shareFileCreado(ctx),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _onShareWithResult(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    ShareResult shareResult;

    print('--- SHARE FILE PICKER DEBUG ---');
    print('filePath: $filePath');
    print('fileName: $fileName');

    if (filePath.isNotEmpty) {
      final realFile = File(filePath);

      print('exists: ${await realFile.exists()}');
      print('size: ${await realFile.length()}');

      try {
        final bytes = await realFile.readAsBytes();
        print('first bytes: ${bytes.take(20).toList()}');
      } catch (e) {
        print('error reading bytes: $e');
      }

      final xfile = XFile(filePath, name: fileName);

      print('XFile path: ${xfile.path}');
      print('XFile name: ${xfile.name}');
      print('XFile mimeType: ${xfile.mimeType}');

      final files = <XFile>[xfile];

      shareResult = await SharePlus.instance.share(
        ShareParams(
          text: text.isEmpty ? null : text,
          subject: subject.isEmpty ? null : subject,
          title: title.isEmpty ? null : title,
          files: files,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          excludedCupertinoActivities: [CupertinoActivityType.airDrop],
        ),
      );
    } else {
      print('No file, sharing only text');

      shareResult = await SharePlus.instance.share(
        ShareParams(
          text: text.isEmpty ? null : text,
          subject: subject.isEmpty ? null : subject,
          title: title.isEmpty ? null : title,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          excludedCupertinoActivities: excludedCupertinoActivityType,
        ),
      );
    }

    print('share result: ${shareResult.status} ${shareResult.raw}');

    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }


  void _shareFileCreado(BuildContext context) async {
  final box = context.findRenderObject() as RenderBox?;
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    // Obtener directorio temporal
    final tempDir = await getTemporaryDirectory();

    // Sanitizar nombre 
    String nombreLimpio = fileName2.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (nombreLimpio.isEmpty) nombreLimpio = 'archivo_temporal';
    if (!nombreLimpio.endsWith('.txt')) nombreLimpio += '.txt';

    // Ruta física real
    final fullPath = p.join(tempDir.path, nombreLimpio);

    // Escritura física
    final file = File(fullPath);
    await file.writeAsBytes(utf8.encode(text));

    setState(() {
      filePath = file.path; 
    });

    // LOGs
    print('Path real: ${file.path}');
    print('Existe: ${await file.exists()}');

    // rCOMPARTIRr
    // Usar Share.shareXFiles directamente para evitar problemas de ShareParams
    final result = await Share.shareXFiles(
      [XFile(file.path, name: nombreLimpio, mimeType: 'text/plain')],
      text: text.isEmpty ? null : text,
      subject: subject.isEmpty ? null : subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    

    print('Resultado: ${result.status}');
    scaffoldMessenger.showSnackBar(getResultSnackBar(result));

  } catch (e) {
    print('Error crítico en share: $e');
    scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Text("Resultado: ${result.status} ${result.raw ?? ''}"),
    );
  }
}
