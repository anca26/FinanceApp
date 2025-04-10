import 'package:flutter/material.dart';

class ScanView extends StatelessWidget {
  final bool isLoading;
  final String ocrText;
  final bool wasCleared;
  final VoidCallback onScan;
  final VoidCallback onClear;
  final VoidCallback onSave; 

  final String extractedDate;
  final String extractedTotal;
  final String extractedQuantity;
  final String extractedMerchant;

  final Color myBlue = const Color.fromARGB(255, 45, 51, 107);
  final Color myWhite = const Color.fromARGB(255, 255, 242, 242);
  final Function(String label, String newValue) onEditField;

  const ScanView({
    super.key,
    required this.isLoading,
    required this.ocrText,
    required this.wasCleared,
    required this.onScan,
    required this.onClear,
    required this.onSave, 
    required this.extractedDate,
    required this.extractedTotal,
    required this.extractedQuantity,
    required this.extractedMerchant,
    required this.onEditField,
  });

  Widget buildEditableRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text(value),
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController(text: value);
                    return AlertDialog(
                      title: Text('Edit $label'),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
                      ],
                    );
                  },
                );
                if (result != null) onEditField(label, result);
              },
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showBox = ocrText.trim().isNotEmpty || isLoading;

    return SingleChildScrollView(
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
                  onPressed: onClear,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      child: Text(
                        ocrText.isEmpty ? "No receipt" : ocrText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: wasCleared ? FontStyle.italic : FontStyle.normal,
                          color: wasCleared ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 30),
          if (!showBox)
            Center(
              child: ElevatedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Scan a receipt"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (showBox) ...[
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan receipt"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            if (ocrText.trim().isNotEmpty && !wasCleared)
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
                      buildEditableRow(context, "Date:", extractedDate),
                      const SizedBox(height: 8),
                      buildEditableRow(context, "Total:", extractedTotal),
                      const SizedBox(height: 8),
                      buildEditableRow(context, "Quantity:", extractedQuantity),
                      const SizedBox(height: 8),
                      buildEditableRow(context, "Merchant:", extractedMerchant),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: onSave, 
                        icon: const Icon(Icons.save),
                        label: const Text("Save Receipt"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myBlue,
                          foregroundColor: myWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
