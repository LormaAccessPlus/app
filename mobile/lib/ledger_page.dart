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

      // DEBUG: print request info, status and raw body
      print('ledger api url: $url');
      print('ledger api status: ${response.statusCode}');
      print('ledger api headers: ${response.headers}');
      print('ledger api response.body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data = jsonBody is List ? jsonBody : (jsonBody['data'] ?? []);

        // DEBUG: print parsed data structure
        print('ledger parsed data: $data');

        // normalize each item to Map<String, dynamic>
        ledgerEntries = data.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);

          // normalize common key casings and alternate names
          m['LedgerDate'] = m['LedgerDate'] ?? m['ledgerdate'] ?? m['Ledger_Date'] ?? m['ledgerDate'];
          m['Particulars'] = m['Particulars'] ?? m['particulars'] ?? m['Particular'];
          m['ORNumber'] = m['ORNumber'] ?? m['ornumber'] ?? m['OR_No'];
          m['Debit'] = m['Debit'] ?? m['debit'];
          m['Credit'] = m['Credit'] ?? m['credit'];

          m['Term'] = m['Term'] ?? m['term'] ?? m['TERM'];
          m['SchoolYear'] = m['SchoolYear'] ?? m['schoolYear'] ?? m['schoolyear'] ?? m['SCHOOLYEAR'];
          m['Notes'] = m['Notes'] ?? m['notes'] ?? m['NOTES'];
          m['LastModifiedBy'] = m['LastModifiedBy'] ?? m['lastModifiedBy'] ?? m['lastmodifiedby'];
          m['TransID'] = m['TransID'] ?? m['transid'] ?? m['TransId'];

          // DEBUG: print keys present for this item
          print('ledger entry keys: ${m.keys.toList()}');
          return m;
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e, st) {
      print('ledger load error: $e\n$st');
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
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: ledgerEntries.length,
                      itemBuilder: (context, index) {
                        final entry = ledgerEntries[index];
                        final term = entry['Term'] ?? '-';
                        final schoolYear = entry['SchoolYear'] ?? '-';
                        final date = entry['LedgerDate'] ?? '-';
                        final particulars = entry['Particulars'] ?? '-';
                        final notes = entry['Notes'] ?? '-';
                        final lastModifiedBy = entry['LastModifiedBy'] ?? '-';
                        final debit =
                            double.tryParse(entry['Debit'].toString()) ?? 0.0;
                        final credit =
                            double.tryParse(entry['Credit'].toString()) ?? 0.0;
                        final orNumber = entry['ORNumber'] ?? "-";
                        final transId = entry['TransID']?.toString() ?? "-";
                        final balance = _calculateRunningBalance(index);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      date.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₱${balance.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("Term: $term", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                Text("School Year: $schoolYear", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                Text("Particulars: $particulars", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                Text("Notes: $notes", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                Text("Last Modified By: $lastModifiedBy", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _LedgerAmount(
                                      label: "Debit",
                                      value: debit,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 16),
                                    _LedgerAmount(
                                      label: "Credit",
                                      value: credit,
                                      color: Colors.green,
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "OR #",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          orNumber.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "TransID: $transId",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _LedgerAmount extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _LedgerAmount({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
        ),
        Text(
          "₱${value.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
