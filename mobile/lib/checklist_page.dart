import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const Color primaryColor = Color(0xFF08695A);
  final _storage = const FlutterSecureStorage();
  final String apiBase = 'http://10.0.2.2:8000'; // adjust if backend host differs

  bool _loading = true;
  String? _error;
  String _selectedYear = '2024-2025';
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sid = await _storage.read(key: 'student_id');
      final token = await _storage.read(key: 'token');

      if (sid == null) {
        setState(() {
          _error = 'No student id saved. Please sign in.';
          _loading = false;
        });
        return;
      }

      // Try a few common endpoint shapes — adjust/remove as necessary
      final candidates = [
        Uri.parse('$apiBase/api/studsubjfeealignment/$sid'),
        Uri.parse('$apiBase/api/studsubjfeealignment?student_id=$sid'),
      ];

      http.Response? resp;
      for (final uri in candidates) {
        try {
          resp = await http.get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
          // stop at first 200
          if (resp.statusCode == 200) break;
        } catch (e) {
          // continue to next candidate
          debugPrint('Request to $uri failed: $e');
          resp = null;
        }
      }

      if (resp == null) {
        setState(() {
          _error = 'Request failed: no response from server';
          _loading = false;
        });
        return;
      }

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          _rows = data.map<Map<String, dynamic>>((e) {
            return {
              'Term': e['Term'] ?? e['term'] ?? '',
              'SchoolYear': e['SchoolYear'] ?? e['schoolYear'] ?? e['School Year'] ?? '',
              'SubjectID': e['SubjectID'] ?? e['subjectID'] ?? e['SubjectId'] ?? '',
              'Units': (e['Units'] ?? e['units'] ?? '').toString(),
            };
          }).toList();
        } else if (data is Map && data['data'] is List) {
          _rows = (data['data'] as List).map<Map<String, dynamic>>((e) {
            return {
              'Term': e['Term'] ?? '',
              'SchoolYear': e['SchoolYear'] ?? '',
              'SubjectID': e['SubjectID'] ?? '',
              'Units': (e['Units'] ?? '').toString(),
            };
          }).toList();
        } else {
          _rows = [];
        }

        setState(() {
          _loading = false;
        });
      } else {
        // include body to help debug server-side error/404 message
        setState(() {
          _error = 'Server error: ${resp!.statusCode}\n${resp.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Request failed: $e';
        _loading = false;
      });
    }
  }

  Map<String, List<Map<String, String>>> _groupByTermAndYear() {
    final Map<String, List<Map<String, String>>> grouped = {};
    for (final r in _rows) {
      final sy = (r['SchoolYear'] as String?) ?? '';
      if (sy != _selectedYear) continue;
      final term = (r['Term'] as String?) ?? 'Unknown';
      grouped.putIfAbsent(term, () => []);
      grouped[term]!.add({
        'SubjectID': (r['SubjectID'] as String?) ?? '',
        'Units': (r['Units'] as String?) ?? '',
      });
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedYear,
                          items: const [
                            DropdownMenuItem(value: '2024-2025', child: Text('2024-2025')),
                            DropdownMenuItem(value: '2023-2024', child: Text('2023-2024')),
                            DropdownMenuItem(value: '2022-2023', child: Text('2022-2023')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedYear = v;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadChecklist,
                ),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (_rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No checklist items found for selected year.'),
                    )
                  else
                    ..._groupByTermAndYear().entries.map((entry) {
                      final term = entry.key;
                      final courses = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                term,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: courses.map((c) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            c['SubjectID'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '', // no title from table; leave empty or fetch if available
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 36,
                                          child: Text(
                                            c['Units'] ?? '',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}