import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  
  List<AppUser> _topUsers = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final allUsers = snapshot.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();

    // Score = (Rating * 10) + (Favors * 2)
    allUsers.sort((a, b) {
      final scoreA = (a.rating * 10) + (a.favors * 2);
      final scoreB = (b.rating * 10) + (b.favors * 2);
      return scoreB.compareTo(scoreA); // descending
    });

    AppUser? current;
    if (uid != null) {
      try {
        current = allUsers.firstWhere((u) => u.id == uid);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _topUsers = allUsers;
        _currentUser = current;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final top3 = _topUsers.take(3).toList();
    final rest = _topUsers.length > 3 ? _topUsers.sublist(3) : <AppUser>[];

    return MainLayout(
      title: 'Community Leaderboard',
      user: _currentUser,
      child: Column(
        children: [
          // 🏆 HEADER
          Text(
            'Community Hall of Fame',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recognizing our most active readers and lenders.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 40),

          if (top3.isNotEmpty)
            SizedBox(
              height: 320,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place
                  if (top3.length > 1) 
                    _buildPodiumUser(context, top3[1], 2, height: 220, color: Colors.grey.shade400),
                  
                  // 1st Place
                  _buildPodiumUser(context, top3[0], 1, height: 280, color: Colors.amber),

                  // 3rd Place
                  if (top3.length > 2) 
                    _buildPodiumUser(context, top3[2], 3, height: 180, color: Colors.brown.shade300),
                ],
              ),
            ),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            itemBuilder: (context, index) {
              final user = rest[index];
              final rank = index + 4;
              return _buildRankListTile(context, user, rank);
            },
          ),

          const SizedBox(height: 60),

          Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'How do we calculate the scores?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We believe in rewarding those who give back. Your Community Score reflects both your generosity and your reputation. The score is calculated as follows: Score = (Rating * 10) + (Favors * 2)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _scoreDetail(Icons.handshake, 'Lending Books', 'Earn Favor Points'),
                    Container(height: 40, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _scoreDetail(Icons.star, 'Quality Swaps', 'High Star Ratings'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreDetail(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 28),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPodiumUser(BuildContext context, AppUser user, int rank, {required double height, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar & Badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: color,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).cardColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Text(
                  '#$rank',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            user.name.split(' ').first, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            _calculateLevel(user),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          Container(
            width: 80,
            height: height - 120, 
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: color),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.black54),
                Text(
                  user.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankListTile(BuildContext context, AppUser user, int rank) {
    final isMe = user.id == _currentUser?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.1) : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: AppColors.primary) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: Text(
            '#$rank',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        title: Text(
          isMe ? '${user.name} (You)' : user.name,
          style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(_calculateLevel(user)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(user.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(
                  '${user.favors} Favors',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Gamification
  String _calculateLevel(AppUser user) {
    if (user.favors > 50) return '🧙‍♂️ Grand Archivist';
    if (user.favors > 20) return '🗝️ Keeper of Books';
    if (user.favors > 10) return '📚 Avid Reader';
    if (user.favors > 5)  return '📖 Bookworm';
    return '🌱 Novice';
  }
}