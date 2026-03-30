import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/session_service.dart';
import '../../services/supabase_service.dart';

class AuthRepository {
  /// Get the correct redirect URL based on platform
  static String? _getRedirectUrl() {
    if (kIsWeb) {
      // Must exactly match one of the Redirect URLs in Supabase dashboard
      // Site URL is https://app.code-nyx.tech/ so we use that
      return 'https://app.code-nyx.tech/';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return 'io.supabase.flutter://login-callback/';
    }

    return null;
  }

  /// Sign in with Google via Supabase OAuth
  static Future<void> signInWithGoogle() async {
    print('🌐 Starting Google OAuth...');
    print('📱 Platform: ${_getPlatformName()}');

    final redirectUrl = _getRedirectUrl();
    print('🔄 Redirect URL: $redirectUrl');

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      print('✅ OAuth initiated successfully');
    } catch (e) {
      print('❌ OAuth error: $e');
      rethrow;
    }
  }

  /// Helper to normalize email
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static Future<Map<String, dynamic>> signInWithEmail(String email) async {
    final normalizedEmail = normalizeEmail(email);

    try {
      final response = await SupabaseService.client
          .from('team_members')
          .select()
          .eq('email', normalizedEmail)
          .maybeSingle();

      if (response == null) {
        throw Exception("EMAIL_NOT_FOUND");
      }

      final teamId = (response['team_id'] ?? '').toString();
      final name = (response['name'] ?? '').toString();

      await SessionService.saveSession(
        normalizedEmail,
        teamId,
        userName: name.isEmpty ? null : name,
      );

      await SupabaseService.client
          .from('team_members')
          .update({'joined': true})
          .eq('email', normalizedEmail);

      return {'email': normalizedEmail, 'team_id': teamId, 'name': name};
    } catch (e) {
      if (e.toString().contains("EMAIL_NOT_FOUND")) {
        rethrow;
      }
      throw Exception("UNKNOWN_ERROR");
    }
  }

  /// Find which team the user belongs to using their email
  static Future<String?> findUserTeam(String email) async {
    try {
      final normalizedEmail = normalizeEmail(email);
      print('🔍 Finding team for email: $normalizedEmail');

      final response = await SupabaseService.client
          .from('team_members')
          .select('team_id')
          .eq('email', normalizedEmail)
          .maybeSingle();

      if (response != null) {
        final teamId = response['team_id'] as String;
        print('✅ Team found: $teamId');

        await SupabaseService.client
            .from('team_members')
            .update({'joined': true})
            .eq('team_id', teamId)
            .eq('email', normalizedEmail);

        print('✅ User marked as joined');
        return teamId;
      } else {
        print('❌ No team found for email: $normalizedEmail');
        return null;
      }
    } catch (e) {
      print('❌ Error finding team: $e');
      rethrow;
    }
  }

  /// Sign out the current user and clear all session data
  static Future<void> signOut() async {
    try {
      print('👋 Signing out...');
      await SupabaseService.client.auth.signOut();
      await SessionService.clearSession();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Get current authenticated user email
  static String? getCurrentUserEmail() {
    return SupabaseService.client.auth.currentUser?.email;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return SupabaseService.client.auth.currentUser != null;
  }

  /// Get team members
  static Future<List<Map<String, dynamic>>> getTeamMembers(
    String teamId,
  ) async {
    try {
      print('📋 Fetching team members for: $teamId');
      final response = await SupabaseService.client
          .from('team_members')
          .select()
          .eq('team_id', teamId)
          .order('name', ascending: true);

      print('✅ Team members fetched: ${response.length} members');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching team members: $e');
      return [];
    }
  }

  /// Get team info
  static Future<Map<String, dynamic>?> getTeamInfo(String teamId) async {
    try {
      print('🏢 Fetching team info for: $teamId');
      final response = await SupabaseService.client
          .from('teams')
          .select()
          .eq('team_id', teamId)
          .maybeSingle();

      print('✅ Team info fetched: $response');
      return response;
    } catch (e) {
      print('Error fetching team info: $e');
      return null;
    }
  }

  /// Mark user as joined
  static Future<bool> markUserAsJoined(String teamId, String email) async {
    try {
      final normalizedEmail = normalizeEmail(email);
      await SupabaseService.client
          .from('team_members')
          .update({'joined': true})
          .eq('team_id', teamId)
          .eq('email', normalizedEmail);
      return true;
    } catch (e) {
      print('Error marking user as joined: $e');
      return false;
    }
  }

  /// Helper to get platform name for debugging
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
}
