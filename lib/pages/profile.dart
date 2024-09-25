import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFAF5),
        elevation: 0, // Düz bir AppBar tasarımı için gölgeyi kaldırıyoruz
      ),
      backgroundColor: const Color(0xFFFCFBF5), // Arka plan rengi
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
                  color:
                      const Color(0xFFDDEEFA), // Daha hafif bir arka plan rengi
                  borderRadius:
                      BorderRadius.circular(30.0), // Daha yuvarlak köşeler
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF181A18)
                          .withOpacity(0.2), // Gölgede tema rengi
                      blurRadius: 12.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF89CFF0), // Tema mavi renk
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TUI HOTELS',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181A18),
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
                    const SizedBox(height: 24),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: 'Telefon',
                      value: '+1 234 567 890',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      icon: Icons.location_on,
                      title: 'Adres',
                      value: 'AQI PEGASOS HOTELS',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      icon: Icons.date_range,
                      title: 'Doğum Tarihi',
                      value: '1 Ocak 1990',
                    ),
                    const SizedBox(height: 16),
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
        Icon(icon, size: 28, color: const Color(0xFF6CAEED)), // Tema rengi
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
                  color: Color(0xFF181A18), // Koyu tema rengi
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
