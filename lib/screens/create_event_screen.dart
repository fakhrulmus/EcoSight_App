import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCategory = 'general';
  bool _isLoading = false;

  static const _green = Color(0xFF10B981);

  static const _categoryOptions = [
    {'value': 'general', 'label': 'General Activity', 'points': 30},
    {'value': 'tree', 'label': 'Tree Planting', 'points': 50},
    {'value': 'garden', 'label': 'Community Garden', 'points': 40},
  ];

  int get _impactPoints =>
      (_categoryOptions.firstWhere((c) => c['value'] == _selectedCategory)['points'] as int);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${dayNames[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _green),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _green),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _green),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _saveEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnack('Please enter an event title');
      return;
    }
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_startTime == null) {
      _showSnack('Please select a start time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final timeStr = _endTime != null
          ? '${_startTime!.format(context)} - ${_endTime!.format(context)}'
          : _startTime!.format(context);

      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'date': _formatDate(_selectedDate!),
        'time': timeStr,
        'dateTimestamp': Timestamp.fromDate(DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        )),
        'category': _selectedCategory,
        'impactPoints': _impactPoints,
        'createdBy': user?.uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: _green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to create event: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(children: [
              _buildTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'e.g. Beach Cleanup Drive',
                icon: LucideIcons.calendar,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the event...',
                icon: LucideIcons.fileText,
                maxLines: 4,
              ),
            ]),
            const SizedBox(height: 16),
            _buildCard(children: [
              _buildPickerRow(
                label: 'Date',
                icon: LucideIcons.calendar,
                value: _selectedDate != null ? _formatDate(_selectedDate!) : 'Select date',
                onTap: _pickDate,
                hasValue: _selectedDate != null,
              ),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildPickerRow(
                label: 'Start Time',
                icon: LucideIcons.clock,
                value: _startTime != null ? _startTime!.format(context) : 'Select time',
                onTap: _pickStartTime,
                hasValue: _startTime != null,
              ),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildPickerRow(
                label: 'End Time',
                icon: LucideIcons.clock,
                value: _endTime != null ? _endTime!.format(context) : 'Optional',
                onTap: _pickEndTime,
                hasValue: _endTime != null,
              ),
            ]),
            const SizedBox(height: 16),
            _buildCard(children: [
              Text(
                'Category & Impact',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              ...(_categoryOptions.map((cat) {
                final isSelected = _selectedCategory == cat['value'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['value'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _green.withOpacity(0.08)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _green : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _green
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${cat['points']} pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })),
            ]),
            const SizedBox(height: 16),
            _buildCard(children: [
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g. Teluk Kemang Beach',
                icon: LucideIcons.mapPin,
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Event',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF1F2937), fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerRow({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required bool hasValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _green, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: hasValue ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(LucideIcons.chevronRight, color: Color(0xFFD1D5DB), size: 20),
        ],
      ),
    );
  }
}
