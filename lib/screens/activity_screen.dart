import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'activity_detail_screen.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final List<Activity> _activities = [
    Activity(
      id: 1,
      title: 'Beach Cleanup',
      date: 'Sat, May 24',
      time: '8:00 AM - 12:00 PM',
      location: 'Teluk Kemang Beach',
      icon: LucideIcons.leaf,
      description: 'Join us for a morning of coastal conservation! Help remove plastic waste and debris from Teluk Kemang Beach while learning about marine ecosystem protection.',
    ),
    Activity(
      id: 2,
      title: 'Tree Planting',
      date: 'Sun, May 25',
      time: '9:00 AM - 11:00 AM',
      location: 'UTM Forest Reserve',
      icon: LucideIcons.sprout,
      description: 'Be part of our reforestation initiative. Plant native tree species in the UTM Forest Reserve and contribute to carbon sequestration efforts.',
    ),
    Activity(
      id: 3,
      title: 'Community Garden',
      date: 'Wed, May 28',
      time: '4:00 PM - 6:00 PM',
      location: 'Campus Green Zone',
      icon: LucideIcons.recycle,
      description: 'Get your hands dirty! Help establish an organic community garden where students can grow vegetables and herbs sustainably.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailScreen(activity: activity),
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
                                      const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF6B7280)),
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
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.mapPin, size: 14, color: Color(0xFF6B7280)),
                                      const SizedBox(width: 4),
                                      Text(
                                        activity.location,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

