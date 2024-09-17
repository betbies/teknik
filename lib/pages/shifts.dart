import 'package:flutter/material.dart';

class ShiftsPage extends StatelessWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDE0FE),
      appBar: AppBar(
        title: const Text('Vardiyalar', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFCFBF5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildExpansionTile(
              title: 'Shift A',
              icon: Icons.wb_sunny,
              color: Colors.orangeAccent,
              content: 'Details about the morning shift...',
            ),
            const SizedBox(height: 10),
            _buildExpansionTile(
              title: 'Shift B',
              icon: Icons.cloud,
              color: Colors.blueAccent,
              content: 'Details about the evening shift...',
            ),
            const SizedBox(height: 10),
            _buildExpansionTile(
              title: 'Shift C',
              icon: Icons.nights_stay,
              color: Colors.deepPurpleAccent,
              content: 'Details about the night shift...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15.0),
      elevation: 4.0,
      shadowColor: color.withOpacity(0.5),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
