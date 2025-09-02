import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const Color primaryColor = Color(0xFF08695A);
  final String apiBase = 'http://10.0.2.2:8000';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _courses = [];

  // week navigation and day selection
  DateTime _weekStart = _startOfWeek(DateTime.now()); // Monday
  int _selectedWeekdayIndex = DateTime.now().weekday - 1; // 0=Mon..6=Sun

  static DateTime _startOfWeek(DateTime dt) {
    // return Monday of the week
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static String _formatMonthDayRange(DateTime start, DateTime end) {
    final startFmt = "${_monthName(start.month)} ${start.day}";
    final endFmt = "${_monthName(end.month)} ${end.day}";
    final year = end.year;
    return "$startFmt - $endFmt, $year";
  }

  static String _monthName(int m) {
    const names = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return names[m - 1];
  }

  final List<String> _daysShort = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(Uri.parse('$apiBase/api/classroom/courses?user_id=1'));
      if (res.statusCode != 200) {
        setState(() {
          _error = 'Server error: ${res.statusCode}\n${res.body}';
          _loading = false;
        });
        return;
      }
      final body = json.decode(res.body);
      final List raw = body['courses'] ?? [];
      // normalize to maps
      final List<Map<String, dynamic>> parsed = raw.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e as Map);
        // ensure days are list of short codes (Mon..Sun)
        map['days'] = (map['days'] is List) ? List<String>.from(map['days']) : <String>[];
        return map;
      }).toList();
      setState(() {
        _courses = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      // keep the same weekday selection when moving weeks
      if (_selectedWeekdayIndex < 0 || _selectedWeekdayIndex > 6) {
        _selectedWeekdayIndex = 0;
      }
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      // keep the same weekday selection when moving weeks
      if (_selectedWeekdayIndex < 0 || _selectedWeekdayIndex > 6) {
        _selectedWeekdayIndex = 0;
      }
    });
  }

  List<DateTime> _weekDates() {
    return List.generate(7, (i) => _weekStart.add(Duration(days: i)));
  }

  List<Map<String, dynamic>> _classesForSelectedDay() {
    final dayCode = _daysShort[_selectedWeekdayIndex];
    final List<Map<String, dynamic>> list = [];
    for (final c in _courses) {
      final days = (c['days'] as List).cast<String>();
      if (days.contains(dayCode)) list.add(c);
    }
    // sort by start_time if present
    list.sort((a, b) {
      final sa = a['start_time'] ?? '';
      final sb = b['start_time'] ?? '';
      return sa.compareTo(sb);
    });
    return list;
  }

  String _formatTimeRange(Map<String, dynamic> c) {
    final s = c['start_time'];
    final e = c['end_time'];
    if (s == null && e == null) return '';
    if (s != null && e != null) return "$s - $e";
    return s ?? e ?? '';
  }

  Widget _classCard(Map<String, dynamic> c) {
    final times = _formatTimeRange(c);
    final room = c['room'] ?? '';
    final instructor = (c['instructor'] ?? c['teacher'] ?? '').toString();
    final initials = (c['name'] ?? '').toString().trim().split(' ').map((s) => s.isEmpty ? '' : s[0]).take(2).join();

    final color = Colors.primaries[(c['id']?.hashCode ?? 0) % Colors.primaries.length];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // accent stripe
          Container(width: 6, height: 112, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                    if (times.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                        child: Text(times, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  if (room.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Flexible(child: Text(room, style: const TextStyle(color: Colors.black54))),
                    ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.15), child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(instructor, style: const TextStyle(color: Colors.black87))),
                    if (c['link'] != null)
                      IconButton(icon: const Icon(Icons.open_in_new, size: 18), onPressed: () {
                        // open link using url_launcher
                      }),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _weekDates();
    final weekEnd = weekDates[6];
    final weekRange = _formatMonthDayRange(weekDates[0], weekEnd);
    final classes = _classesForSelectedDay();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _prevWeek),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(weekRange, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text('Second Semester', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.black), onPressed: _nextWeek),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Text('Error', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_error!),
                    ElevatedButton(onPressed: _fetchCourses, child: const Text('Retry')),
                  ]),
                )
              : Column(
                  children: [
                    // weekday selector (Mon-Fri visible like design)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            // show Mon..Fri only
                            final dt = weekDates[i];
                            final dayShort = _daysShort[i];
                            final selected = _selectedWeekdayIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedWeekdayIndex = i),
                                child: Column(
                                  children: [
                                    Text(dayShort, style: TextStyle(color: selected ? primaryColor : Colors.black54)),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected ? primaryColor : Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Text('${dt.day}', style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        // scroll to full schedule or change view - currently no-op
                      },
                      child: const Text('View Class Schedule', style: TextStyle(decoration: TextDecoration.underline)),
                    ),

                    // classes list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RefreshIndicator(
                          onRefresh: _fetchCourses,
                          child: classes.isEmpty
                              ? ListView(children: const [SizedBox(height: 12), Center(child: Text('No classes for this day.', style: TextStyle(color: Colors.black54)))])
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: classes.length,
                                  itemBuilder: (context, idx) => _classCard(classes[idx]),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}