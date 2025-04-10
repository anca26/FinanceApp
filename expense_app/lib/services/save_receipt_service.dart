import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendReceiptToServer({
  required String date,
  required String total,
  required String merchant,
}) async {
  final uri = Uri.parse("http://10.0.2.2:5000/save");

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'date': date,
        'total': total,
        'merchant': merchant,
      }),
    );

    if (response.statusCode == 200) {
      print("Receipt saved successfully: ${response.body}");
    } else {
      print("Failed to save receipt: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending receipt: $e");
  }
}
