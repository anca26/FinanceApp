import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_app/views/history_view.dart';
import 'package:expense_app/views/settings_view.dart';
import 'package:expense_app/views/scan_view.dart';

void main() {
  runApp(const MyApp());
}

final Color myBlue = const Color.fromARGB(255, 45, 51, 107);
final Color myWhite = const Color.fromARGB(255, 255, 242, 242);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpenseTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: myBlue),
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
    final totalRegex = RegExp(r'(total|sumă|amount)\s*[:\-]?\s*(\d+[.,]?\d*)', caseSensitive: false);
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

  void _clearText() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove receipt"),
        content: const Text("Are you sure you want to remove the receipt?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove")),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _ocrText = "No receipt";
        _wasCleared = true;
        extractedDate = "-";
        extractedTotal = "-";
        extractedQuantity = "-";
        extractedMerchant = "-";
      });
    }
  }

  bool _validateInput(String label, String value) {
    switch (label) {
      case "Date:":
        return RegExp(r'^\d{2}[./-]\d{2}[./-]\d{4}\$').hasMatch(value);
      case "Total:":
        return RegExp(r'^\d+[.,]?\d*\$').hasMatch(value);
      case "Quantity:":
        return RegExp(r'^(x\s*\d+|\d+\s*buc|\d+\s*pcs)\$').hasMatch(value);
      case "Merchant:":
        return value.isNotEmpty && !RegExp(r'\d').hasMatch(value);
      default:
        return true;
    }
  }

  void _saveReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Receipt saved successfully!")),
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
          ? ScanView(
              isLoading: _isLoading,
              ocrText: _ocrText,
              wasCleared: _wasCleared,
              onScan: scanReceipt,
              onClear: _clearText,
              onSave: _saveReceipt,
              extractedDate: extractedDate,
              extractedTotal: extractedTotal,
              extractedQuantity: extractedQuantity,
              extractedMerchant: extractedMerchant,
              onEditField: (label, value) {
                if (_validateInput(label, value)) {
                  setState(() {
                    switch (label) {
                      case "Date:":
                        extractedDate = value;
                        break;
                      case "Total:":
                        extractedTotal = value;
                        break;
                      case "Quantity:":
                        extractedQuantity = value;
                        break;
                      case "Merchant:":
                        extractedMerchant = value;
                        break;
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid format for \$label")),
                  );
                }
              },
            )
          : _selectedIndex == 1
              ? const HistoryView()
              : const SettingsView(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: myBlue,
        onTap: _onItem,
      ),
    );
  }
}
