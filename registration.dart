import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'api_service.dart';

class RegistrationPage extends StatefulWidget {
  final String enrollment;
  const RegistrationPage({super.key, required this.enrollment});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  List<dynamic> courses = [];
  String? selectedCourse;
  bool loading = false;
  bool fetchingCourses = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
  }

  void fetchAvailableCourses() async {
    try {
      final result = await ApiService.getAvailableCourses(widget.enrollment);
      setState(() {
        courses = result;
        fetchingCourses = false;
      });
    } catch (e) {
      setState(() => fetchingCourses = false);
      _showSnackBar('Failed to load available courses');
    }
  }

  void handleRegistration() async {
    if (!_formKey.currentState!.validate() || selectedCourse == null) {
      _showSnackBar('Please fill all details and select a course');
      return;
    }

    setState(() => loading = true);
    try {
      final res = await ApiService.submitRegistration(
        enrollment: widget.enrollment,
        course: selectedCourse!,
        phone: _phoneController.text,
        semester: _semesterController.text,
      );

      if (res['status'] == 'success') {
        _showSuccessDialog();
      } else {
        _showSnackBar(res['message'] ?? 'Registration Failed');
      }
    } catch (e) {
      _showSnackBar('Error connecting to server');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Registered!"),
        content: const Text(
            "Your course has been registered successfully. Would you like to download the slip?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Later", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              generatePDF();
              Navigator.pop(context);
            },
            child: const Text("Download Slip",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Professional PDF Generation Logic ---
  void generatePDF() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ACADEMIC HUB',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.deepPurple)),
                      pw.Text('Student Registration Services',
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('OFFICIAL SLIP',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('COURSE REGISTRATION CONFIRMATION',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline)),
              ),
              pw.SizedBox(height: 30),
              // Table for professional layout
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  _buildTableRow('Enrollment Number', widget.enrollment),
                  _buildTableRow('Course Name', selectedCourse ?? 'N/A'),
                  _buildTableRow('Semester', _semesterController.text),
                  _buildTableRow('Contact Number', _phoneController.text),
                  _buildTableRow('Registration Date',
                      DateTime.now().toString().split(' ')[0]),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text('Important Instructions:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.Bullet(
                  text: 'Keep this slip safe for future academic references.'),
              pw.Bullet(
                  text: 'Ensure all details mentioned above are correct.'),
              pw.Bullet(
                  text: 'Contact the admin office in case of any discrepancy.'),
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by: Academic Hub Portal',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey600)),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom:
                                pw.BorderSide(width: 1, color: PdfColors.black),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Authorized Signature',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                    'This is a computer-generated document and does not require a physical stamp.',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey500)),
              ),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  // Helper function to build table rows for PDF
  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Academic Hub Registration",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 5))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.app_registration_rounded,
                          size: 60, color: Colors.deepPurple),
                      const SizedBox(height: 10),
                      const Text("Course Form",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      const SizedBox(height: 25),
                      TextFormField(
                        initialValue: widget.enrollment,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Enrollment Number",
                          prefixIcon:
                              const Icon(Icons.badge, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      fetchingCourses
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Course',
                                prefixIcon: const Icon(Icons.book,
                                    color: Colors.deepPurple),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              items: courses.map((course) {
                                return DropdownMenuItem<String>(
                                  value: course['course_name'],
                                  child: Text(course['course_name'],
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedCourse = val),
                              validator: (val) =>
                                  val == null ? 'Please select a course' : null,
                            ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your contact number' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _semesterController,
                        decoration: InputDecoration(
                          labelText: "Semester (e.g. 4th)",
                          prefixIcon: const Icon(Icons.layers,
                              color: Colors.deepPurple),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter semester' : null,
                      ),
                      const SizedBox(height: 30),
                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                onPressed: handleRegistration,
                                child: const Text('REGISTER COURSE',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
