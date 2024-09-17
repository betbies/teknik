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
              title: 'Arıza 1',
              description:
                  'Bu arıza, cihazın açılmaması ile ilgili bir sorunu içerir.',
              date: '2024-08-25',
              isTransparentBackground: true,
            ),
            const SizedBox(height: 10),
            _buildMalfunctionEntry(
              title: 'Arıza 2',
              description: 'Bu arıza, ekranın yanıt vermemesi ile ilgilidir.',
              date: '2024-08-24',
              isTransparentBackground: true,
            ),
            // Üçüncü arıza kaydını kaldırdık.
          ],
        ),
      ),
    );
  }

  Widget _buildMalfunctionEntry({
    required String title,
    required String description,
    required String date,
    bool isTransparentBackground = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isTransparentBackground
            ? Colors.white.withOpacity(0.8)
            : Colors.white,
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        trailing: Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
      ),
    );
  }
}
