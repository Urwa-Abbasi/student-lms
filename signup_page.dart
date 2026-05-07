import 'package:flutter/material.dart';
import 'login_page.dart';
import 'api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _enrollmentController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  bool _isObscured = true;

  // Consistent Colors
  static const Color primaryPurple = Colors.deepPurple;

  void _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _enrollmentController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.redAccent);
      return;
    }

    setState(() => loading = true);
    try {
      final body = {
        'name': _nameController.text,
        'email': _emailController.text,
        'department': _departmentController.text,
        'enrollment': _enrollmentController.text,
        'password': _passwordController.text,
      };
      final result = await ApiService.signup(body);

      if (result['status'] == 'success') {
        _showSnackBar('Account Created Successfully!', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        _showSnackBar(
            result['message'] ?? 'Registration Failed', Colors.orangeAccent);
      }
    } catch (e) {
      _showSnackBar('Error connecting to backend', Colors.red);
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
                // LEFT SIDE: SIGNUP FORM
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
                        child: _buildSignupForm(),
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE: SIDE PICTURE (Same as Login Page)
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
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold),
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

  Widget _buildSignupForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person_add_rounded, color: primaryPurple, size: 70),
        const SizedBox(height: 10),
        const Text(
          'Join Hub',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
          ),
        ),
        const Text(
          'Create your account to get started',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        _buildInputField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _departmentController,
          label: 'Department',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _enrollmentController,
          label: 'Enrollment Number',
          icon: Icons.badge_outlined,
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
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already a member? ",
                style: TextStyle(color: Colors.black54)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                "Log In",
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
