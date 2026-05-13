import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'activity_detail_screen.dart';
import 'create_event_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _userRole = 'student';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _seedIfEmpty();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _userRole = (doc.data()?['role'] ?? 'student') as String;
        });
      }
    } catch (_) {}
  }

  Future<void> _seedIfEmpty() async {
    try {
      // Check if already seeded by looking for the first seed document
      final check = await FirebaseFirestore.instance
          .collection('events')
          .doc('seed_beach_cleanup')
          .get();
      if (check.exists) return;

      final col = FirebaseFirestore.instance.collection('events');
      final batch = FirebaseFirestore.instance.batch();

      final seeds = [
        {
          'id': 'seed_beach_cleanup',
          'title': 'Beach Cleanup',
          'description':
              'Join us for a morning of coastal conservation! Help remove plastic waste and debris from Teluk Kemang Beach while learning about marine ecosystem protection.',
          'location': 'Teluk Kemang Beach',
          'date': 'Sat, May 23',
          'time': '8:00 AM - 12:00 PM',
          'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 23, 8, 0)),
          'category': 'general',
          'participantCount': 0,
          'createdBy': 'system',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'seed_tree_planting',
          'title': 'Tree Planting',
          'description':
              'Be part of our reforestation initiative. Plant native tree species in the UTM Forest Reserve and contribute to carbon sequestration efforts.',
          'location': 'UTM Forest Reserve',
          'date': 'Sun, May 24',
          'time': '9:00 AM - 11:00 AM',
          'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 24, 9, 0)),
          'category': 'tree',
          'participantCount': 0,
          'createdBy': 'system',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'seed_campus_green_day',
          'title': 'Campus Green Day',
          'description':
              'A day dedicated to sustainability awareness with workshops, exhibitions, and eco-friendly activities across campus.',
          'location': 'Campus Main Hall',
          'date': 'Tue, May 26',
          'time': '10:00 AM - 4:00 PM',
          'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 26, 10, 0)),
          'category': 'general',
          'participantCount': 0,
          'createdBy': 'system',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'seed_community_garden',
          'title': 'Community Garden',
          'description':
              'Get your hands dirty! Help establish an organic community garden where students can grow vegetables and herbs sustainably.',
          'location': 'Campus Green Zone',
          'date': 'Wed, May 27',
          'time': '4:00 PM - 6:00 PM',
          'dateTimestamp': Timestamp.fromDate(DateTime(2026, 5, 27, 16, 0)),
          'category': 'garden',
          'participantCount': 0,
          'createdBy': 'system',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final seed in seeds) {
        final id = seed['id'] as String;
        final data = Map<String, dynamic>.from(seed)..remove('id');
        batch.set(col.doc(id), data);
      }

      await batch.commit();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                );
              },
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Upcoming',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  Text(
                    'Eco Activities',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('dateTimestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.calendarOff,
                              size: 48,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No events yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Check back soon!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final activities =
                      docs.map((doc) => Activity.fromFirestore(doc)).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityDetailScreen(
                                activity: activity,
                                userRole: _userRole,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    activity.icon,
                                    color: const Color(0xFF10B981),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.calendar,
                                              size: 14, color: Color(0xFF6B7280)),
                                          const SizedBox(width: 4),
                                          Text(
                                            activity.date,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (activity.location.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.mapPin,
                                                size: 14, color: Color(0xFF6B7280)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                activity.location,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  color: Color(0xFFD1D5DB),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
