import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Receipt {
  final String merchant;
  final DateTime date;
  final double total;

  Receipt({required this.merchant, required this.date, required this.total});

  factory Receipt.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parse(json['date']);
    } catch (_) {
      parsedDate = DateFormat('dd.MM.yyyy').parse(json['date']);
    }

    return Receipt(
      merchant: json['merchant'],
      date: parsedDate,
      total: double.parse(json['total'].replaceAll(',', '.')),
    );
  }
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<Receipt> allReceipts = [];
  List<Receipt> filteredReceipts = [];
  TextEditingController searchController = TextEditingController();
  final Color myBlue = const Color.fromARGB(255, 45, 51, 107);

  @override
  void initState() {
    super.initState();
    fetchReceipts();
    searchController.addListener(_onSearchChanged);
  }

  void fetchReceipts() async {
    final url = 'http://10.0.2.2:5000/api/receipts';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Receipt> fetched = [];
        for (var e in jsonData) {
          try {
            fetched.add(Receipt.fromJson(e));
          } catch (err) {
            print('Eroare la parsing bon: $e, err: $err');
          }
        }
        setState(() {
          allReceipts = fetched;
          filteredReceipts = fetched;
        });
      } else {
        print('Eroare server: ${response.statusCode}');
      }
    } catch (e) {
      print('Eroare fetch: $e');
    }
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredReceipts = allReceipts.where((receipt) =>
        receipt.merchant.toLowerCase().contains(query)
      ).toList();
    });
  }

  Map<String, List<Receipt>> groupReceiptsByDay(List<Receipt> receipts) {
    Map<String, List<Receipt>> grouped = {};
    for (var receipt in receipts) {
      final key = DateFormat('dd.MM.yyyy').format(receipt.date);
      grouped.putIfAbsent(key, () => []).add(receipt);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateFormat('dd.MM.yyyy').parse(b).compareTo(DateFormat('dd.MM.yyyy').parse(a)));

    return {
      for (var key in sortedKeys) key: grouped[key]!
    };
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedReceipts = groupReceiptsByDay(filteredReceipts);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search receipts',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: groupedReceipts.isEmpty
              ? const Center(child: Text('Nu exista bonuri'))
              : ListView(
                  children: groupedReceipts.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '${entry.key}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...entry.value.map((receipt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: myBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: myBlue.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    receipt.merchant,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('${receipt.total.toStringAsFixed(2)} RON'),
                                  leading: const Icon(Icons.receipt_long),
                                  onTap: () {
                                    // navigare catre detalii
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        )
      ],
    );
  }
}
