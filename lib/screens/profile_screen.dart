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
                    _buildImpactCards(),
                    const SizedBox(height: 20),
                    _buildEnvironmentalImpact(),
                    const SizedBox(height: 20),
                    _buildMonthlyActivity(),
                    const SizedBox(height: 20),
                    _buildAchievements(),
                    const SizedBox(height: 22),
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
          const Text(
            "Your Impact",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Every action counts towards a better future",
            style: TextStyle(
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('participation')
                .where('userId', isEqualTo: user?.uid ?? '')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _statCard(
                icon: Icons.eco_outlined,
                title: "Activities",
                value: count.toString(),
                subtitle: "Total joined",
                color: primaryGreen,
                bgColor: const Color(0xFFEAF8F0),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.access_time,
            title: "Hours",
            value: "41",
            subtitle: "Volunteer time",
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
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
          _impactBar("CO₂ Offset", "85 kg", 0.85, primaryGreen),
          const SizedBox(height: 18),
          _impactBar("Waste Collected", "32 kg", 0.65, const Color(0xFF2563EB)),
          const SizedBox(height: 18),
          _impactBar("Trees Planted", "18", 0.45, const Color(0xFF10B981)),
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
          _achievementTile(
            icon: Icons.eco_outlined,
            title: "Eco Warrior",
            subtitle: "Joined 10+ activities",
          ),
          const SizedBox(height: 14),
          _achievementTile(
            icon: Icons.groups_outlined,
            title: "Team Player",
            subtitle: "Active participant",
          ),
        ],
      ),
    );
  }

  Widget _achievementTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: const Color(0xFFFEF3C7),
          child: Icon(icon, color: const Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: greyText, fontSize: 14),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.workspace_premium_outlined,
          color: Color(0xFFF59E0B),
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