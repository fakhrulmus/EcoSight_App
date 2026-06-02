import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipationHistoryScreen extends StatefulWidget {
  const ParticipationHistoryScreen({super.key});

  @override
  State<ParticipationHistoryScreen> createState() => _ParticipationHistoryScreenState();
}

class _ParticipationHistoryScreenState extends State<ParticipationHistoryScreen> {
  final Color primaryGreen = const Color(0xFF00B14F);
  final Color darkText = const Color(0xFF1F2937);
  final Color greyText = const Color(0xFF6B7280);

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  String _formatJoinDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Joined on Jun 2, 2026';
    final date = timestamp.toDate();
    final months = [
      'Jun', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Joined on ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _getActivityIcon(String activityName) {
    final name = activityName.toLowerCase();
    if (name.contains('beach') || name.contains('clean') || name.contains('trash')) {
      return LucideIcons.recycle; // Matches the recycling arrows icon in the Beach Cleanup screenshot!
    } else if (name.contains('tree') || name.contains('plant') || name.contains('forest')) {
      return LucideIcons.sprout;
    } else if (name.contains('garden') || name.contains('farm') || name.contains('green')) {
      return LucideIcons.leaf;
    }
    return LucideIcons.award;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches white background in the screenshot
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _currentUser == null
                ? _buildNotLoggedInState()
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('participation')
                        .where('userId', isEqualTo: _currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B14F),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading history: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        );
                      }

                      final docs = snapshot.hasData ? List<QueryDocumentSnapshot>.from(snapshot.data!.docs) : [];
                      
                      // Sort documents in Dart by joinDate descending
                      docs.sort((a, b) {
                        final aTime = a['joinDate'] as Timestamp?;
                        final bTime = b['joinDate'] as Timestamp?;
                        if (aTime == null && bTime == null) return 0;
                        if (aTime == null) return 1;
                        if (bTime == null) return -1;
                        return bTime.compareTo(aTime);
                      });

                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Activities Row
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: RichText(
                              text: TextSpan(
                                text: 'Total Activities: ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF374151),
                                  fontFamily: 'Roboto',
                                ),
                                children: [
                                  TextSpan(
                                    text: '${docs.length}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Participation History List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                
                                final title = data['activityName'] ?? 'Eco Activity';
                                final date = data['activityDate'] ?? '';
                                final time = data['activityTime'] ?? '9:00 AM';
                                final location = data['activityLocation'] ?? '';
                                final joinDate = data['joinDate'] as Timestamp?;
                                
                                // Format combined date-time
                                final dateTimeStr = time.isNotEmpty ? '$date · $time' : date;

                                return _buildParticipationCard(
                                  title: title,
                                  dateTimeStr: dateTimeStr,
                                  location: location,
                                  joinDate: joinDate,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      decoration: BoxDecoration(
        color: primaryGreen, // Solid green background exactly like screenshot
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Participation History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32, // Large title text
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "All activities you've joined",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationCard({
    required String title,
    required String dateTimeStr,
    required String location,
    required Timestamp? joinDate,
  }) {
    // Styling tags precisely like the screenshot's upcoming tag
    const badgeColor = Color(0xFF2563EB); // Elegant blue text
    const badgeBg = Color(0xFFEFF6FF); // Light blue background

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Matches round border in screenshot
        border: Border.all(color: const Color(0xFFE5E7EB)), // Subtle outline border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left circular icon container
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8F0), // Soft green background
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(title),
                color: primaryGreen, // Dark green icon
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle text contents
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: darkText,
                            fontSize: 20, // Large bold title
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Styled "Upcoming" status tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Upcoming',
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 16, color: greyText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateTimeStr,
                          style: TextStyle(
                            color: greyText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: greyText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: greyText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Joined Date
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 16, color: greyText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatJoinDate(joinDate),
                          style: TextStyle(
                            color: greyText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.sprout,
              color: primaryGreen,
              size: 72,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Your green journey starts here!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You haven't joined any eco-activities yet. Explore upcoming events, participate, and start building your green impact tracker!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: greyText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, color: greyText, size: 64),
            const SizedBox(height: 16),
            Text(
              "Access Denied",
              style: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Please log in to view your participation history.",
              style: TextStyle(color: greyText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
