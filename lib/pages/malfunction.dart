import 'package:flutter/material.dart';

class MalfunctionPage extends StatelessWidget {
  const MalfunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5),
      appBar: AppBar(
        title:
            const Text('Arıza Defteri', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFCFBF5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildMalfunctionEntry(
              member: 'Üye 1',
              description: 'Bugün cihaz açılmıyor, lütfen kontrol edin.',
              date: '2024-08-25',
              time: '14:30',
            ),
            const SizedBox(height: 10),
            _buildMalfunctionEntry(
              member: 'Üye 1',
              description: 'Ekran yanıt vermiyor, yardım bekliyorum.',
              date: '2024-08-24',
              time: '09:15',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMalfunctionEntry({
    required String member,
    required String description,
    required String date,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          children: [
            const Icon(
              Icons.person,
              size: 24,
              color: Colors.black, // İkon rengi siyah yapıldı
            ),
            const SizedBox(width: 8), // İkon ile metin arasında boşluk
            Text(
              member,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(width: 8), // Tarih ile saat arasında boşluk
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
