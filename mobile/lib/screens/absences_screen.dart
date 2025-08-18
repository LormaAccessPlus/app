import 'package:flutter/material.dart';

class AbsencesScreen extends StatelessWidget {
  const AbsencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example absence data
    final absences = [
      AbsenceRow('01-01-25', 'Capstone I', '01-01-25', 'Sick'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Absences'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semester Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF08695A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Second Semester 2024-2025",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 12),
            // Absences Table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFB9F5D8)),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFA7D7C5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _AbsenceTableHeader('Date'),
                        _AbsenceTableHeader('Subject'),
                        _AbsenceTableHeader('Recorded'),
                        _AbsenceTableHeader('Remarks'),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...absences.map((absence) => Row(
                        children: [
                          _AbsenceTableCell(absence.date),
                          _AbsenceTableCell(absence.subject),
                          _AbsenceTableCell(absence.recorded),
                          _AbsenceTableCell(absence.remarks),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbsenceRow {
  final String date;
  final String subject;
  final String recorded;
  final String remarks;
  AbsenceRow(this.date, this.subject, this.recorded, this.remarks);
}

class _AbsenceTableHeader extends StatelessWidget {
  final String label;
  const _AbsenceTableHeader(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _AbsenceTableCell extends StatelessWidget {
  final String value;
  const _AbsenceTableCell(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}