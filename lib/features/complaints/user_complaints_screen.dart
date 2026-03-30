import 'package:codenyx/core/theme/app_theme.dart';
import 'package:codenyx/services/session_service.dart';
import 'package:flutter/material.dart';
import 'complaints_repository.dart';

class UserComplaintsScreen extends StatefulWidget {
  const UserComplaintsScreen({super.key});

  @override
  State<UserComplaintsScreen> createState() => _UserComplaintsScreenState();
}

class _UserComplaintsScreenState extends State<UserComplaintsScreen> {
  final _messageController = TextEditingController();
  final _repository = const ComplaintsRepository();

  String _teamId = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    try {
      final session = await SessionService.getSession();
      final teamId = (session['teamId'] ?? '').toString();
      final complaints = teamId.isEmpty
          ? <Map<String, dynamic>>[]
          : await _repository.getUserComplaints(teamId);

      if (!mounted) return;

      setState(() {
        _teamId = teamId;
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showSnackBar('Failed to load complaints: $e', isError: true);
    }
  }

  Future<void> _submitComplaint() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSnackBar('Please enter your complaint message.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.createComplaint(message);
      _messageController.clear();
      await _loadComplaints();

      if (!mounted) return;
      _showSnackBar('Complaint submitted successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to submit complaint: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.surfaceLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPrimary),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingL,
          AppTheme.spacingM,
          AppTheme.spacingL,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Raise a Complaint', style: AppTheme.cardTitle),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Let organizers know about issues affecting your team.',
                    style: AppTheme.cardBody,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      hintStyle: const TextStyle(color: AppTheme.textTertiary),
                      filled: true,
                      fillColor: AppTheme.surfaceLight.withValues(alpha: 0.75),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: const BorderSide(
                          color: AppTheme.accentPrimary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Submit Complaint'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const Text('YOUR COMPLAINTS', style: AppTheme.sectionHeader),
            const SizedBox(height: AppTheme.spacingM),
            if (_teamId.isEmpty)
              _buildEmptyCard('No team session found for complaints.')
            else if (_complaints.isEmpty)
              _buildEmptyCard('No complaints submitted yet.')
            else
              ..._complaints.map(
                (complaint) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _ComplaintCard(complaint: complaint),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Text(message, style: AppTheme.cardBody),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint});

  final Map<String, dynamic> complaint;

  @override
  Widget build(BuildContext context) {
    final message = (complaint['message'] ?? '').toString();
    final status = (complaint['status'] ?? 'pending').toString();
    final createdAt = (complaint['created_at'] ?? '').toString();
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(message, style: AppTheme.cardBody)),
              const SizedBox(width: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _capitalize(status),
                  style: AppTheme.metaText.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text('Created: $createdAt', style: AppTheme.metaText),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    return status == 'resolved' ? Colors.green : Colors.amber;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
