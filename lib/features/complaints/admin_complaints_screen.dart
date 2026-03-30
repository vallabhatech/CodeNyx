import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'complaints_repository.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final _repository = const ComplaintsRepository();

  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final complaints = await _repository.getAllComplaints();

      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showSnackBar('Failed to load complaints: $e', isError: true);
    }
  }

  Future<void> _resolveComplaint(dynamic id) async {
    try {
      await _repository.updateComplaintStatus(id);
      await _loadComplaints();

      if (!mounted) return;
      _showSnackBar('Complaint marked as resolved.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to resolve complaint: $e', isError: true);
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
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Complaints', style: AppTheme.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentPrimary,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                children: _complaints.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          decoration: AppTheme.cardDecoration(
                            borderRadius: AppTheme.radiusLarge,
                          ),
                          child: const Text(
                            'No complaints found.',
                            style: AppTheme.cardBody,
                          ),
                        ),
                      ]
                    : _complaints
                        .map(
                          (complaint) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacingM,
                            ),
                            child: _AdminComplaintCard(
                              complaint: complaint,
                              onResolve: () => _resolveComplaint(complaint['id']),
                            ),
                          ),
                        )
                        .toList(),
              ),
      ),
    );
  }
}

class _AdminComplaintCard extends StatelessWidget {
  const _AdminComplaintCard({
    required this.complaint,
    required this.onResolve,
  });

  final Map<String, dynamic> complaint;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final userEmail = (complaint['user_email'] ?? 'Unknown').toString();
    final teamId = (complaint['team_id'] ?? 'Unknown').toString();
    final message = (complaint['message'] ?? '').toString();
    final status = (complaint['status'] ?? 'pending').toString();
    final isResolved = status == 'resolved';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userEmail, style: AppTheme.cardTitle),
          const SizedBox(height: AppTheme.spacingXS),
          Text('Team: $teamId', style: AppTheme.metaText),
          const SizedBox(height: AppTheme.spacingM),
          Text(message, style: AppTheme.cardBody),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: (isResolved ? Colors.green : Colors.amber).withValues(
                    alpha: 0.16,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isResolved ? 'Resolved' : 'Pending',
                  style: AppTheme.metaText.copyWith(
                    color: isResolved ? Colors.green : Colors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isResolved ? null : onResolve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: const Text('Resolve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
