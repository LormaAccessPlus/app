import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final _storage = const FlutterSecureStorage();
  String _selectedYear = 'A.Y 2024-2025';
  final List<String> _years = [
    'A.Y 2024-2025',
    'A.Y 2023-2024',
    'A.Y 2022-2023',
  ];

  bool _loading = false;
  String? _error;
  Map<String, dynamic> _dataByYear = {}; // AY -> { Semester -> [subjects] }
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _studentId = await _storage.read(key: 'student_id');
    if (_studentId != null) await _loadGrades();
  }

  Future<void> _loadGrades() async {
    if (_studentId == null) {
      setState(() => _error = 'No student id found');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:8000/api/grades')
          .replace(queryParameters: {'student_id': _studentId!, 'year': _selectedYear});
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          setState(() {
            _dataByYear = (body['data'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
          });
        } else {
          setState(() => _error = body['message']?.toString() ?? 'Failed to load grades');
        }
      } else {
        setState(() => _error = 'Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Request failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _semesterCard(String title, List<dynamic> subjects) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade700, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(flex: 3, child: Text('Subject', style: TextStyle(color: Colors.black54))),
                  Expanded(child: Text('Prelim', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                  Expanded(child: Text('Midterm', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                  Expanded(child: Text('Finals', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                  Expanded(child: Text('Final', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              ...subjects.map((s) {
                final subj = s as Map<String, dynamic>;
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text(subj['subject'] ?? '', style: const TextStyle(color: Colors.black87))),
                        Expanded(child: Text(subj['prelim']?.toString() ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text(subj['midterm']?.toString() ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text(subj['finals']?.toString() ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text(subj['final']?.toString() ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayData = _dataByYear[_selectedYear] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedYear = v);
                        _loadGrades();
                      },
                    ),
                  ),
                  if (_loading) const CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
              const SizedBox(height: 8),
              if (_error != null) Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          if (ayData != null && ayData.isNotEmpty) ...[
                            for (final sem in ayData.keys)
                              _semesterCard(sem, (ayData[sem] as List<dynamic>?) ?? []),
                          ] else ...[
                            // fallback: show two empty semester cards when no data
                            _semesterCard('First Semester', []),
                            _semesterCard('Second Semester', []),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}