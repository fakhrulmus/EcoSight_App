import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryGreen = const Color(0xFF00B14F);
  final Color darkText = const Color(0xFF0F172A);
  final Color greyText = const Color(0xFF64748B);

  User? user;
  String name = "Student";
  String email = "";
  String phone = "";
  String role = "student";
  int impactScore = 0;
  int activitiesJoined = 0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();

      setState(() {
        name = data?['name'] ?? user!.displayName ?? "Student";
        email = data?['email'] ?? user!.email ?? "";
        phone = data?['phone'] ?? "Not added";
        role = (data?['role'] ?? 'student') as String;
        impactScore = (data?['impactScore'] as int?) ?? 0;
        activitiesJoined = (data?['activitiesJoined'] as int?) ?? 0;
      });
    } catch (e) {
      setState(() {
        email = user?.email ?? "";
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    _buildUserInfoCard(),
                    const SizedBox(height: 20),
                    if (role == 'student') ...[
                      _buildImpactCards(),
                      const SizedBox(height: 20),
                      _buildEnvironmentalImpact(),
                      const SizedBox(height: 20),
                      _buildMonthlyActivity(),
                      const SizedBox(height: 20),
                      _buildAchievements(),
                      const SizedBox(height: 20),
                    ],
                    _buildLogoutButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 35, 28, 45),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role == 'admin' ? "My Account" : "Your Impact",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role == 'admin'
                ? "Administrator"
                : "Every action counts towards a better future",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_outline,
                  color: primaryGreen,
                  size: 46,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Column(
      children: [
        _infoTile(
          icon: Icons.email_outlined,
          label: "Email",
          value: email.isEmpty ? "Not available" : email,
        ),
        const SizedBox(height: 14),
        _infoTile(
          icon: Icons.phone_outlined,
          label: "Phone",
          value: phone,
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryGreen, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: greyText,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.eco_outlined,
            title: "Activities",
            value: "$activitiesJoined",
            subtitle: "Total joined",
            color: primaryGreen,
            bgColor: const Color(0xFFEAF8F0),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.stars_outlined,
            title: "Eco Points",
            value: "$impactScore",
            subtitle: "Impact score",
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: darkText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: darkText,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: greyText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Environmental Impact",
            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your contributions to sustainability",
            style: TextStyle(color: greyText, fontSize: 15),
          ),
          const SizedBox(height: 22),
          _impactBar(
            "CO₂ Offset",
            "${(impactScore * 0.4).round()} kg",
            (impactScore / 250).clamp(0.0, 1.0),
            primaryGreen,
          ),
          const SizedBox(height: 18),
          _impactBar(
            "Waste Collected",
            "${(impactScore * 0.2).round()} kg",
            (impactScore / 250).clamp(0.0, 1.0),
            const Color(0xFF2563EB),
          ),
          const SizedBox(height: 18),
          _impactBar(
            "Trees Planted",
            "${(impactScore / 50).floor()}",
            (impactScore / 500).clamp(0.0, 1.0),
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _impactBar(String label, String value, double percent, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: darkText, fontSize: 16),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 9,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyActivity() {
    final months = ["Jan", "Feb", "Mar", "Apr"];
    final values = [8.0, 12.0, 16.0, 6.0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Activity",
            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Volunteer hours over time",
            style: TextStyle(color: greyText, fontSize: 15),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 48,
                        height: values[index] * 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        months[index],
                        style: TextStyle(color: greyText),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      {
        'icon': Icons.eco_outlined,
        'title': 'First Step',
        'subtitle': 'Join your first activity',
        'unlocked': activitiesJoined >= 1,
        'requirement': 1,
      },
      {
        'icon': Icons.local_florist_outlined,
        'title': 'Eco Enthusiast',
        'subtitle': 'Reach 50 eco points',
        'unlocked': impactScore >= 50,
        'requirement': 50,
      },
      {
        'icon': Icons.military_tech_outlined,
        'title': 'Eco Warrior',
        'subtitle': 'Reach 150 eco points',
        'unlocked': impactScore >= 150,
        'requirement': 150,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'title': 'Green Champion',
        'subtitle': 'Reach 300 eco points',
        'unlocked': impactScore >= 300,
        'requirement': 300,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Achievements",
            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Badges earned through participation",
            style: TextStyle(color: greyText, fontSize: 15),
          ),
          const SizedBox(height: 20),
          ...badges.asMap().entries.map((entry) {
            final i = entry.key;
            final badge = entry.value;
            final unlocked = badge['unlocked'] as bool;
            return Padding(
              padding: EdgeInsets.only(bottom: i < badges.length - 1 ? 14 : 0),
              child: _achievementTile(
                icon: badge['icon'] as IconData,
                title: badge['title'] as String,
                subtitle: badge['subtitle'] as String,
                unlocked: unlocked,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _achievementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: unlocked
              ? const Color(0xFFFEF3C7)
              : const Color(0xFFF1F5F9),
          child: Icon(
            icon,
            color: unlocked
                ? const Color(0xFFF59E0B)
                : const Color(0xFFCBD5E1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: unlocked ? darkText : const Color(0xFF94A3B8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: unlocked ? greyText : const Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Icon(
          unlocked
              ? Icons.workspace_premium_outlined
              : Icons.lock_outline,
          color: unlocked
              ? const Color(0xFFF59E0B)
              : const Color(0xFFCBD5E1),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text(
          "Log Out",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE85D5D),
          side: const BorderSide(color: Color(0xFFE85D5D), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}