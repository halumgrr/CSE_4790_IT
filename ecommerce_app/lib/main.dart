import 'package:flutter/material.dart';
import 'supabase_client.dart';
import 'auth_handler.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStateListener(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GhorerBazar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green[700],
            secondary: Colors.green[500],
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}