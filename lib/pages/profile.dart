import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFAF5),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFCFBF5),
      body: Center(
        child: Container(), // Beyaz sayfa
      ),
    );
  }
}
