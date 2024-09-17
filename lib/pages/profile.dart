import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'), // Üst bar başlığı
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5), // İstediğiniz renk
      ),
      backgroundColor: const Color(0xFFFCFBF5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 120,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TUI HOTELS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'tui@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: 'Telefon',
                      value: '+1 234 567 890',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.location_on,
                      title: 'Adres',
                      value: 'AQI PEGASOS HOTELS',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.date_range,
                      title: 'Doğum Tarihi',
                      value: '1 Ocak 1990',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.work,
                      title: 'Meslek',
                      value: 'Elektrikçi',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
