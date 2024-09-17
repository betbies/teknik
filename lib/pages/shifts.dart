import 'package:flutter/material.dart';

class ShiftsPage extends StatelessWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;

    // Shift'in otomatik olarak genişletilmesi için kontrol
    bool isShiftAOpen = currentHour >= 8 && currentHour < 16;
    bool isShiftBOpen = currentHour >= 16 && currentHour < 24;
    bool isShiftCOpen = currentHour >= 0 && currentHour < 8;

    return Scaffold(
      backgroundColor: const Color(0xFBFAF5),
      appBar: AppBar(
        title: const Text('Vardiyalar'), // Üst bar başlığı
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5), // İstediğiniz renk
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShiftTile(
            'Shift A',
            Icons.wb_sunny,
            Colors.orangeAccent,
            'Details about the morning shift...',
            isShiftAOpen,
          ),
          const SizedBox(height: 16),
          _buildShiftTile(
            'Shift B',
            Icons.cloud,
            Colors.blueAccent,
            'Details about the evening shift...',
            isShiftBOpen,
          ),
          const SizedBox(height: 16),
          _buildShiftTile(
            'Shift C',
            Icons.nights_stay,
            Colors.deepPurpleAccent,
            'Details about the night shift...',
            isShiftCOpen,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTile(
    String title,
    IconData icon,
    Color color,
    String content,
    bool isInitiallyExpanded,
  ) {
    // Arka plan renginin opaklığını yarıya düşür
    Color backgroundColor = color.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, backgroundColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
          title: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          initiallyExpanded: isInitiallyExpanded,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
