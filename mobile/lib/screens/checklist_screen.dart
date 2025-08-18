import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String selectedYear = '2024-2025';
  final List<String> years = ['2024-2025', '2023-2024'];

  // Example curriculum data
  final Map<String, List<_SemesterSection>> yearSemesters = {
    '2024-2025': [
      _SemesterSection(
        title: 'First Semester',
        color: Color(0xFF08695A),
        subjects: [
          _SubjectRow('GECO7', 'Science, Technology, and society', '3.0'),
          _SubjectRow('NSTP', 'Civil Warfare', '3.0'),
          _SubjectRow('INTROCOM', 'Introduction To Computing', '3.0'),
          _SubjectRow('DISTRICT', 'Science, Technology, and society', '3.0'),
          _SubjectRow('GECO5', 'Purposive Communication', '3.0'),
          _SubjectRow('COMPRO1', 'Fundamentals if Problem Solving', '3.0'),
          _SubjectRow('PATHFIT', 'Physical Activities Towards H and F', '2.0'),
          _SubjectRow('CFVE', 'Christian Foundation and\nValues Education', '3.0'),
        ],
      ),
      _SemesterSection(
        title: 'I - Second Semester',
        color: Color(0xFF08695A),
        subjects: [
          _SubjectRow('COMPRO2', 'Intermediate Problem Solving and\nProgramming', '3.0'),
          _SubjectRow('DATASTUC', 'Data Structures and Algorithms lec/lab', '3.0'),
          _SubjectRow('WEBDEV1', 'Web Development 1 lec/lab', '3.0'),
          _SubjectRow('GECO1', 'Understanding Self', '3.0'),
          _SubjectRow('GECO4', 'Mathematics in the Modern World', '3.0'),
          _SubjectRow('CFVE2', 'Christian Foundation and\nValues Education 2', '3.0'),
          _SubjectRow('GEC01', 'Understanding Self', '3.0'),
        ],
      ),
    ],
    '2023-2024': [], // <-- Add this line to prevent the error
    // Add more years if needed
  };

  @override
  Widget build(BuildContext context) {
    final semesters = yearSemesters[selectedYear]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown for year selection
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[100],
                ),
                child: DropdownButton<String>(
                  value: selectedYear,
                  isExpanded: false,
                  underline: SizedBox(),
                  items: years
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text(y),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedYear = value);
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            // Curriculum Card
            Expanded(
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ListView.builder(
                    itemCount: semesters.length,
                    itemBuilder: (context, semIndex) {
                      final sem = semesters[semIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: sem.color,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(semIndex == 0 ? 10 : 0),
                                topRight: Radius.circular(semIndex == 0 ? 10 : 0),
                              ),
                            ),
                            child: Text(
                              sem.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.2),
                                1: FlexColumnWidth(2.5),
                                2: FlexColumnWidth(0.8),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: sem.subjects.map((subject) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Text(
                                        subject.code,
                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                      child: Text(
                                        subject.title,
                                        style: TextStyle(fontSize: 13),
                                        softWrap: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          subject.units,
                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterSection {
  final String title;
  final Color color;
  final List<_SubjectRow> subjects;
  _SemesterSection({required this.title, required this.color, required this.subjects});
}

class _SubjectRow {
  final String code;
  final String title;
  final String units;
  _SubjectRow(this.code, this.title, this.units);
}