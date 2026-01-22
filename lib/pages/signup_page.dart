import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = AuthService();
  final _userService = UserService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool isLoading = false;
  String error = '';

  void signup() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => error = 'Please fill in all fields');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final cred = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final user = AppUser(
        id: cred.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: 'user',
        rating: 5.0,
        favors: 10,
        bio: 'I love reading!',
        profilePicture: '',
        ratingSum: 5,
        ratingCount: 1,
        isBlocked: false,
      );

      await _userService.createUser(user);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().contains('email-already-in-use') 
              ? 'This email is already registered.' 
              : 'Signup failed. Please try again.';
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
              constraints: const BoxConstraints(maxWidth: 400),
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
                      const Icon(Icons.person_add, size: 48, color: AppColors.secondary),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join the community today',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: nameController,
                        decoration: _inputDecoration('Full Name', Icons.badge_outlined),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: _inputDecoration('Password', Icons.lock_outline),
                        obscureText: true,
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
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signup,
                          child: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Text('Sign Up'),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login'),
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