import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';

class AttendancePage extends StatefulWidget {
  final String enrollment;
  const AttendancePage({super.key, required this.enrollment});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> attendance = [];
  bool loading = true;
  final Color primaryPurple = const Color(0xFF8B5CF6);

  final List<Color> chartColors = [
    const Color(0xFF60A5FA), // Blue
    const Color(0xFFFBBF24), // Amber
    const Color(0xFF34D399), // Emerald
    const Color(0xFFF87171), // Red
    const Color(0xFFA78BFA), // Purple
    const Color(0xFF2DD4BF), // Teal
  ];

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  void fetchAttendance() async {
    try {
      final result = await ApiService.getAttendance(widget.enrollment);
      setState(() {
        attendance = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Error: $e");
    }
  }

  double calculatePercentage() {
    if (attendance.isEmpty) return 0;
    int present = attendance
        .where((a) => a['status'].toString().toLowerCase() == 'present')
        .length;
    return (present / attendance.length) * 100;
  }

  List<PieChartSectionData> getSections() {
    Map<String, int> subjectCounts = {};
    for (var item in attendance) {
      String sub = item['subject']?.toString() ?? 'Other';
      subjectCounts[sub] = (subjectCounts[sub] ?? 0) + 1;
    }

    int i = 0;
    return subjectCounts.entries.map((entry) {
      final color = chartColors[i % chartColors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 65, // Chart size bara karne ke liye radius barhaya
        titleStyle: const TextStyle(
          fontSize: 22, // <--- Baray Fonts
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Attendance History',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSummaryHeader(),
                  if (attendance.isNotEmpty) _buildChartCard(),
                  _buildRecentLogsTitle(),
                  _buildAttendanceList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryHeader() {
    double perc = calculatePercentage();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("Overall Attendance",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 10),
          Text("${perc.toStringAsFixed(1)}%",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: perc / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    Map<String, int> subjectCounts = {};
    for (var item in attendance) {
      String sub = item['subject']?.toString() ?? 'Other';
      subjectCounts[sub] = (subjectCounts[sub] ?? 0) + 1;
    }
    List<String> subjects = subjectCounts.keys.toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Text("Subject-wise Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 35),

          // Chart ab Center mein hai
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 5,
                  centerSpaceRadius: 40,
                  sections: getSections(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          // Centered Wrap for Subjects
          Wrap(
            spacing: 20,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: subjects.asMap().entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: chartColors[entry.key % chartColors.length],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${entry.value} (${subjectCounts[entry.value]})",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("Recent Logs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (attendance.isEmpty) return const SizedBox();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendance.length,
      itemBuilder: (context, index) {
        final item = attendance[index];
        bool isPresent = item['status'].toString().toLowerCase() == 'present';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
            ],
          ),
          child: Row(
            children: [
              Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['subject'] ?? 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(item['date'].toString().split(' ')[0],
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status'].toString().toUpperCase(),
                  style: TextStyle(
                      color: isPresent ? Colors.green[700] : Colors.red[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
