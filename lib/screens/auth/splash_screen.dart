import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🟢 SplashScreen: initState called');
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    print('🟢 SplashScreen: _checkLogin started');
    
    final auth = context.read<AuthProvider>();
    print('🟢 SplashScreen: calling loadSession');
    
    await auth.loadSession();
    print('🟢 SplashScreen: loadSession finished');
    
    print('🟢 SplashScreen: auth.isLogin = ${auth.isLogin}');
    print('🟢 SplashScreen: auth.user = ${auth.user}');
    
    await Future.delayed(const Duration(seconds: 2));
    print('🟢 SplashScreen: delay finished');
    
    if (!mounted) return;
    
    if (auth.isLogin) {
      print('🟢 SplashScreen: navigating to HomeScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      print('🟢 SplashScreen: navigating to LoginScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 SplashScreen: build called');
    return Scaffold(
      backgroundColor: const Color(0xff2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.home_work,
                      size: 60,
                      color: Color(0xff2563EB),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "FindKost",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Temukan Kost Terbaik untukmu",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}