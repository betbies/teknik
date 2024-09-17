import 'package:flutter/material.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekipler'), // Üst bar başlığı
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5), // İstediğiniz renk
      ),
      backgroundColor: const Color(0xFFFCFBF5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTeamTile(
              context, 'Resort Teknik Servis Ekibi', ['Üye 1', 'Üye 2']),
          const SizedBox(height: 16),
          _buildTeamTile(
              context, 'Royal Teknik Servis Ekibi', ['Üye 1', 'Üye 2']),
          const SizedBox(height: 16),
          _buildTeamTile(
              context, 'Club Teknik Servis Ekibi', ['Üye 1', 'Üye 2']),
        ],
      ),
    );
  }

  Widget _buildTeamTile(
      BuildContext context, String teamName, List<String> members) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFDDDDFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          title: Text(
            teamName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: members
              .map((member) => ListTile(
                    title: Text(
                      member,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
