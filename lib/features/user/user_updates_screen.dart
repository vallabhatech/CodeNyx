import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserUpdatesScreen extends StatefulWidget {
  const UserUpdatesScreen({super.key});

  @override
  State<UserUpdatesScreen> createState() => _UserUpdatesScreenState();
}

class _UserUpdatesScreenState extends State<UserUpdatesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final response = await Supabase.instance.client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _announcements = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load announcements: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load announcements: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppTheme.spacingL, AppTheme.spacingL, AppTheme.spacingL, AppTheme.spacingM),
            child: Text('LATEST ANNOUNCEMENTS', style: AppTheme.sectionHeader),
          ),
          Expanded(
            child: _announcements.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    child: _buildEmptyCard('No announcements available right now.'),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAnnouncements,
                    color: AppTheme.accentPrimary,
                    backgroundColor: AppTheme.surfaceLight,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingL,
                        0,
                        AppTheme.spacingL,
                        120, // Padding for floating nav bar
                      ),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: _announcements.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingM),
                      itemBuilder: (context, index) {
                        return _AnnouncementCard(announcement: _announcements[index]);
                      },
                    ),
                  ),
          ),
        ],
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Map<String, dynamic> announcement;

  @override
  Widget build(BuildContext context) {
    final title = (announcement['title'] ?? 'Untitled').toString();
    final message = (announcement['message'] ?? '').toString();
    
    final createdAt = (announcement['created_at'] ?? '').toString();
    String formattedDate = '';
    
    if (createdAt.isNotEmpty) {
      DateTime? parsed = DateTime.tryParse(createdAt)?.toLocal();
      if (parsed != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge).copyWith(
        border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.15)),
        color: AppTheme.accentPrimary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: AppTheme.accentPrimary, size: 20),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(child: Text(title, style: AppTheme.cardTitle.copyWith(color: AppTheme.accentPrimary))),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(message, style: AppTheme.cardBody),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(formattedDate, style: AppTheme.metaText),
          ],
        ],
      ),
    );
  }
}
