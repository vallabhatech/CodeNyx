import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';

class ManageAnnouncementsScreen extends ConsumerStatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  ConsumerState<ManageAnnouncementsScreen> createState() =>
      _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState
    extends ConsumerState<ManageAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showSnackBar('Please enter both title and message.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final createAnnouncement = ref.read(createAnnouncementProvider);
      await createAnnouncement(title, message);

      _titleController.clear();
      _messageController.clear();

      if (!mounted) return;
      _showSnackBar('Announcement created successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to create announcement: $e', isError: true);
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
    final announcementsAsync = ref.watch(announcementsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Manage Announcements', style: AppTheme.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            children: [
              _buildComposerCard(),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  const Text('Recent Announcements', style: AppTheme.cardTitle),
                  const Spacer(),
                  IconButton(
                    onPressed: () => ref.invalidate(announcementsListProvider),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              announcementsAsync.when(
                data: (announcements) {
                  if (announcements.isEmpty) {
                    return _buildEmptyState(
                      'No announcements yet. Create the first one above.',
                    );
                  }

                  return Column(
                    children: announcements
                        .map((announcement) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.spacingM,
                              ),
                              child: _AnnouncementCard(announcement: announcement),
                            ))
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
                    _buildEmptyState('Failed to load announcements.\n$error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposerCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Announcement', style: AppTheme.cardTitle),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Broadcast important updates to all participants.',
            style: AppTheme.cardBody,
          ),
          const SizedBox(height: AppTheme.spacingL),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDecoration('Title'),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDecoration('Message'),
          ),
          const SizedBox(height: AppTheme.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAnnouncement,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Publish Announcement'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Text(message, style: AppTheme.cardBody),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
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
        borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 1.4),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Map<String, dynamic> announcement;

  @override
  Widget build(BuildContext context) {
    final title = (announcement['title'] ?? 'Untitled').toString();
    final message = (announcement['message'] ?? '').toString();
    final createdAt = (announcement['created_at'] ?? '').toString();

    return Container(
      width: double.infinity,
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
                  color: AppTheme.accentPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: AppTheme.accentPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(child: Text(title, style: AppTheme.cardTitle)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(message, style: AppTheme.cardBody),
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text('Created: $createdAt', style: AppTheme.metaText),
          ],
        ],
      ),
    );
  }
}
