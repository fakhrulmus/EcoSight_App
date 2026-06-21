import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Activity {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final IconData icon;
  final String description;
  final int impactPoints;

  Activity({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.icon,
    required this.description,
    this.impactPoints = 25,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      icon: _categoryToIcon(data['category'] ?? 'general'),
      description: data['description'] ?? '',
      impactPoints: (data['impactPoints'] as int?) ?? 25,
    );
  }

  static IconData _categoryToIcon(String category) {
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

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final String userRole;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    this.userRole = 'student',
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool _isJoined = false;
  bool _isCheckingJoin = true;
  bool _isJoining = false;
  int _participantCount = 0;

  @override
  void initState() {
    super.initState();
    _loadParticipantData();
  }

  Future<void> _loadParticipantData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isCheckingJoin = false);
      return;
    }

    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('events')
            .doc(widget.activity.id)
            .collection('participants')
            .doc(user.uid)
            .get(),
        FirebaseFirestore.instance
            .collection('events')
            .doc(widget.activity.id)
            .get(),
      ]);

      final participantDoc = results[0];
      final eventDoc = results[1];
      final eventData = eventDoc.data();

      if (mounted) {
        setState(() {
          _isJoined = participantDoc.exists;
          _participantCount = (eventData?['participantCount'] as int?) ?? 0;
          _isCheckingJoin = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCheckingJoin = false);
      }
    }
  }

  Future<void> _handleJoin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join activities.')),
      );
      return;
    }

    setState(() => _isJoining = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Record in event subcollection (for admin participant tracking)
      final participantRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.activity.id)
          .collection('participants')
          .doc(user.uid);

      batch.set(participantRef, {
        'userId': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'impactPoints': widget.activity.impactPoints,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Record in flat participation collection (for student history view)
      final participationRef =
          FirebaseFirestore.instance.collection('participation').doc();
      batch.set(participationRef, {
        'userId': user.uid,
        'activityId': widget.activity.id,
        'activityName': widget.activity.title,
        'activityDate': widget.activity.date,
        'activityTime': widget.activity.time,
        'activityLocation': widget.activity.location,
        'joinDate': FieldValue.serverTimestamp(),
        'status': 'Joined',
      });

      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.activity.id);

      batch.update(eventRef, {
        'participantCount': FieldValue.increment(1),
      });

      // Update user's impact score and activity count
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      batch.update(userRef, {
        'impactScore': FieldValue.increment(widget.activity.impactPoints),
        'activitiesJoined': FieldValue.increment(1),
      });

      await batch.commit();

      if (mounted) {
        setState(() {
          _isJoined = true;
          _participantCount++;
          _isJoining = false;
        });

        // Simulating visual feedback delay before popping back, if applicable
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate joined
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${widget.activity.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.activity.id)
          .delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            decoration: const BoxDecoration(color: Color(0xFF16A34A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    if (widget.userRole == 'admin')
                      GestureDetector(
                        onTap: _handleDelete,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.activity.icon,
                        color: const Color(0xFF16A34A),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.activity.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Impact points badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.star,
                                size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.activity.impactPoints} eco points',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ABOUT THIS ACTIVITY',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.activity.description,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          LucideIcons.calendar,
                          widget.activity.date,
                          widget.activity.time,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          LucideIcons.mapPin,
                          widget.activity.location.isNotEmpty
                              ? widget.activity.location
                              : 'Location TBD',
                          'Meet at the main entrance',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          LucideIcons.users,
                          _isCheckingJoin
                              ? 'Loading...'
                              : '$_participantCount student${_participantCount == 1 ? '' : 's'} joined',
                          'Be one of the changemakers',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildActionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isCheckingJoin) {
      return const SizedBox(
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A)),
        ),
      );
    }

    // Admins manage events, not join them
    if (widget.userRole == 'admin') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.shieldCheck, color: Color(0xFF16A34A), size: 20),
            SizedBox(width: 8),
            Text(
              'Admin View — Use trash icon to delete',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_isJoined) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF16A34A), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Successfully Joined!',
              style: TextStyle(
                color: Color(0xFF064E3B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${widget.activity.impactPoints} eco points added to your score!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF15803D), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isJoining ? null : _handleJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF16A34A).withOpacity(0.4),
        ),
        child: _isJoining
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Join Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF16A34A), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
