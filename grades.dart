import 'package:flutter/material.dart';

class GradesPage extends StatelessWidget {
  final String enrollment;
  final String studentName;

  const GradesPage({
    super.key,
    required this.enrollment,
    required this.studentName,
  });

  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color bgLight = Color(0xFFF9FAFB);

  final Map<String, List<Map<String, String>>> semesterData = const {
    'Semester 1': [
      {
        'desc': 'APPLIED PHYSICS',
        'cc': 'NS-106 T',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'ENGLISH COMPOSITION & COMPREHENSION',
        'cc': 'HS-100',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
      {
        'desc': 'PROGRAMMING FUNDAMENTALS - LAB',
        'cc': 'CS-104 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'LINEAR ALGEBRA',
        'cc': 'NS-201',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'INTRO TO INFO. & COMM. TECH - LAB',
        'cc': 'CS-107 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'PROGRAMMING FUNDAMENTALS',
        'cc': 'CS-104 T',
        'ch': '3',
        'grd': 'B+',
        'sts': 'Pass',
        'qp': '9.99'
      },
      {
        'desc': 'INTRO TO INFO. & COMM. TECH',
        'cc': 'CS-107 T',
        'ch': '2',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '7.34'
      },
      {
        'desc': 'APPLIED PHYSICS - LAB',
        'cc': 'NS-106 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
    ],
    'Semester 2': [
      {
        'desc': 'PAKISTAN STUDIES',
        'cc': 'HS-103',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'DISCRETE STRUCTURES',
        'cc': 'CS-103',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
      {
        'desc': 'INTRO TO SOFTWARE ENGINEERING',
        'cc': 'SE-100 T',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'WEB ENGINEERING - LAB',
        'cc': 'CS-102 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'WEB ENGINEERING',
        'cc': 'CS-102 T',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'OBJECT ORIENTED PROGRAMMING - LAB',
        'cc': 'CS-112 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'INTRO TO SOFTWARE ENG. - LAB',
        'cc': 'SE-100 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'PRINCIPLES OF ACCOUNTING',
        'cc': 'MS-101',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
      {
        'desc': 'OBJECT ORIENTED PROGRAMMING',
        'cc': 'CS-112 T',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
    ],
    'Semester 3': [
      {
        'desc': 'ISLAMIC STUDIES',
        'cc': 'HS-101',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'HUMAN COMPUTER INTERACTION',
        'cc': 'SE-244',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'SOFTWARE REQUIREMENT ENG.',
        'cc': 'SE-211',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'DATA STRUCTURES & ALGORITHMS',
        'cc': 'CS-232 T',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
      {
        'desc': 'HUMAN RESOURCE MANAGEMENT',
        'cc': 'MS-203',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'DATA STRUCTURES & ALGO - LAB',
        'cc': 'CS-232 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'CALCULUS & ANALYTICAL GEOMETRY',
        'cc': 'MT-101',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
    ],
    'Semester 4': [
      {
        'desc': 'OPERATING SYSTEM',
        'cc': 'CS-234 T',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'INTRO TO DATABASE SYSTEM - LAB',
        'cc': 'CS-233 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'INTRODUCTION TO DATABASE SYSTEM',
        'cc': 'CS-233 T',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
      {
        'desc': 'PROBABILITY AND STATISTICS',
        'cc': 'MT-206',
        'ch': '3',
        'grd': 'A-',
        'sts': 'Pass',
        'qp': '11.01'
      },
      {
        'desc': 'SOFTWARE ARCHITECTURE - LAB',
        'cc': 'SE-243 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'OPERATING SYSTEM - LAB',
        'cc': 'CS-234 L',
        'ch': '1',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '4.00'
      },
      {
        'desc': 'SOFTWARE ARCHITECTURE & DESIGN',
        'cc': 'SE-243 T',
        'ch': '2',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '8.00'
      },
      {
        'desc': 'PSYCHOLOGY',
        'cc': 'HS-207',
        'ch': '3',
        'grd': 'A',
        'sts': 'Pass',
        'qp': '12.00'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      // Purple AppBar Header
      appBar: AppBar(
        title: const Text(
          'Academic Hub',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(enrollment,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            letterSpacing: 0.5)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [neonGreen, Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Text("TOTAL CGPA",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text("3.85",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: semesterData.length,
              itemBuilder: (context, index) {
                final String semName = semesterData.keys.elementAt(index);
                return _buildSemesterCard(semName, semesterData[semName]!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(String title, List<Map<String, String>> subjects) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(color: primaryPurple),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              horizontalMargin: 20,
              headingRowHeight: 45,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(
                    label: Text("SUBJECT",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                DataColumn(
                    label: Text("CODE",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                DataColumn(
                    label: Text("CH",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                DataColumn(
                    label: Text("GRD",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                DataColumn(
                    label: Text("STATUS",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                DataColumn(
                    label: Text("QP",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
              ],
              rows: subjects.map((sub) {
                return DataRow(
                  cells: [
                    DataCell(SizedBox(
                        width: 140,
                        child: Text(sub['desc']!,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)))),
                    DataCell(Text(sub['cc']!,
                        style:
                            const TextStyle(fontSize: 9, color: Colors.grey))),
                    DataCell(Center(
                        child: Text(sub['ch']!,
                            style: const TextStyle(fontSize: 10)))),
                    DataCell(Center(
                        child: Text(sub['grd']!,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text("Pass",
                          style: TextStyle(
                              color: neonGreen,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    )),
                    DataCell(Center(
                        child: Text(sub['qp']!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54)))),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
