import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MalfunctionPage extends StatelessWidget {
  const MalfunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5), // Sayfa arkaplan rengi
      appBar: AppBar(
        title: const Text(
          'Arıza Defteri',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFCFBF5), // AppBar arka plan rengi
        elevation: 0, // AppBar gölgesi kaldırıldı
        centerTitle: true, // Başlığı ortala
        iconTheme:
            const IconThemeData(color: Colors.black), // Geri okunun rengi
      ),
      body: Container(
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
    );
  }

  Widget _buildMalfunctionEntry({
    required String member,
    required String description,
    required String date,
    required String time,
  }) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

    return CustomPaint(
      painter: OldPaperPainter(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(0.1), // İçerik arka planı için hafif beyaz
          borderRadius: BorderRadius.zero, // Kenarları dik
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
      ),
    );
  }
}

class OldPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Saman kağıdı rengi (daha soluk, sararmış)
    final paintBrown = Paint()
      ..color = const Color(0xFFF5DEB3); // Eski kağıt rengi
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBrown);

    // Hafif doku eklemek için rastgele çizgiler
    final paintTexture = Paint()..color = Colors.brown.withOpacity(0.15);
    for (double i = 0; i < size.width; i += 8) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintTexture);
    }

    // Yatay çizgiler (kağıt üzerindeki hafif çizgiler)
    final paintDarkGrey = Paint()
      ..color = Colors.brown.withOpacity(0.25)
      ..strokeWidth = 1.0;

    // Çizgi sayısını 6'ya düşür
    for (double i = 0; i < 6; i++) {
      double position = size.height * (i / 6);
      canvas.drawLine(
          Offset(0, position), Offset(size.width, position), paintDarkGrey);
    }

    // Sayfanın kenarlarına hafif gölgeler
    final paintEdges = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height), // Dik köşeler
      paintEdges,
    );
  }

  @override
  bool shouldRepaint(OldPaperPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(OldPaperPainter oldDelegate) {
    return false;
  }
}
