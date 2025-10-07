import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthHandler {
  static String getRedirectUrl() {
    if (kIsWeb) {
      // For web, use the current host
      return '${Uri.base.origin}/#/reset-password';
    } else {
      // For mobile, use custom URL scheme
      return 'com.example.ecommerce_app://login-callback';
    }
  }

  static String getBaseUrl() {
    if (kIsWeb) {
      return Uri.base.origin;
    } else {
      return 'com.example.ecommerce_app://login-callback';
    }
  }

  static Future<void> handleAuthCallback() async {
    if (!kIsWeb) {
      // For mobile, we need to handle the deep link
      try {
        final session = supabase.auth.currentSession;
        if (session != null) {
          print('Mobile auth session restored: ${session.user.email}');
        }
      } catch (e) {
        print('Error handling mobile auth callback: $e');
      }
    }
  }
}

class AuthStateListener extends StatefulWidget {
  final Widget child;
  
  const AuthStateListener({
    super.key,
    required this.child,
  });

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      print('Auth state changed: $event');
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        print('User signed in: ${session.user.email}');
        // Handle successful sign in
      } else if (event == AuthChangeEvent.signedOut) {
        print('User signed out');
        // Handle sign out
      } else if (event == AuthChangeEvent.passwordRecovery && session != null) {
        print('Password recovery initiated');
        // Navigate to reset password screen
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/reset-password',
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}