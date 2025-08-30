import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  final _storage = const FlutterSecureStorage();
  final String apiBase = 'http://10.0.2.2:8000';
  bool isLoading = true;
  List<Map<String, dynamic>> absences = [];

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    final sid = await _storage.read(key: 'student_id');
    if (sid == null) {
      setState(() {
        isLoading = false;
        absences = [];
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      final url = Uri.parse('$apiBase/api/absences/$sid');
      final resp = await http.get(url);
      // debug
      print('absences url: $url');
      print('absences status: ${resp.statusCode}');
      print('absences body: ${resp.body}');

      if (resp.statusCode == 200) {
        final parsed = jsonDecode(resp.body);
        final List<dynamic> data = parsed is List ? parsed : (parsed['data'] ?? []);
        absences = data.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          m['AbsDate'] = m['AbsDate'] ?? m['absdate'] ?? m['Abs_Date'] ?? '-';
          m['Remarks'] = m['Remarks'] ?? m['remarks'] ?? '-';
          m['RecordedBy'] = m['RecordedBy'] ?? m['recordedBy'] ?? m['recordedby'] ?? '-';
          m['RecordedDate'] = m['RecordedDate'] ?? m['recordedDate'] ?? m['recordeddate'] ?? '-';
          m['Hours'] = m['Hours'] ?? m['hours'] ?? 0;
          m['SchedID'] = m['SchedID'] ?? m['schedid'] ?? '-';
          return m;
        }).toList();
      } else {
        absences = [];
      }
    } catch (e, st) {
      print('loadAbsences error: $e\n$st');
      absences = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absences')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : absences.isEmpty
              ? const Center(child: Text('No absences found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: absences.length,
                  itemBuilder: (context, i) {
                    final a = absences[i];
                    final date = a['AbsDate']?.toString() ?? '-';
                    final remarks = a['Remarks']?.toString() ?? '-';
                    final hours = (a['Hours'] != null) ? double.tryParse(a['Hours'].toString()) ?? 0.0 : 0.0;
                    final recordedBy = a['RecordedBy']?.toString() ?? '-';
                    final recordedDate = a['RecordedDate']?.toString() ?? '-';
                    final sched = a['SchedID']?.toString() ?? '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text('Hours: ${hours.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54)),
                            ]),
                            const SizedBox(height: 8),
                            Text('SchedID: $sched', style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 6),
                            Text('Remarks: $remarks'),
                            const SizedBox(height: 6),
                            Text('Recorded By: $recordedBy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Recorded Date: $recordedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}