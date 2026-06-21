import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalActivities = 0;
  int _totalParticipants = 0;
  List<Map<String, dynamic>> _eventStats = [];

  static const _green = Color(0xFF10B981);
  static const _darkGreen = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').count().get(),
        FirebaseFirestore.instance.collection('events').get(),
      ]);

      final userCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
      final eventsSnapshot = results[1] as QuerySnapshot;

      int totalParticipants = 0;
      final eventStats = <Map<String, dynamic>>[];

      for (final doc in eventsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final count = (data['participantCount'] as int?) ?? 0;
        totalParticipants += count;
        eventStats.add({
          'title': data['title'] ?? 'Untitled',
          'date': data['date'] ?? '',
          'participantCount': count,
          'impactPoints': (data['impactPoints'] as int?) ?? 0,
          'category': data['category'] ?? 'general',
        });
      }

      // Sort by participant count descending
      eventStats.sort((a, b) =>
          (b['participantCount'] as int).compareTo(a['participantCount'] as int));

      if (mounted) {
        setState(() {
          _totalUsers = userCount;
          _totalActivities = eventsSnapshot.docs.length;
          _totalParticipants = totalParticipants;
          _eventStats = eventStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: () async {
            setState(() => _isLoading = true);
            await _loadStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_green, _darkGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Overview of EcoSight activity',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: _green),
                    ),
                  )
                else ...[
                  const SizedBox(height: 24),

                  // Stat cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                icon: LucideIcons.users,
                                label: 'Total Users',
                                value: '$_totalUsers',
                                color: const Color(0xFF6366F1),
                                bg: const Color(0xFFEEF2FF),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _statCard(
                                icon: LucideIcons.calendar,
                                label: 'Total Activities',
                                value: '$_totalActivities',
                                color: _green,
                                bg: const Color(0xFFECFDF5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                icon: LucideIcons.userCheck,
                                label: 'Total Joins',
                                value: '$_totalParticipants',
                                color: const Color(0xFFF59E0B),
                                bg: const Color(0xFFFFFBEB),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _statCard(
                                icon: LucideIcons.trendingUp,
                                label: 'Avg per Event',
                                value: _totalActivities > 0
                                    ? (_totalParticipants / _totalActivities)
                                        .toStringAsFixed(1)
                                    : '0',
                                color: const Color(0xFFEC4899),
                                bg: const Color(0xFFFDF2F8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Participation by event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Participation by Event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Number of students joined per activity',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_eventStats.isEmpty)
                            const Center(
                              child: Text(
                                'No events yet',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            )
                          else
                            ..._eventStats.map((event) =>
                                _participationBar(event)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Event detail table
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activity Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._eventStats.asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            return Column(
                              children: [
                                if (i > 0)
                                  const Divider(
                                      height: 24, color: Color(0xFFF3F4F6)),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _categoryIcon(
                                            e['category'] as String),
                                        color: _green,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e['title'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          Text(
                                            e['date'] as String,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${e['participantCount']}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const Text(
                                          'joined',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _participationBar(Map<String, dynamic> event) {
    final count = event['participantCount'] as int;
    final maxCount = _eventStats.isEmpty
        ? 1
        : (_eventStats.first['participantCount'] as int);
    final ratio = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Text(
                '$count joined',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'tree':
        return LucideIcons.sprout;
      case 'garden':
        return LucideIcons.recycle;
      default:
        return LucideIcons.leaf;
    }
  }
}
