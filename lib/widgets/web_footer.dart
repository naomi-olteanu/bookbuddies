import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      color: Colors.grey[900], // Dark background for footer
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      child: SafeArea(
        child: Column(
          children: [
            // Top Section (Columns)
            isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildFooterContent(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFooterContent(context)
                      .map((e) => Padding(padding: const EdgeInsets.only(bottom: 30), child: e))
                      .toList(),
                ),
            
            const Divider(color: Colors.white24, height: 60),
            
            // Bottom Section (Copyright)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '© 2025 BookBuddies. All rights reserved.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Row(
                  children: [
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 16),
                    _socialIcon(Icons.camera_alt), // Instagram-ish
                    const SizedBox(width: 16),
                    _socialIcon(Icons.alternate_email), // Twitter-ish
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFooterContent(BuildContext context) {
    return [
      // 1. Brand Column
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.auto_stories, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'BookBuddies',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Connecting book lovers, one swap at a time. \nRead more, spend less, build community.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
      ),
      
      // 2. Quick Links
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Explore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _footerLink('Browse Books'),
            _footerLink('Community'),
            _footerLink('Top Rated Users'),
          ],
        ),
      ),

      // 3. Legal / Contact
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _footerLink('Help Center'),
            _footerLink('Privacy Policy'),
            _footerLink('Terms of Service'),
            _footerLink('Contact Us'),
          ],
        ),
      ),
    ];
  }

  Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {}, // Add navigation here
        child: Text(
          text,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }
}