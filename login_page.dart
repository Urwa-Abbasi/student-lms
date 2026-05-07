import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';
import 'api_service.dart';
import 'attendance_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _enrollmentController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;
  bool _isObscured = true;
  String selectedRole = "Student";

  // Consistent Colors from Signup UI
  static const Color primaryPurple = Colors.deepPurple;

  @override
  void dispose() {
    _enrollmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_enrollmentController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Enrollment and Password are required', Colors.redAccent);
      return;
    }

    setState(() => loading = true);

    try {
      final result = await ApiService.login(
        _enrollmentController.text,
        _passwordController.text,
        role: selectedRole,
      );

      if (result['status'] == 'success') {
        if (selectedRole == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                enrollment: result['enrollment']?.toString() ??
                    _enrollmentController.text,
                studentName: result['name'] ?? "Student",
              ),
            ),
          );
        } else if (selectedRole == 'Teacher') {
          if (result['assignments'] != null) {
            _showTeacherSelectionDialog(result['name'], result['assignments']);
          } else {
            _showSnackBar('No teaching assignments found', Colors.orangeAccent);
          }
        }
      } else {
        _showSnackBar(
          result['message'] ?? 'Invalid Credentials',
          Colors.orangeAccent,
        );
      }
    } catch (e) {
      _showSnackBar('Server connection failed', Colors.red);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryPurple, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;

            return Row(
              children: [
                // LEFT SIDE: LOGIN FORM (Signup style white card)
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE: SIDE PICTURE (Signup style)
                if (!isMobile)
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/image/image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: primaryPurple.withOpacity(0.15),
                            child: const Center(
                              child: Text(
                                "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black26, blurRadius: 10)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_open_rounded, color: primaryPurple, size: 70),
        const SizedBox(height: 10),
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
          ),
        ),
        const Text(
          'Enter your credentials to continue',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),

        // Role Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              _buildRoleTab("Student"),
              _buildRoleTab("Teacher"),
            ],
          ),
        ),
        const SizedBox(height: 25),

        _buildInputField(
          controller: _enrollmentController,
          label:
              selectedRole == "Student" ? 'Enrollment Number' : 'Email Address',
          icon: selectedRole == "Student"
              ? Icons.badge_outlined
              : Icons.email_outlined,
        ),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 30),

        loading
            ? const CircularProgressIndicator(color: primaryPurple)
            : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 20),
        if (selectedRole == "Student")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? ",
                  style: TextStyle(color: Colors.black54)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                    color: primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRoleTab(String role) {
    bool isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryPurple),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
      ),
    );
  }

  void _showTeacherSelectionDialog(String teacherName, List assignments) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "Welcome Prof. $teacherName",
          style: const TextStyle(
              color: primaryPurple, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              var item = assignments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(item['course'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['department']),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: primaryPurple),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendancePage(
                          dept: item['department'],
                          course: item['course'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: col,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
