// dashboard_screen.dart

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/layout/web_wrapper.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import '../complaints/user_complaints_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/session_service.dart';
import '../social_feed/feed_screen.dart';
import '../user/user_updates_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../services/timer_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String teamId = "";
  String teamName = "";
  String projectName = "";
  String userEmail = "";
  List members = [];
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasUnreadUpdates = true;

  Timer? _timer;
  DateTime? _startTimeUtc; // always UTC — never converted until display
  int _durationHours = 36;
  bool _timerActive = false;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _loadTimerOnce();

    _pageController.addListener(() {
      setState(() {
        _selectedIndex = _pageController.page?.round() ?? 0;
        if (_selectedIndex == 2) {
          _hasUnreadUpdates = false;
        }
      });
    });

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final session = await SessionService.getSession();
      teamId = session['teamId'] ?? '';
      userEmail = session['email'] ?? '';

      if (teamId.isEmpty || userEmail.isEmpty) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null || user.email == null) {
          setState(() => _isLoading = false);
          return;
        }

        final rawEmail = user.email!;
        final normalizedEmail = AuthRepository.normalizeEmail(rawEmail);

        final foundTeamId = await AuthRepository.findUserTeam(normalizedEmail);
        if (foundTeamId == null) {
          setState(() => _isLoading = false);
          return;
        }

        teamId = foundTeamId;
        userEmail = normalizedEmail;
        await SessionService.saveSession(normalizedEmail, foundTeamId);
      }

      if (teamId.isNotEmpty) {
        final teamResponse = await SupabaseService.client
            .from('teams')
            .select()
            .eq('team_id', teamId)
            .maybeSingle();

        if (teamResponse != null) {
          teamName = teamResponse['team_name'] ?? '';
          projectName = teamResponse['project_name'] ?? '';
        }

        final membersResponse = await SupabaseService.client
            .from('team_members')
            .select()
            .eq('team_id', teamId)
            .order('name', ascending: true);

        setState(() {
          members = membersResponse;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimerOnce() async {
    final data = await TimerService.getTimer();

    if (data == null ||
        data['is_active'] != true ||
        data['start_time'] == null) {
      if (mounted) setState(() => _timerActive = false);
      return;
    }

    // Force UTC — Supabase sometimes omits the trailing 'Z'
    final raw = data['start_time'] as String;
    _startTimeUtc = DateTime.parse(raw.endsWith('Z') ? raw : '${raw}Z');
    _durationHours = (data['duration_hours'] as int?) ?? 36;

    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTimeUtc == null || !mounted) return;

      // Both sides UTC — no offset error
      final endUtc = _startTimeUtc!.add(Duration(hours: _durationHours));
      final diff = endUtc.difference(DateTime.now().toUtc());

      setState(() {
        if (diff.isNegative || diff == Duration.zero) {
          _timerActive = false;
        } else {
          _timerActive = true;
        }
      });
    });
  }

  Duration get _remaining {
    if (_startTimeUtc == null) return Duration.zero;
    final endUtc = _startTimeUtc!.add(Duration(hours: _durationHours));
    final diff = endUtc.difference(DateTime.now().toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }

  String formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h}h ${m}m ${s}s ';
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Text('Logout?', style: AppTheme.cardTitle),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.cardBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.cardTitle.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthRepository.signOut();
              if (!mounted) return;
              GoRouter.of(this.context).go('/');
            },
            child: Text(
              'Logout',
              style: AppTheme.cardTitle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
            ),
            Positioned(
              top: -80,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentPrimary.withOpacity(0.08),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentPrimary,
                  ),
                ),
              )
            else
              PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDashboardPage(),
                  WebWrapper(child: FeedScreen(teamId: teamId)),
                  const WebWrapper(child: UserUpdatesScreen()),
                  const WebWrapper(child: UserComplaintsScreen()),
                ],
              ),
            Positioned(
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: bottomInset + AppTheme.spacingM,
              child: _buildFloatingNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPage() {
    final memberCount = members.length;

    return SafeArea(
      child: WebWrapper(
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
              _buildHeaderWithLogout(),
              const SizedBox(height: AppTheme.spacingL),
              _buildQuickStats(memberCount),
              SizedBox(height: kIsWeb ? AppTheme.spacingXL : AppTheme.spacingL),
              _buildTimerBanner(),
              const SizedBox(height: AppTheme.spacingL),
              _buildChatBanner(),
              SizedBox(
                height: kIsWeb ? AppTheme.spacingXL * 1.5 : AppTheme.spacingXL,
              ),
              SizedBox(
                height: kIsWeb ? AppTheme.spacingXL * 1.5 : AppTheme.spacingXL,
              ),
              _buildTeamMembers(memberCount),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWithLogout() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset('assets/logo/gdg-logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text('codenyx', style: AppTheme.hackathonTitle),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.logout, color: Colors.red, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Logout',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(int memberCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Team ID',
            value: teamId.isEmpty ? '--' : teamId,
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildStatCard(
            title: 'Members',
            value: '$memberCount',
            icon: Icons.person_add_alt_1_rounded,
            highlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    bool highlighted = false,
  }) {
    final accentColor = highlighted
        ? AppTheme.accentPrimary
        : AppTheme.accentSecondary;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: highlighted
          ? AppTheme.accentCardDecoration(borderRadius: AppTheme.radiusLarge)
          : AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: AppTheme.spacingM),
          Text(title, style: AppTheme.metaText),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitle.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBanner() {
    final rem = _remaining;

    final isUrgent = rem.inHours <= 6 && _timerActive;

    String displayTime;
    bool showCountdown = true;

    if (!_timerActive && _startTimeUtc == null) {
      showCountdown = false;
      displayTime = "GET READY";
    } else if (!_timerActive || rem == Duration.zero) {
      displayTime = "00:00:00";
    } else {
      displayTime = formatTime(rem); // assumed HH:MM:SS
    }

    final timerColor = isUrgent ? Colors.red : AppTheme.accentPrimary;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(borderRadius: AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Text("HACKATHON TIMER", style: AppTheme.sectionHeader),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: timerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // MAIN CONTENT
          Center(
            child: showCountdown
                ? Column(
                    children: [
                      Text(
                        displayTime,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 36, // slightly reduced
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2, // tighter spacing
                          color: timerColor,
                          height: 1,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      Text(
                        "GET READY",
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Timer will start soon",
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // PROGRESS BAR (only when active)
          if (showCountdown)
            LayoutBuilder(
              builder: (context, constraints) {
                final total = const Duration(hours: 36);
                final progress = total.inSeconds > 0
                    ? (rem.inSeconds / total.inSeconds).clamp(0.0, 1.0)
                    : 0.0;

                return Stack(
                  children: [
                    Container(
                      height: 5,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 5,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: timerColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChatBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () => context.push('/chat'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingXL,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.accentPrimary.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentPrimary.withOpacity(0.18),
                  ),
                  child: const Icon(
                    Icons.chat_outlined,
                    color: AppTheme.accentPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Team Chat",
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 6,
                                  height: 6,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "LIVE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Talk with your team instantly",
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.accentPrimary.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembers(int memberCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("TEAM MEMBERS", style: AppTheme.sectionHeader),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withOpacity(0.45),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text('$memberCount', style: AppTheme.metaText),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        if (members.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text("No members yet", style: AppTheme.cardBody),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTheme.spacingM),
            itemBuilder: (_, index) => _buildMemberCard(members[index]),
          ),
      ],
    );
  }

  Widget _buildFloatingNavBar() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryBackground.withOpacity(0.65),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavBarItem(
                  icon: Icons.dashboard_rounded,
                  label: "Dashboard",
                  index: 0,
                ),
                _buildNavBarItem(
                  icon: Icons.dynamic_feed_rounded,
                  label: "Feed",
                  index: 1,
                ),
                _buildNavBarItem(
                  icon: Icons.notifications_rounded,
                  label: "Updates",
                  index: 2,
                  showBadge: _hasUnreadUpdates,
                ),
                _buildNavBarItem(
                  icon: Icons.report_rounded,
                  label: "Complaints",
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppTheme.spacingL : AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.accentPrimary.withOpacity(0.25),
                    AppTheme.accentSecondary.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isSelected
                ? AppTheme.accentPrimary.withOpacity(0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.accentPrimary
                      : AppTheme.textSecondary.withOpacity(0.8),
                  size: 22,
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBackground,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: AppTheme.navLabel.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final isCurrentUser = member['email'] == userEmail;
    final name = member['name']?.toString() ?? 'Unknown';
    final college = member['college']?.toString() ?? 'Unknown College';
    final linkedinUrl = member['linkedin_url']?.toString() ?? '';
    final hasLinkedin = linkedinUrl.isNotEmpty;
    final isJoined = member['joined'] == true;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final List<List<Color>> avatarGradients = [
      [const Color(0xFF4F8EF7), const Color(0xFF845EF7)],
      [const Color(0xFF20C997), const Color(0xFF4F8EF7)],
      [const Color(0xFFFF6B6B), const Color(0xFFFFD93D)],
      [AppTheme.accentPrimary, AppTheme.accentSecondary],
    ];
    final gradient =
        avatarGradients[initial.codeUnitAt(0) % avatarGradients.length];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.accentPrimary.withOpacity(0.05)
            : AppTheme.surfaceLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.accentPrimary.withOpacity(0.35)
              : AppTheme.borderColor.withOpacity(0.6),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTheme.cardTitle.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: AppTheme.accentPrimary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'You',
                          style: AppTheme.metaText.copyWith(
                            color: AppTheme.accentPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 12,
                      color: AppTheme.textSecondary.withOpacity(0.45),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        college,
                        style: AppTheme.metaText.copyWith(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withOpacity(0.75),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (hasLinkedin) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(linkedinUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo/linkedin-transparent.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isJoined
                  ? Colors.green.withOpacity(0.12)
                  : Colors.amber.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: isJoined
                    ? Colors.green.withOpacity(0.28)
                    : Colors.amber.withOpacity(0.28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isJoined ? Colors.green : Colors.amber,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isJoined ? 'Joined' : 'Pending',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: isJoined ? Colors.green : Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
