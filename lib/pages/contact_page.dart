import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/services/auth_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _auth = AuthService();
  final _userService = UserService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final user = await _userService.getUser(uid);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
          
          if (user != null) {
            _nameController.text = user.name;
            _emailController.text = user.email;
          }
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    if (_nameController.text.isEmpty || _messageController.text.isEmpty) return;

    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    if (mounted) {
      setState(() {
        _isSending = false;
        _messageController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent! We will get back to you soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return MainLayout(
      title: 'Contact Us',
      user: _currentUser,
      child: Column(
        children: [
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Have a question? Found a bug? You can contact us with the following form.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 60),

          if (isDesktop) 
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildContactInfo(context)),
                const SizedBox(width: 60),
                Expanded(flex: 2, child: _buildContactForm(context)),
              ],
            )
          else 
            Column(
              children: [
                _buildContactInfo(context),
                const SizedBox(height: 40),
                _buildContactForm(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(context, Icons.email_outlined, 'Email Us', 'support@bookbuddies.com'),
            const SizedBox(height: 32),
            _infoRow(context, Icons.location_on_outlined, 'Visit Us', 'Calea Victoriei\nBucuresti, Sector 1'),
            const SizedBox(height: 32),
            _infoRow(context, Icons.access_time, 'Working Hours', 'Mon - Fri: 9am - 5pm'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send a Message',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(context, 'Your Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration(context, 'Your Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: _inputDecoration(context, 'How can we help?'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                child: _isSending 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Send Message', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
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