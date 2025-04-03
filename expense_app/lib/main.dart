import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpenseTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 48, 122, 137)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ExpenseTrack'),
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
  String _ocrText = "";
  bool _isLoading = false;
  bool _wasCleared = false;

  String extractedDate = "-";
  String extractedTotal = "-";
  String extractedQuantity = "-";
  String extractedMerchant = "-";

  int _selectedIndex = 0;

  void _onItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void extractFields(String text) {
    final dateRegex = RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{4}\b');
    final totalRegex = RegExp(r'(total|sum\u0103|amount)\s*[:\-]?\s*(\d+[.,]?\d*)', caseSensitive: false);
    final quantityRegex = RegExp(r'\b(x\s*\d+|\d+\s*buc|\d+\s*pcs)', caseSensitive: false);
    final merchantRegex = RegExp(r'(?:S\.?C\.?\s+)([A-Z\s]+?)(?:\s+S\.?R\.?L\.?|S\.?A\.?)');

    final dateMatch = dateRegex.firstMatch(text);
    final totalMatch = totalRegex.firstMatch(text);
    final qtyMatch = quantityRegex.firstMatch(text);
    final merchantMatch = merchantRegex.firstMatch(text);

    setState(() {
      extractedDate = dateMatch?.group(0) ?? "-";
      extractedTotal = totalMatch != null ? totalMatch.group(2)! : "-";
      extractedQuantity = qtyMatch?.group(0) ?? "-";
      extractedMerchant = merchantMatch != null ? merchantMatch.group(1)!.trim() : "-";
    });
  }

  Future<void> scanReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _ocrText = "";
        _wasCleared = false;
        extractedDate = "-";
        extractedTotal = "-";
        extractedQuantity = "-";
        extractedMerchant = "-";
      });

      try {
        final uri = Uri.parse("http://10.0.2.2:5000/scan");
        final request = http.MultipartRequest("POST", uri);
        request.files.add(await http.MultipartFile.fromPath("image", pickedFile.path));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final decoded = jsonDecode(responseBody);
          final scannedText = decoded['text'] ?? "Text empty.";
          setState(() {
            _ocrText = scannedText;
          });
          extractFields(scannedText);
        } else {
          setState(() {
            _ocrText = "Server error: \${response.statusCode}";
          });
        }
      } catch (e) {
        setState(() {
          _ocrText = "Connection error: \$e";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _ocrText = "No image selected.";
        _wasCleared = false;
      });
    }
  }

  void _clearText() {
    setState(() {
      _ocrText = "Text cleared.";
      _wasCleared = true;
      extractedDate = "-";
      extractedTotal = "-";
      extractedQuantity = "-";
      extractedMerchant = "-";
    });
  }

  Widget buildScanView() {
    final bool showBox = _ocrText.trim().isNotEmpty || _isLoading;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          if (showBox)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanned text:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _clearText,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear text',
                ),
              ],
            ),
          if (showBox) const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: showBox ? 200 : 0,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      child: Text(
                        _ocrText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: _wasCleared ? FontStyle.italic : FontStyle.normal,
                          color: _wasCleared ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : scanReceipt,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Scan an image"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
          if (_ocrText.trim().isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Detected Fields",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Date:"),
                      Text(extractedDate),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Total:"),
                      Text(extractedTotal),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Quantity:"),
                      Text(extractedQuantity),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Merchant:"),
                      Text(extractedMerchant),
                    ]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _selectedIndex == 0
          ? buildScanView()
          : _selectedIndex == 1
              ? const Center(child: Text('View1'))
              : const Center(child: Text('View2')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItem,
      ),
    );
  }
}
