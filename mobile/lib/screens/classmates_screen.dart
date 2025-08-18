import 'package:flutter/material.dart';

class ClassmatesScreen extends StatelessWidget {
  const ClassmatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example classmates data
    final classmates = List.generate(
      9,
      (i) => {'name': 'George Washington', 'section': 'BSIT- III'},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Classmates'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown and Button Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'Capstone',
                    items: [
                      DropdownMenuItem(value: 'Capstone', child: Text('Capstone')),
                      // Add more subjects if needed
                    ],
                    onChanged: (v) {},
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF08695A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text("Show Classmates"),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Subject Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: "Subject:", value: "CAPSPRO1 Capstone Project 1"),
                  _InfoRow(label: "Units:", value: "3"),
                  _InfoRow(label: "Term:", value: "Second Semester 2024-2025"),
                  _InfoRow(label: "Teacher:", value: "MENDEZ, Janelli M."),
                  _InfoRow(label: "Department:", value: "College of Computer Studies and Engineering"),
                  _InfoRow(label: "Schedule:", value: "8:00 AM-9:30 AM MT @Room: CLI-404"),
                  _InfoRow(label: "For:", value: "BSIT-3-1-G1"),
                ],
              ),
            ),
            SizedBox(height: 18),
            // Classmates Grid
            Expanded(
              child: GridView.builder(
                itemCount: classmates.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final mate = classmates[index];
                  return Column(
                    children: [
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF08695A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        mate['name']!,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        mate['section']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}