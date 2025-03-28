import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpenseTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 48, 122, 137)),
      ),
      home: const MyHomePage(title: 'ExpenseTrack'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _ocrText = "Nimic scanat momentan.";
  
  Future<void> scanReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final uri = Uri.parse("http://10.0.2.2:5000/scan"); // folosește IP local dacă e pe telefon
      final request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath("image", pickedFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);
        setState(() {
          _ocrText = decoded['text'] ?? "Text gol.";
        });
      } else {
        setState(() {
          _ocrText = "Eroare server: ${response.statusCode}";
        });
      }
    } else {
      setState(() {
        _ocrText = "Nu a fost selectată nicio imagine.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            const Text('Text scanat din imagine:'),
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _ocrText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ElevatedButton.icon(
          onPressed: scanReceipt,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Scanează o imagine"),
          ),
          ],
        ),
      ),
    );
  }
}
