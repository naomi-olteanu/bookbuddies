import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  String error = '';
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Invalid email or password';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // for desktop
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.auto_stories, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to continue reading',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: emailController,
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: _inputDecoration('Password', Icons.lock_outline),
                        obscureText: true,
                        onSubmitted: (_) => login(), // enter for login
                      ),

                      if (error.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          child: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Text('Login'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        ),
                        child: const Text('Don\'t have an account? Sign up'),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      filled: true,
      fillColor: Theme.of(context).cardTheme.color,
    );
  }
}