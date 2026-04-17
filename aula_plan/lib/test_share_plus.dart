import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart' hide XFile; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' hide XFile;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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
  List<String> imageNames = [];
  List<String> imagePaths = [];
  List<CupertinoActivityType> excludedCupertinoActivityType = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Plus Plugin Demo'),
        elevation: 4,
      ),
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
                labelText: 'Share subject',
                hintText: 'Enter subject to share (optional)',
              ),
              onChanged: (String value) => setState(() => subject = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Share title',
                hintText: 'Enter title to share (optional)',
              ),
              onChanged: (String value) => setState(() => title = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Share uri',
                hintText: 'Enter the uri you want to share',
              ),
              onChanged: (String value) => setState(() => uri = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Share Text as File',
                hintText: 'Enter the filename you want to share your text as',
              ),
              onChanged: (String value) => setState(() => fileName = value),
            ),
            const SizedBox(height: 16),
            
            // --- Lógica de Selección de Archivos Modificada ---
            ElevatedButton.icon(
              label: const Text('Add File (Image, PDF, etc.)'),
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
                  // Agregamos múltiples grupos de tipos para escritorio
                  final typeGroups = <XTypeGroup>[
                    const XTypeGroup(
                      label: 'Soportados (Imágenes y PDF)',
                      extensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'docx', 'txt'],
                    ),
                    const XTypeGroup(
                      label: 'Todos los archivos',
                      // No poner extensiones aquí a veces ayuda a que Windows muestre el comodín *.*
                    ),
                  ];
                  
                  final file = await openFile(acceptedTypeGroups: typeGroups);
                  if (file != null) {
                    setState(() {
                      imagePaths.add(file.path);
                      imageNames.add(file.name);
                    });
                  }
                } else {
                  // Mobile / Web: ImagePicker solo maneja fotos/videos. 
                  // Para PDFs en móvil deberías usar el paquete 'file_picker', 
                  // pero aquí mantenemos image_picker para no romper tus dependencias.
                  final imagePicker = ImagePicker();
                  final pickedFile = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imagePaths.add(pickedFile.path);
                      imageNames.add(pickedFile.name);
                    });
                  }
                }
              },
            ),

            if (imageNames.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: imageNames.map((name) => Text("Seleccionado: $name")).toList(),
                ),
              ),

            const SizedBox(height: 32),
            
            Builder(
              builder: (ctx) => Column(
                children: [
                  _buildButton(ctx, 'Share', 
                    text.isEmpty && imagePaths.isEmpty ? null : () => _onShareWithResult(ctx)),
                  const SizedBox(height: 16),
                  _buildButton(ctx, 'Share XFile from Assets', 
                    () => _onShareXFileFromAssets(ctx)),
                  const SizedBox(height: 16),
                  _buildButton(ctx, 'Share text as XFile', 
                    fileName.isEmpty || text.isEmpty ? null : () => _onShareTextAsXFile(ctx)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback? onPressed) {
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

    if (imagePaths.isNotEmpty) {
      final files = <XFile>[];
      for (var i = 0; i < imagePaths.length; i++) {
        files.add(XFile(imagePaths[i], name: imageNames[i]));
      }
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
    } else if (uri.isNotEmpty) {
      shareResult = await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(uri),
          subject: subject.isEmpty ? null : subject,
          title: title.isEmpty ? null : title,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          excludedCupertinoActivities: excludedCupertinoActivityType,
        ),
      );
    } else {
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
    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }

  void _onShareXFileFromAssets(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final data = await rootBundle.load('assets/flutter_logo.png');
      final buffer = data.buffer;
      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
              name: 'flutter_logo.png',
              mimeType: 'image/png',
            ),
          ],
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          downloadFallbackEnabled: true,
        ),
      );
      scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onShareTextAsXFile(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode(text), mimeType: 'text/plain')],
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          fileNameOverrides: [fileName],
          downloadFallbackEnabled: true,
        ),
      );
      scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Text("Resultado: ${result.status} ${result.raw ?? ''}"),
    );
  }
}