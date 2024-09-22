import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MalfunctionPage extends StatelessWidget {
  const MalfunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: PagePainter(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          height: double.infinity,
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
      ),
    );
  }

  Widget _buildMalfunctionEntry({
    required String member,
    required String description,
    required String date,
    required String time,
  }) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
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
              color: Colors.black,
            ),
            const SizedBox(width: 8),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }
}

class PagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Defter sayfası arka planı
    final paintWhite = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintWhite);

    // Yatay çizgiler
    final paintDarkGrey = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.0;
    for (double i = 0; i < 15; i++) {
      double position = size.height * (i / 15);
      canvas.drawLine(
          Offset(0, position), Offset(size.width, position), paintDarkGrey);
    }

    // Pembe dikey çizgi
    final paintPink = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(size.width * .1, 0),
        Offset(size.width * .1, size.height), paintPink);

    // Başlık çizgisi
    final paintHeaderLine = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paintHeaderLine);
  }

  @override
  bool shouldRepaint(PagePainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(PagePainter oldDelegate) {
    return false;
  }
}
