import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'history_view.dart';

class ReceiptDetailsPage extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailsPage({super.key, required this.receipt});

  Future<void> _confirmAndDelete(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Esti sigur?'),
      content: const Text('Vrei sa stergi acest bon? Actiunea este permanenta.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Nu'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
            final success = await _deleteReceipt(receipt.id);
            if (success) {
              Navigator.of(context).pop(receipt.id);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Eroare la stergere')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 60, 51, 139)),
          child: const Text('Sterge', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<bool> _updateCategory(int receiptId, String category) async {
    try {
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:5000/api/receipts/$receiptId'),
        headers: {'Content-Type': 'application/json'},
        body: '{"category": "$category"}'
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }



  Future<bool> _deleteReceipt(int receiptId) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:5000/api/receipts/$receiptId'));
      return response.statusCode == 200;
    } catch (e) {
      print('Eroare la stergere: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          receipt.merchant,
          style: const TextStyle(color: Color.fromARGB(255, 60, 51, 139)),
          ),
        backgroundColor: const Color.fromARGB(255, 178, 171, 240),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 60, 51, 139)),
            onPressed: () => _confirmAndDelete(context),
          )
        ],
      ),
       body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Merchant: ${receipt.merchant}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('dd.MM.yyyy').format(receipt.date)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${receipt.total.toStringAsFixed(2)} RON',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
             DropdownButtonFormField<String>(
              value: receipt.category,  
              items: [
                'Clothing',
                'Traveling',
                'Groceries',
                'Electronics',
                'Dining',
                'Others'
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) async {
              if (value != null) {
                final success = await _updateCategory(receipt.id, value);
                if (success) {
                  receipt.category = value;  
                  print('Category updated to: $value');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error updating category')),
                  );
                }
              }
            },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
