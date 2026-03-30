import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';

class ManageMentorRequestsScreen extends ConsumerStatefulWidget {
  const ManageMentorRequestsScreen({super.key});

  @override
  ConsumerState<ManageMentorRequestsScreen> createState() =>
      _ManageMentorRequestsScreenState();
}

class _ManageMentorRequestsScreenState
    extends ConsumerState<ManageMentorRequestsScreen> {
  String _selectedStatus = 'all';

  Future<void> _updateStatus(dynamic id, String status) async {
    try {
      final updateStatus = ref.read(updateMentorRequestStatusProvider);
      await updateStatus(id, status);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $status'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.surfaceLight,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update request: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorRequestsAsync = ref.watch(mentorRequestsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Mentor Requests', style: AppTheme.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            children: [
              const Text('Filter by status', style: AppTheme.cardTitle),
              const SizedBox(height: AppTheme.spacingM),
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: ['all', 'pending', 'accepted', 'resolved']
                    .map(
                      (status) => ChoiceChip(
                        label: Text(_labelForStatus(status)),
                        selected: _selectedStatus == status,
                        onSelected: (_) {
                          setState(() => _selectedStatus = status);
                        },
                        selectedColor: AppTheme.accentPrimary,
                        backgroundColor: AppTheme.surfaceLight,
                        labelStyle: TextStyle(
                          color: _selectedStatus == status
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppTheme.spacingL),
              mentorRequestsAsync.when(
                data: (requests) {
                  final filteredRequests = _selectedStatus == 'all'
                      ? requests
                      : requests
                          .where(
                            (request) =>
                                (request['status'] ?? '').toString() ==
                                _selectedStatus,
                          )
                          .toList();

                  if (filteredRequests.isEmpty) {
                    return _buildEmptyState(
                      'No mentor requests found for this filter.',
                    );
                  }

                  return Column(
                    children: filteredRequests
                        .map(
                          (request) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacingM,
                            ),
                            child: _MentorRequestCard(
                              request: request,
                              onUpdateStatus: _updateStatus,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXL),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentPrimary,
                      ),
                    ),
                  ),
                ),
                error: (error, _) =>
                    _buildEmptyState('Failed to load mentor requests.\n$error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelForStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'resolved':
        return 'Resolved';
      default:
        return 'All';
    }
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Text(message, style: AppTheme.cardBody),
    );
  }
}

class _MentorRequestCard extends StatelessWidget {
  const _MentorRequestCard({
    required this.request,
    required this.onUpdateStatus,
  });

  final Map<String, dynamic> request;
  final Future<void> Function(dynamic id, String status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final requestId = request['id'];
    final teamName = (request['team_name'] ?? request['team_id'] ?? 'Unknown team')
        .toString();
    final category = (request['category'] ?? 'General').toString();
    final description = (request['description'] ?? '').toString();
    final status = (request['status'] ?? 'pending').toString();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.support_agent_outlined,
                  color: _statusColor(status),
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(child: Text(teamName, style: AppTheme.cardTitle)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text('Category: $category', style: AppTheme.metaText),
          const SizedBox(height: AppTheme.spacingM),
          Text(description, style: AppTheme.cardBody),
          const SizedBox(height: AppTheme.spacingL),
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: ['pending', 'accepted', 'resolved']
                .map(
                  (nextStatus) => OutlinedButton(
                    onPressed: status == nextStatus
                        ? null
                        : () => onUpdateStatus(requestId, nextStatus),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _statusColor(nextStatus),
                      side: BorderSide(color: _statusColor(nextStatus)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text(_capitalize(nextStatus)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppTheme.accentSecondary;
      case 'resolved':
        return AppTheme.colorBlue;
      default:
        return AppTheme.accentPrimary;
    }
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
