import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stability_ai_issue/save_generated_image.dart';
import 'package:stability_ai_issue/stability_ai_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stability ai',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Stability Ai'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String takenImagePath = '';
  String generatedImagePath = '';

  void _submit() async {
    await StabilityAiApi.generateImage(sourceImage: XFile(takenImagePath))
        .then((resultMap) async {
      if (resultMap[ApiMapVars.statusCode] == 200) {
        await saveImageFileFromApiResponseToTemp(
                fileData: resultMap[ApiMapVars.responseBody])
            .then((savedImagePath) {
          setState(() {
            generatedImagePath = savedImagePath;
          });
        });
      } else {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              child: const Text("Select Source Image"),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                await picker
                    .pickImage(source: ImageSource.gallery)
                    .then((takenImage) async {
                  if (takenImage == null) return;
                  setState(() => takenImagePath = takenImage.path);
                });
              },
            ),
            const SizedBox(height: 20),
            takenImagePath.isNotEmpty
                ? Image.file(File(takenImagePath))
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            generatedImagePath.isNotEmpty
                ? Image.file(File(generatedImagePath))
                : const SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        label: const Text("GENERATE IMAGE"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
