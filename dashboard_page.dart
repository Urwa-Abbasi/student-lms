import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class DashboardPage extends StatefulWidget {
  final String enrollment;
  final String studentName;

  const DashboardPage(
      {super.key, required this.enrollment, required this.studentName});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Color primaryPurple = const Color(0xFF9161F2);
  Color bgLight = const Color(0xFFF8F9FD);
  Color darkSlate = const Color(0xFF1E293B);
  int _selectedIndex = 0;

  String overallAttendance = "Loading...";
  String currentDate = "";
  String currentDayName = "";
  String currentTime = "";
  Timer? _timer;
  List<Map<String, dynamic>> dailySchedule = [];

  final List<String> timeSlots = [
    "8am",
    "9am",
    "10am",
    "11am",
    "12pm",
    "1pm",
    "2pm",
    "3pm",
    "4pm"
  ];

  @override
  void initState() {
    super.initState();
    _getRealDate();
    _fetchAttendance();
    _setupDailySchedule();

    // Timer setup
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getRealDate();
    });

    // ✅ Dashboard khulne ke 1.5 second baad announcement popup dikhayega
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _showAnnouncementPopup();
    });
  }

  // ✅ New Function: Notification Popup
  void _showAnnouncementPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: primaryPurple),
            const SizedBox(width: 10),
            const Text("Notice Board",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latest Update:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              "Welcome to your updated student portal! You can now track your attendance and grades in real-time.",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it",
                style: TextStyle(
                    color: primaryPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getRealDate() {
    var now = DateTime.now();
    setState(() {
      currentDate = DateFormat('MMMM d, yyyy').format(now);
      currentDayName = DateFormat('EEEE').format(now).toUpperCase();
      currentTime = DateFormat('hh:mm a').format(now);
    });
  }

  // ... (Attendance aur Schedule logic same hai) ...
  Future<void> _fetchAttendance() async {
    try {
      final summary = await ApiService.getAttendanceSummary(widget.enrollment);
      if (summary.isNotEmpty) {
        double totalAttended = 0, totalClasses = 0;
        for (var item in summary) {
          totalAttended += double.parse(item['attended'].toString());
          totalClasses += double.parse(item['total_classes'].toString());
        }
        setState(() => overallAttendance = totalClasses > 0
            ? "${((totalAttended / totalClasses) * 100).toStringAsFixed(1)}%"
            : "0.0%");
      }
    } catch (e) {
      setState(() => overallAttendance = "0.0%");
    }
  }

  void _setupDailySchedule() {
    switch (currentDayName) {
      case "TUESDAY":
        dailySchedule = [
          {
            "subject": "SOFTWARE CONSTRUCTION",
            "instructor": "Mr. Fahim",
            "color": Colors.blue,
            "start": 0.0,
            "width": 0.18
          },
          {
            "subject": "AUTOMATA THEORY",
            "instructor": "Mr. Fahim Uddin",
            "color": Colors.purple,
            "start": 0.18,
            "width": 0.18
          },
          {
            "subject": "COMPUTER NETWORKS",
            "instructor": "Mr. Umar Khan",
            "color": Colors.indigo,
            "start": 0.65,
            "width": 0.18
          },
        ];
        break;
      case "THURSDAY":
        dailySchedule = [
          {
            "subject": "CCN - LAB",
            "instructor": "Ms. Aleena Rehman",
            "color": Colors.green,
            "start": 0.08,
            "width": 0.35
          },
          {
            "subject": "COMMUNICATION SKILLS",
            "instructor": "Ms. Sania Zafar",
            "color": Colors.red,
            "start": 0.45,
            "width": 0.25
          },
          {
            "subject": "MOBILE APP - LAB",
            "instructor": "Ms. Marium",
            "color": Colors.orange,
            "start": 0.75,
            "width": 0.25
          },
        ];
        break;
      case "FRIDAY":
        dailySchedule = [
          {
            "subject": "MOBILE APPLICATION",
            "instructor": "Dr. Khalid",
            "color": Colors.teal,
            "start": 0.15,
            "width": 0.20
          },
          {
            "subject": "SCD - LAB",
            "instructor": "Mr. Ashar Ahmad",
            "color": Colors.blueGrey,
            "start": 0.40,
            "width": 0.30
          },
        ];
        break;
      default:
        dailySchedule = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1000;

    return Scaffold(
      backgroundColor: bgLight,
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile: true)) : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: primaryPurple),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(isMobile: false),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopProfile(),
                  const SizedBox(height: 30),
                  _buildHeroBanner(isMobile),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(width: 12),
                      Text("Academic Overview",
                          style: TextStyle(
                              fontSize: isMobile ? 22 : 26,
                              fontWeight: FontWeight.w900,
                              color: darkSlate)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _actionCard(
                          "View Grades",
                          "GPA: 3.8",
                          Icons.analytics_rounded,
                          [const Color(0xFF6366F1), const Color(0xFF818CF8)],
                          '/grades',
                          screenWidth),
                      _actionCard(
                          "Attendance",
                          overallAttendance,
                          Icons.event_available,
                          [const Color(0xFF10B981), const Color(0xFF34D399)],
                          '/attendance',
                          screenWidth),
                      _actionCard(
                          "Time",
                          currentTime,
                          Icons.access_time_filled_rounded,
                          [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
                          '/courses',
                          screenWidth),
                    ],
                  ),
                  const SizedBox(height: 50),
                  _buildTimetableHeader(),
                  const SizedBox(height: 25),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isMobile ? 800 : screenWidth - 350,
                      child: _buildModernTimetable(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String title, String val, IconData icon,
      List<Color> colors, String route, double sw) {
    double cardWidth =
        (sw < 700) ? (sw - 40) : (sw < 1100 ? (sw - 350) / 2 : 250);
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, route, arguments: widget.enrollment),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 25),
            Text(val,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            Text(title,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Sidebar, Profile, Banner, aur Timetable UI elements wese hi hain...
  Widget _buildTopProfile() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/profile',
            arguments: widget.enrollment),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(widget.studentName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                      fontSize: 16)),
              Text(widget.enrollment,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(width: 15),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                      color: primaryPurple.withOpacity(0.3), width: 2)),
              child: ClipOval(
                  child: Icon(Icons.person_rounded,
                      color: primaryPurple, size: 30)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    return Container(
      width: 260,
      color: primaryPurple,
      child: Column(children: [
        const SizedBox(height: 60),
        const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(Icons.school_rounded, color: Colors.white, size: 40)),
        const SizedBox(height: 50),
        _navItem(Icons.grid_view_rounded, "Dashboard", 0, '/dashboard'),
        _navItem(Icons.calendar_month_rounded, "Attendance", 1, '/attendance'),
        _navItem(Icons.assessment_rounded, "Grades", 2, '/grades'),
        _navItem(Icons.book_rounded, "Courses", 3, '/courses'),
        _navItem(
            Icons.app_registration_rounded, "Registration", 4, '/registration'),
        const Spacer(),
        _navItem(Icons.logout_rounded, "Logout", 5, '/'),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _navItem(IconData icon, String label, int index, String route) {
    bool isSel = _selectedIndex == index;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      onTap: () =>
          Navigator.pushNamed(context, route, arguments: widget.enrollment),
      leading: Icon(icon, color: isSel ? Colors.white : Colors.white60),
      title: Text(label,
          style: TextStyle(
              color: isSel ? Colors.white : Colors.white60,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildHeroBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 30 : 45),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryPurple, const Color(0xFFA78BFA)]),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentDate,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text("Welcome, ${widget.studentName}!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text("Your academic journey is looking great today.",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTimetableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
          color: primaryPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryPurple.withOpacity(0.15))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Class Timetable",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkSlate.withOpacity(0.8))),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 15,
              width: 1.5,
              color: primaryPurple.withOpacity(0.3)),
          Text(currentDayName,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: primaryPurple)),
        ],
      ),
    );
  }

  Widget _buildModernTimetable() {
    if (dailySchedule.isEmpty)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("No classes today",
                  style: TextStyle(color: Colors.grey))));
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 12))
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(children: [
        _timetableTopBar(),
        ...dailySchedule.map((l) => _timetableRow(l))
      ]),
    );
  }

  Widget _timetableTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Row(children: [
        const Expanded(
            flex: 3,
            child: Text("COURSE DETAILS",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.5))),
        Expanded(
            flex: 7,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: timeSlots
                    .map((time) => Text(time,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8))))
                    .toList())),
      ]),
    );
  }

  Widget _timetableRow(Map<String, dynamic> l) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['subject'],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: darkSlate)),
                      Text(l['instructor'],
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ]))),
        Expanded(
            flex: 7,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(children: [
                    Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8))),
                    Positioned(
                      left: constraints.maxWidth * l['start'],
                      width: constraints.maxWidth * l['width'],
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: (l['color'] as Color).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: (l['color'] as Color).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]),
                        child: const Center(
                            child: Text("LECTURE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2))),
                      ),
                    ),
                  ]);
                }))),
      ]),
    );
  }
}
