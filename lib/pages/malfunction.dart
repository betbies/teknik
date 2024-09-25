import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Rastgele sayı üretmek için

class MalfunctionPage extends StatelessWidget {
  const MalfunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5), // Sayfa arkaplan rengi
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri tuşunu kaldırır
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
            const SizedBox(height: 20), // İki arıza girişi arasında boşluk
            _buildMalfunctionEntry(
              member: 'Üye 1',
              description: 'Ekran yanıt vermiyor, yardım bekliyorum.',
              date: '2024-08-24',
              time: '09:15',
            ),
            const SizedBox(height: 20), // İki arıza girişi arasında boşluk
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
    final random = Random();
    final randomAngle =
        (random.nextDouble() - 0.5) * 0.2; // -0.1 ile 0.1 arasında rastgele açı

    return Stack(
      children: [
        Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..rotateZ(randomAngle), // Rastgele açı ile döndür
          child: CustomPaint(
            painter: OldPaperPainter(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.1), // İçerik arka planı için hafif beyaz
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(
                      height: 10), // Yuvarlakları aşağıya kaydırmak için
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      9,
                      (index) => Container(
                        width: 15, // Yuvarlak boyutu
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), // Yuvarlak rengi
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
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
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8, // Y ekseninde konum
          left: 0, // X ekseninde konum
          right: 0, // Eşit bir şekilde sağa da yerleştirmek için
          child: Center(
            child: Transform.rotate(
              angle: -0.5, // Ataşı biraz döndür
              child: const Icon(
                Icons.attach_file, // Ataş simgesi
                size: 30,
                color: Colors.brown, // Ataş rengi
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OldPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBrown = Paint()
      ..color = const Color(0xFFF5DEB3); // Eski kağıt rengi
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBrown);

    final paintLine = Paint()
      ..color = Colors.brown.withOpacity(0.25)
      ..strokeWidth = 1.0;

    double lineHeight = 24; // Sabit satır yüksekliği
    for (double i = lineHeight; i < size.height; i += lineHeight) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintLine);
    }

    // Kesik çizgileri ekle
    paintLine.color = Colors.brown.withOpacity(0.5);
    paintLine.strokeWidth = 1.5;
    double dashHeight = 4; // Kesik çizgilerin yüksekliği
    for (double i = 0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(0, i + dashHeight), paintLine);
    }

    // Sayfanın kenarlarına hafif gölgeler
    final paintEdges = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
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
