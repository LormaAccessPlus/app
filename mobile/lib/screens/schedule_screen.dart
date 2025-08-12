import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range and Semester
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                Column(
                  children: [
                    Text(
                      "May 2 - May 8, 2025",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "Second Semester",
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
              ],
            ),
            SizedBox(height: 18),

            // Days Row
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DayCircle(day: "Mon", date: "4", selected: false),
                  _DayCircle(day: "Tue", date: "5", selected: false),
                  _DayCircle(day: "Wed", date: "6", selected: false),
                  _DayCircle(day: "Thu", date: "7", selected: false),
                  _DayCircle(day: "Fri", date: "8", selected: true),
                ],
              ),
            ),
            SizedBox(height: 10),

            // View Class Schedule Link
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "View Class Schedule",
                  style: TextStyle(
                    color: Color(0xFF08695A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),

            // Date Header
            Text(
              "Friday, May 8",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),

            // Classes List
            _ScheduleClassCard(
              subject: "Networking 2",
              time: "8:30 - 10:00 AM",
              location: "CLI Building, Room 301",
              teacher: "Dr. Ellen Ganda",
              teacherAvatar: Icons.person,
              color: Color(0xFFB9F5D8),
            ),
            _ScheduleClassCard(
              subject: "Event Driven Programming",
              time: "10:00 AM - 12:00 PM",
              location: "CLI Building, Room 301",
              teacher: "Engr. Gelo Pogi",
              teacherAvatar: Icons.person,
              color: Color(0xFFD0F2FF),
            ),
            _ScheduleClassCard(
              subject: "Christian Foundation and Values Education",
              time: "8:30 - 10:00 AM",
              location: "CLI Building, Room 301",
              teacher: "Dr. Jopher Matcho",
              teacherAvatar: Icons.person,
              color: Color(0xFFFFF3CD),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String day;
  final String date;
  final bool selected;

  const _DayCircle({
    required this.day,
    required this.date,
    required this.selected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: selected ? Color(0xFF08695A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Color(0xFF08695A) : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleClassCard extends StatelessWidget {
  final String subject;
  final String time;
  final String location;
  final String teacher;
  final IconData teacherAvatar;
  final Color color;

  const _ScheduleClassCard({
    required this.subject,
    required this.time,
    required this.location,
    required this.teacher,
    required this.teacherAvatar,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF08695A),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF08695A), size: 16),
              SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  color: Color(0xFF08695A),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[300],
                child: Icon(teacherAvatar, size: 18, color: Colors.grey[700]),
              ),
              SizedBox(width: 8),
              Text(
                teacher,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}