import 'dart:async';
import 'package:codenyx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_repository.dart';
import '../complaints/admin_complaints_screen.dart';
import 'manage_announcements_screen.dart';
import 'manage_mentor_requests_screen.dart';
import '../../services/timer_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  Timer? _pulseTimer;

  // Always stored as UTC — only converted to local for display
  DateTime? _startTimeUtc;
  int _durationHours = 36;
  bool _isActive = false;
  bool _isLoading = true;
  bool _pulseOn = false;

  @override
  void initState() {
    super.initState();
    _fetchAndStartLocalTimer();
    _startPulse();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _startPulse() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _pulseOn = !_pulseOn);
    });
  }

  /// Single Supabase fetch — no extra calls anywhere else.
  Future<void> _fetchAndStartLocalTimer() async {
    if (mounted) setState(() => _isLoading = true);

    final data = await TimerService.getTimer();
    if (!mounted) return;

    if (data != null &&
        data['is_active'] == true &&
        data['start_time'] != null) {
      final raw = data['start_time'] as String;
      // Force UTC: Supabase sometimes omits the trailing 'Z'
      _startTimeUtc = DateTime.parse(raw.endsWith('Z') ? raw : '${raw}Z');
      _durationHours = (data['duration_hours'] as int?) ?? 36;
      _isActive = true;

      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _startTimeUtc = null;
      _isActive = false;
      _ticker?.cancel();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Derived values ─────────────────────────────────────────────────────────

  Duration get _remaining {
    if (_startTimeUtc == null) return Duration.zero;
    // Both sides in UTC — no timezone offset error
    final endUtc = _startTimeUtc!.add(Duration(hours: _durationHours));
    final rem = endUtc.difference(DateTime.now().toUtc());
    return rem.isNegative ? Duration.zero : rem;
  }

  bool get _isExpired =>
      _isActive && _startTimeUtc != null && _remaining == Duration.zero;

  // Local-time helpers for display only
  DateTime? get _startLocal => _startTimeUtc?.toLocal();
  DateTime? get _endLocal =>
      _startTimeUtc?.add(Duration(hours: _durationHours)).toLocal();

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _timerLabel {
    if (!_isActive) return '--:--:--';
    if (_isExpired) return '00:00:00';
    final r = _remaining;
    return '${_pad(r.inHours)}:${_pad(r.inMinutes.remainder(60))}:${_pad(r.inSeconds.remainder(60))}';
  }

  Color get _timerColor {
    if (!_isActive) return AppTheme.textTertiary;
    if (_isExpired) return Colors.red;
    if (_remaining.inHours < 3) return Colors.orange;
    return AppTheme.accentPrimary;
  }

  String get _statusLabel {
    if (_isLoading) return 'Fetching timer…';
    if (!_isActive) return 'Timer not started';
    if (_isExpired) return 'Hackathon ended';
    if (_remaining.inHours < 3) return 'Approaching deadline';
    return 'Timer running';
  }

  /// "Mar 29, 11:45 PM"
  String _formatDateTime(DateTime local) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = _pad(local.minute);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '${months[local.month - 1]} ${local.day}, $h:$m $ampm';
  }

  // ── Button handlers (each does exactly ONE Supabase call) ─────────────────

  Future<void> _handleStart() async {
    // Guard: if already running, don't hit Supabase at all
    if (_isActive && !_isExpired) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Timer is already running')));
      return;
    }
    await TimerService.startTimer(); // 1 Supabase call (update)
    await _fetchAndStartLocalTimer(); // 1 Supabase call (select)
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('36H Timer started!')));
  }

  Future<void> _handleReset() async {
    await TimerService.resetTimer(); // 1 Supabase call (update)
    await _fetchAndStartLocalTimer(); // 1 Supabase call (select)
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Timer has been reset')));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Admin Panel', style: AppTheme.cardTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingL),
            child: GestureDetector(
              onTap: () async {
                await AuthRepository.signOut();
                if (!context.mounted) return;
                context.go('/');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.accentCardDecoration(
                borderRadius: AppTheme.radiusLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ADMIN ACCESS', style: AppTheme.sectionHeader),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Manage core hackathon operations from one place.',
                    style: AppTheme.cardBody.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // ── TIMER CARD ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(
                borderRadius: AppTheme.radiusLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'HACKATHON TIMER',
                        style: AppTheme.sectionHeader,
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isActive && !_isExpired
                              ? AppTheme.accentPrimary.withValues(alpha: 0.15)
                              : _isExpired
                              ? Colors.red.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _isActive && !_isExpired
                                ? AppTheme.accentPrimary.withValues(alpha: 0.4)
                                : _isExpired
                                ? Colors.red.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isActive && !_isExpired
                                    ? (_pulseOn
                                          ? AppTheme.accentPrimary
                                          : AppTheme.accentPrimary.withValues(
                                              alpha: 0.3,
                                            ))
                                    : _isExpired
                                    ? Colors.red
                                    : AppTheme.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusLabel,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isActive && !_isExpired
                                    ? AppTheme.accentPrimary
                                    : _isExpired
                                    ? Colors.red
                                    : AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 64,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                _timerLabel,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 58,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                  color: _timerColor,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'HH   MM   SS',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  letterSpacing: 8,
                                  color: AppTheme.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),

                  if (_isActive && !_isLoading) ...[
                    const SizedBox(height: AppTheme.spacingL),
                    _TimerProgressBar(
                      remaining: _remaining,
                      total: Duration(hours: _durationHours),
                      color: _timerColor,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startLocal != null
                              ? 'Started ${_formatDateTime(_startLocal!)}'
                              : '',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          _endLocal != null
                              ? 'Ends ${_formatDateTime(_endLocal!)}'
                              : '',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacingL),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleStart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color: _isActive && !_isExpired
                                  ? AppTheme.accentPrimary.withValues(
                                      alpha: 0.25,
                                    )
                                  : AppTheme.accentPrimary,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              border: _isActive && !_isExpired
                                  ? Border.all(
                                      color: AppTheme.accentPrimary.withValues(
                                        alpha: 0.4,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isActive && !_isExpired
                                      ? Icons.play_circle_filled
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isActive && !_isExpired
                                      ? 'Running…'
                                      : 'Start 36H Timer',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleReset,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Reset Timer',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            _AdminActionTile(
              icon: Icons.campaign_outlined,
              title: 'Manage Announcements',
              subtitle: 'Create or update event-wide notices.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ManageAnnouncementsScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _AdminActionTile(
              icon: Icons.support_agent_outlined,
              title: 'View Mentor Requests',
              subtitle: 'Review incoming support and mentoring requests.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ManageMentorRequestsScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _AdminActionTile(
              icon: Icons.report_gmailerrorred_outlined,
              title: 'View Complaints',
              subtitle: 'Review and resolve participant complaints.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminComplaintsScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _TimerProgressBar extends StatelessWidget {
  const _TimerProgressBar({
    required this.remaining,
    required this.total,
    required this.color,
  });

  final Duration remaining;
  final Duration total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total.inSeconds > 0
        ? (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 6,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Admin action tile ─────────────────────────────────────────────────────────

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Ink(
          decoration: AppTheme.cardDecoration(
            borderRadius: AppTheme.radiusLarge,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: AppTheme.accentPrimary, size: 22),
                ),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.cardTitle),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(subtitle, style: AppTheme.cardBody),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
