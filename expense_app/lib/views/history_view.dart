import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<String> allReceipts = []; // aici o sa vina bonurile de la server
  List<String> filteredReceipts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReceipts();
    searchController.addListener(_onSearchChanged);
  }

  void fetchReceipts() async {
    // Simulare fetch de la server - inlocuiesti cu requestul tau HTTP
    await Future.delayed(const Duration(seconds: 1));
    List<String> serverReceipts = [
      'Bon Mega Image',
      'Bon Carrefour',
      'Bon Lidl',
      'Bon Kaufland',
      'Bon Auchan'
    ];

    setState(() {
      allReceipts = serverReceipts;
      filteredReceipts = serverReceipts;
    });
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredReceipts = allReceipts.where((receipt) => receipt.toLowerCase().contains(query)).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search receipts',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
  child: filteredReceipts.isEmpty
      ? const Center(child: Text('Nu exista bonuri'))
      : ListView.builder(
          itemCount: filteredReceipts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    filteredReceipts[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.receipt_long),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // navigare catre detalii
                  },
                ),
              ),
            );
          },
        ),
    )
      ],
    );
  }
}