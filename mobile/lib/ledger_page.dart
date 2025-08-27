import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  final _storage = const FlutterSecureStorage();
  String? studentId;
  List<Map<String, dynamic>> ledgerEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    final sid = await _storage.read(key: 'student_id');
    setState(() {
      studentId = sid;
      isLoading = true;
    });

    if (sid == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final url = Uri.parse("http://10.0.2.2:8000/api/ledger/$sid");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data =
            jsonBody is List ? jsonBody : jsonBody['data'];

        setState(() {
          ledgerEntries = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  double _calculateRunningBalance(int index) {
    double balance = 0.0;
    for (int i = 0; i <= index; i++) {
      balance += double.tryParse(ledgerEntries[i]['Debit'].toString()) ?? 0.0;
      balance -= double.tryParse(ledgerEntries[i]['Credit'].toString()) ?? 0.0;
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Ledger"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentId == null
              ? const Center(child: Text("No Student ID found"))
              : ledgerEntries.isEmpty
                  ? const Center(child: Text("No ledger records found"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      scrollDirection: Axis.horizontal, // ✅ Enables horizontal scroll on mobile
                      child: DataTable(
                        columnSpacing: 16,
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        columns: const [
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Particulars")),
                          DataColumn(label: Text("Debit")),
                          DataColumn(label: Text("Credit")),
                          DataColumn(label: Text("OR #")),
                          DataColumn(label: Text("Balance")),
                        ],
                        rows: List.generate(ledgerEntries.length, (index) {
                          final entry = ledgerEntries[index];
                          final date = entry['LedgerDate'] ?? '-';
                          final particulars = entry['Particulars'] ?? '-';
                          final debit =
                              double.tryParse(entry['Debit'].toString()) ?? 0.0;
                          final credit =
                              double.tryParse(entry['Credit'].toString()) ?? 0.0;
                          final orNumber = entry['ORNumber'] ?? "-";
                          final balance = _calculateRunningBalance(index);

                          return DataRow(cells: [
                            DataCell(Text(date.toString())),
                            DataCell(Text(particulars.toString())),
                            DataCell(Text("₱${debit.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.red))),
                            DataCell(Text("₱${credit.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.green))),
                            DataCell(Text(orNumber.toString())),
                            DataCell(Text("₱${balance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey))),
                          ]);
                        }),
                      ),
                    ),
    );
  }
}
