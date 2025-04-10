import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<String> scanReceiptFromImage(String imagePath) async {
  final uri = Uri.parse("http://10.0.2.2:5000/scan");

  final request = http.MultipartRequest("POST", uri);
  request.files.add(await http.MultipartFile.fromPath("image", imagePath));

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final decoded = jsonDecode(responseBody);
    return decoded['text'] ?? "Text empty.";
  } else {
    throw Exception("Server error: ${response.statusCode}");
  }
}