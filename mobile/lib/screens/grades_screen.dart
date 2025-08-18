import 'package:flutter/material.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String selectedYear = 'A.Y 2024-2025';
  final List<String> years = ['A.Y 2024-2025', 'A.Y 2023-2024'];

  // Example grades data
  final Map<String, List<_SemesterGrades>> yearGrades = {
    'A.Y 2024-2025': [
      _SemesterGrades(
        title: 'First Semester',
        grades: [
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
        ],
      ),
      _SemesterGrades(
        title: 'Second Semester',
        grades: [
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
          _GradeRow('Advanced Calculus', 99, 99, 99, 99),
        ],
      ),
    ],
    'A.Y 2023-2024': [
      _SemesterGrades(
        title: 'First Semester',
        grades: [
          _GradeRow('Algebra', 95, 96, 97, 98),
        ],
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final semesters = yearGrades[selectedYear]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Grades'),
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
            // Grades Cards
            Expanded(
              child: ListView.builder(
                itemCount: semesters.length,
                itemBuilder: (context, semIndex) {
                  final sem = semesters[semIndex];
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.shade200, width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Semester Header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Text(
                            sem.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2, // Changed from 3 to 2 for a shorter subject column
                                child: Text('Subject', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Expanded(child: Center(child: Text('Prelim', style: TextStyle(fontWeight: FontWeight.w600)))),
                              Expanded(child: Center(child: Text('Midterm', style: TextStyle(fontWeight: FontWeight.w600)))),
                              Expanded(child: Center(child: Text('Finals', style: TextStyle(fontWeight: FontWeight.w600)))),
                              Expanded(child: Center(child: Text('Final', style: TextStyle(fontWeight: FontWeight.w600)))),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        // Grades Rows
                        ...sem.grades.map((grade) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2, // Changed from 3 to 2 for a shorter subject column
                                    child: Text(
                                      grade.subject,
                                      style: TextStyle(fontSize: 14),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(child: Text('${grade.prelim}', style: TextStyle(fontSize: 14))),
                                  ),
                                  Expanded(
                                    child: Center(child: Text('${grade.midterm}', style: TextStyle(fontSize: 14))),
                                  ),
                                  Expanded(
                                    child: Center(child: Text('${grade.finals}', style: TextStyle(fontSize: 14))),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '${grade.finalGrade}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterGrades {
  final String title;
  final List<_GradeRow> grades;
  _SemesterGrades({required this.title, required this.grades});
}

class _GradeRow {
  final String subject;
  final int prelim;
  final int midterm;
  final int finals;
  final int finalGrade;
  _GradeRow(this.subject, this.prelim, this.midterm, this.finals, this.finalGrade);
}