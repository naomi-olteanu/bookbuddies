import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/forum_post_model.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/services/forum_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreateForumPostPage extends StatefulWidget {
  final AppUser currentUser;
  const CreateForumPostPage({super.key, required this.currentUser});

  @override
  State<CreateForumPostPage> createState() => _CreateForumPostPageState();
}

class _CreateForumPostPageState extends State<CreateForumPostPage> {
  final _forumService = ForumService();
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _type = 'general';
  String _bookTitle = '';
  String _genre = '';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (widget.currentUser.isBlocked) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your account is blocked')),
    );
    return;
  }
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      if (_type == 'book') {
        final allowed = await _forumService.userCanCreateForumForBook(
          userId: widget.currentUser.id,
          bookTitle: _bookTitle,
        );
        if (!allowed) throw Exception('You already created a forum for this book.');
      }

      final now = DateTime.now();
      final post = ForumPost(
        id: '',
        title: _title,
        description: _description,
        type: _type,
        bookTitle: _type == 'book' ? _bookTitle : null,
        genre: _type == 'genre' ? _genre : null,
        createdBy: widget.currentUser.id,
        createdByName: widget.currentUser.name,
        createdAt: now,
        updatedAt: now,
        lastMessageAt: now,
        messageCount: 0,
        isClosed: false,
      );

      await _forumService.addForumPost(post);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: widget.currentUser,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create a New Discussion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Forum Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'book', child: Text('Book Specific')),
                    DropdownMenuItem(value: 'genre', child: Text('Genre Specific')),
                  ],
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 20),
                if (_type == 'book') ...[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Book Title', prefixIcon: Icon(Icons.book)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _bookTitle = v!,
                  ),
                  const SizedBox(height: 20),
                ],
                if (_type == 'genre') ...[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Genre', prefixIcon: Icon(Icons.category)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _genre = v!,
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Discussion Title'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _title = v!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description / First Message'),
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _description = v!,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Thread'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}