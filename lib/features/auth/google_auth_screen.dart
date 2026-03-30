import 'dart:async';

import 'package:codenyx/core/theme/app_theme.dart';
import 'package:codenyx/services/session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_access.dart';
import 'auth_repository.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({super.key});

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  StreamSubscription<AuthState>? _authSubscription;
  bool _handledSignIn = false;

  bool loading = false;
  String? errorMessage;
  static const String _unregisteredUserMessage =
      'You are not registered for this hackathon. Please contact organizers.';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Setup listener FIRST before checking session
    // so we don't miss any events that fire during initState
    _setupAuthListener();

    // Then check if we already have a session (post-OAuth redirect on web)
    _checkForExistingSession();

    _animationController.forward();
  }

  /// Check if there's already a session (happens after OAuth redirect on web)
  void _checkForExistingSession() {
    print('🔍 Checking for existing session...');
    final session = Supabase.instance.client.auth.currentSession;
    final email = session?.user.email;

    print('   Session exists: ${session != null}');
    print('   User email: $email');
    print('   Platform: ${kIsWeb ? "Web" : "Mobile"}');

    if (email != null && !_handledSignIn) {
      print('✅ Found existing session — processing immediately');
      // Show loading while we process
      if (mounted) {
        setState(() => loading = true);
      }
      _processSignIn(email);
    }
  }

  /// Setup auth state change listener
  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      print('🔥 AUTH EVENT: ${data.event}');
      print('   User: ${data.session?.user.email}');

      // On web after OAuth redirect, Supabase fires INITIAL_SESSION or TOKEN_REFRESHED
      // On mobile it fires SIGNED_IN
      // We handle all three to be safe
      final shouldProcess =
          data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.initialSession ||
          data.event == AuthChangeEvent.tokenRefreshed;

      if (shouldProcess) {
        final email = data.session?.user.email;
        if (email != null && !_handledSignIn) {
          print('📧 Auth event "${data.event}" — processing sign-in');
          if (mounted) {
            setState(() => loading = true);
          }
          _processSignIn(email);
        }
      }
    });
  }

  /// Process sign-in: find team, save session, navigate
  Future<void> _processSignIn(String email) async {
    if (_handledSignIn) {
      print('⏭️ Already processing sign-in, skipping');
      return;
    }

    _handledSignIn = true;
    print('🔄 Processing sign-in for: $email');

    try {
      final isAdmin = isAdminUser(email);

      if (isAdmin) {
        print('✅ Admin detected -> skipping team check');
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage = null;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        print('🚀 Navigating to /admin');
        context.go('/admin');
        return;
      }

      // Find the user's team
      final teamId = await AuthRepository.findUserTeam(email);

      if (!mounted) {
        print('⚠️ Widget not mounted, aborting');
        return;
      }

      if (teamId == null) {
        print('❌ No team found for email');
        // Sign them out so they don't stay stuck in a bad state
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage = _unregisteredUserMessage;
        });
        _showErrorSnackBar(errorMessage!);
        _handledSignIn = false;
        return;
      }

      print('✅ Team found: $teamId');

      // Save session to local storage
      await SessionService.saveSession(email, teamId);
      print('✅ Session saved');

      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      print('🚀 Navigating to /dashboard');
      context.go('/dashboard');
    } catch (e) {
      print('❌ Error during sign-in: $e');
      _handledSignIn = false;

      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'Sign-in failed: ${e.toString()}';
      });
      _showErrorSnackBar(errorMessage!);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    print('🔘 Sign in button tapped');

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      _handledSignIn = false;
      print('🌐 Initiating Google OAuth...');
      await AuthRepository.signInWithGoogle();
      print('⏳ Waiting for OAuth redirect...');
    } catch (e) {
      print('❌ OAuth error: $e');
      if (!mounted) return;
      final errorMsg = 'Sign-in failed: ${e.toString()}';
      setState(() {
        loading = false;
        errorMessage = errorMsg;
      });
      _showErrorSnackBar(errorMsg);
    }
  }

  Future<void> _showEmailSignInSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EmailSignInSheet(
        onError: (message) {
          if (!mounted) return;
          setState(() {
            errorMessage = message;
          });
          _showErrorSnackBar(message);
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.borderColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingXL,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppTheme.spacingXL),

                      // Illustration/Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.security_outlined,
                          size: 50,
                          color: AppTheme.accentPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL * 1.5),

                      // Header Section
                      const Text(
                        "Welcome to CodeNyx",
                        style: AppTheme.pageTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        "Sign in with your Google account registered with the hackathon",
                        style: AppTheme.cardBody.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingXL * 2),

                      // Error Message Display
                      if (errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(
                            bottom: AppTheme.spacingL,
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(color: Colors.red, width: 1.2),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.block_rounded,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: AppTheme.spacingM),
                                  Text(
                                    'Access Denied',
                                    style: AppTheme.cardTitle.copyWith(
                                      color: Colors.red,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                'Contact Support: Please reach out to the organizers if you believe this is a mistake.',
                                style: AppTheme.metaText.copyWith(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Google Sign-In Button
                      _buildGoogleSignInButton(),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildAlternateSignInButton(),
                      const SizedBox(height: AppTheme.spacingXL * 1.5),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        decoration: AppTheme.cardDecoration(
                          borderRadius: AppTheme.radiusLarge,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: AppTheme.accentPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingL),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "How it works",
                                    style: AppTheme.cardTitle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    "Sign in with the Google account you used to register for the hackathon. We'll automatically find your team.",
                                    style: AppTheme.cardBody.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL * 2),

                      // Security Footer
                      Text(
                        "Your data is secure. We only use your email to find your team.",
                        style: AppTheme.metaText.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : signInWithGoogle,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
              alignment: Alignment.center,
              child: loading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        const Text(
                          "Signing in...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: AppTheme.accentPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternateSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : _showEmailSignInSheet,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.borderColor),
          foregroundColor: AppTheme.textPrimary,
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.55),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: const Text(
          'Sign in another way',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _EmailSignInSheet extends StatefulWidget {
  final Function(String) onError;

  const _EmailSignInSheet({required this.onError});

  @override
  State<_EmailSignInSheet> createState() => _EmailSignInSheetState();
}

class _EmailSignInSheetState extends State<_EmailSignInSheet> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  String? _sheetError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() => _sheetError = 'Please enter your email');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _sheetError = 'Enter a valid email');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _sheetError = null;
    });

    try {
      await AuthRepository.signInWithEmail(email);

      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/dashboard');
    } catch (e) {
      final message = e.toString().contains("EMAIL_NOT_FOUND")
          ? 'Email not found. Contact your team.'
          : 'Something went wrong. Try again.';

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _sheetError = message;
      });
      widget.onError(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  const Text('Sign in another way', style: AppTheme.cardTitle),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Enter the email you registered with for the hackathon.',
                    style: AppTheme.cardBody,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceLight.withOpacity(0.9),
                      errorText: _sheetError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
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
                      onPressed: _isSubmitting ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingL,
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
                                strokeWidth: 2.3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
