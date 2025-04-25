import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> sendReceiptToServer({
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
    return response;
  } catch (e) {
    throw Exception("Error sending receipt: $e");
  }
}
