import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class AttendancePage extends StatefulWidget {
  final String dept;
  final String course;

  const AttendancePage({super.key, required this.dept, required this.course});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> students = [];
  Map<String, String> attendanceMap = {};
  bool isLoading = true;

  String dbDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String displayDate = DateFormat('dd MMM, yyyy').format(DateTime.now());

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color neonGreen = const Color(0xFF10B981);
  final Color bgLight = const Color(0xFFF9FAFB);
  final Color darkSlate = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() async {
    try {
      final result = await ApiService.getStudents(widget.dept, widget.course);
      setState(() {
        students = result;
        for (var student in students) {
          attendanceMap[student['enrollment'].toString()] = "Present";
        }
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Error loading students", Colors.red);
      setState(() => isLoading = false);
    }
  }

  void _submitAttendance() async {
    if (students.isEmpty) {
      _showSnackBar("No students to mark attendance!", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    List<Map<String, String>> finalAttendanceList = students.map((s) {
      String enrollment = s['enrollment'].toString();
      String rawStatus = attendanceMap[enrollment] ?? "Present";

      return {
        "enrollment": enrollment,
        "name": s['name'].toString(),
        "status": rawStatus.toLowerCase(),
      };
    }).toList();

    try {
      final response = await ApiService.submitAttendance(
        course: widget.course,
        date: dbDate,
        attendanceData: finalAttendanceList,
      );

      if (response['status'] == 'success') {
        _showSnackBar("Attendance Submitted for $displayDate", neonGreen);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnackBar(response['message'] ?? "Failed to submit", Colors.orange);
      }
    } catch (e) {
      _showSnackBar("Connection Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: col,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: "Attendance",
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryPurple),
            items: [
              DropdownMenuItem(
                value: "Attendance",
                child: Text("Attendance Page",
                    style: TextStyle(
                        color: darkSlate,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              DropdownMenuItem(
                value: "Announcement",
                child: Text("Post Announcement",
                    style: TextStyle(
                        color: darkSlate,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ],
            onChanged: (value) {
              if (value == "Announcement") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementPage(
                        dept: widget.dept, course: widget.course),
                  ),
                );
              }
            },
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : Column(
              children: [
                _buildSummaryCard(),
                Expanded(
                  child: students.isEmpty
                      ? const Center(
                          child: Text("No students found in this department"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final enrollment = student['enrollment'].toString();
                            final currentStatus =
                                attendanceMap[enrollment] ?? "Present";
                            return _buildStudentTile(student, currentStatus);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSummaryCard() {
    int presentCount = attendanceMap.values.where((v) => v == "Present").length;
    int absentCount = students.length - presentCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryPurple, primaryPurple.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: primaryPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total", "${students.length}"),
          Container(height: 30, width: 1, color: Colors.white24),
          _summaryItem("Present", "$presentCount"),
          Container(height: 30, width: 1, color: Colors.white24),
          _summaryItem("Absent", "$absentCount"),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStudentTile(Map student, String currentStatus) {
    bool isPresent = currentStatus == "Present";
    String enrollment = student['enrollment'].toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(
            color: isPresent
                ? neonGreen.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isPresent
              ? neonGreen.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Text(student['name'][0].toUpperCase(),
              style: TextStyle(
                  color: isPresent ? neonGreen : Colors.red,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(student['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(enrollment,
            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(
                value: "Present",
                label: Text("P"),
                icon: Icon(Icons.check_circle_outline, size: 16)),
            ButtonSegment(
                value: "Absent",
                label: Text("A"),
                icon: Icon(Icons.cancel_outlined, size: 16)),
          ],
          selected: {currentStatus},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              attendanceMap[enrollment] = newSelection.first;
            });
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            side: WidgetStateProperty.all(BorderSide.none),
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return isPresent ? neonGreen : Colors.red;
              }
              return bgLight;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return Colors.grey;
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text("Final Submit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- Announcement Page ---
class AnnouncementPage extends StatefulWidget {
  final String dept;
  final String course;

  const AnnouncementPage({super.key, required this.dept, required this.course});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final TextEditingController _announcementController = TextEditingController();
  bool isPosting = false;
  final Color primaryPurple = const Color(0xFF8B5CF6);

  void _postAnnouncement() async {
    if (_announcementController.text.trim().isEmpty) return;
    setState(() => isPosting = true);
    try {
      final response = await ApiService.postAnnouncement(
        dept: widget.dept,
        course: widget.course,
        content: _announcementController.text.trim(),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Posted!"), backgroundColor: Colors.green));
        _announcementController.clear();
      }
    } finally {
      setState(() => isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
          title: const Text("Post Announcement",
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _announcementController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter announcement...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPosting ? null : _postAnnouncement,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post to Students",
                      style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
