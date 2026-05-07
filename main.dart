import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';
import 'attendance.dart';
import 'grades.dart';
import 'courses.dart';
import 'instructor.dart';
import 'registration.dart';
import 'profile.dart';

void main() {
  runApp(StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Hub', // Aapke portal ka naam
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF8B5CF6),
        // Dark mode background for Glassmorphism effects
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // 1. Logic for pages that need BOTH Name and Enrollment (Dashboard & Grades)
        if (settings.name == '/dashboard' || settings.name == '/grades') {
          final dynamic rawArgs = settings.arguments;
          Map<String, dynamic> args;

          // Checking if arguments are passed as a Map from the frontend
          if (rawArgs is Map<String, dynamic>) {
            args = rawArgs;
          } else {
            // Fallback: If only a String was passed, we handle it to prevent crashes
            args = {
              'enrollment': rawArgs is String ? rawArgs : 'N/A',
              'studentName': 'Student',
            };
          }

          if (settings.name == '/dashboard') {
            return MaterialPageRoute(
              builder: (context) => DashboardPage(
                enrollment: args['enrollment'] ?? 'N/A',
                studentName: args['studentName'] ?? 'Student',
              ),
            );
          }

          if (settings.name == '/grades') {
            return MaterialPageRoute(
              builder: (context) => GradesPage(
                enrollment: args['enrollment'] ?? 'N/A',
                studentName: args['studentName'] ?? 'Student',
              ),
            );
          }
        }

        // 2. Logic for pages that require only Enrollment String
        if (['/attendance', '/registration', '/profile']
            .contains(settings.name)) {
          final String enrollment = settings.arguments as String? ?? 'N/A';

          switch (settings.name) {
            case '/attendance':
              return MaterialPageRoute(
                  builder: (_) => AttendancePage(enrollment: enrollment));
            case '/registration':
              return MaterialPageRoute(
                  builder: (_) => RegistrationPage(enrollment: enrollment));
            case '/profile':
              return MaterialPageRoute(
                  builder: (_) => ProfilePage(enrollment: enrollment));
          }
        }
        return null;
      },
      // Static routes for pages without arguments
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/courses': (context) => CoursesPage(),
        '/instructor': (context) => InstructorPage(),
      },
    );
  }
}
