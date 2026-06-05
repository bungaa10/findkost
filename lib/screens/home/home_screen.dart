import 'package:findkost/owner/owner_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../mahasiswa/mahasiswa_home_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Debug buat cek role
    print('=========================================');
    print('HomeScreen - User Role: ${auth.userRole}');
    print('HomeScreen - User Data: ${auth.user}');
    print('=========================================');
    
    if (auth.userRole == 'pemilik') {
      return const OwnerDashboardScreen();
    } else {
      return const MahasiswaHomeScreen();
    }
  }
}