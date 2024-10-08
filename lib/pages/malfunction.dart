import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore ekledik
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('error')
              .orderBy('timestamp', descending: true) // Zaman sırasına göre
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var malfunctionDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: malfunctionDocs.length,
              itemBuilder: (context, index) {
                var malfunctionData =
                    malfunctionDocs[index].data() as Map<String, dynamic>;

                String userName = malfunctionData['user_name'] ?? 'Bilinmiyor';
                String machineName =
                    malfunctionData['machine_name'] ?? 'Bilinmiyor';
                String description =
                    malfunctionData['error'] ?? 'Bilinmeyen hata';
                Timestamp timestamp =
                    malfunctionData['timestamp'] ?? Timestamp.now();

                // Tarih ve saat formatlama
                DateTime dateTime = timestamp.toDate();
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateTime);
                String formattedTime = DateFormat('HH:mm').format(dateTime);

                return Column(
                  children: [
                    _buildMalfunctionEntry(
                      context, // context'i burada geçiyoruz
                      member: userName,
                      machine: machineName,
                      description: description,
                      date: formattedDate,
                      time: formattedTime,
                    ),
                    const SizedBox(
                        height: 20), // İki arıza girişi arasında boşluk
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMalfunctionEntry(
    BuildContext context, {
    // context'i parametre olarak al
    required String member,
    required String machine,
    required String description,
    required String date,
    required String time,
  }) {
    final formattedDate = date;
    final random = Random();
    final randomAngle = (random.nextDouble() - 0.5) * 0.1; // Rastgele açı

    return Stack(
      children: [
        Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..rotateZ(randomAngle), // Rastgele açı ile döndür
          child: CustomPaint(
            painter: OldPaperPainter(),
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.85, // Sayfa genişliğini küçült
              padding: const EdgeInsets.all(9.0), // İçerik için padding ekle
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1), // İçerik arka planı
              ),
              child: Column(
                children: [
                  const SizedBox(
                      height: 1), // Yuvarlakları aşağı kaydırmak için
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      9,
                      (index) => Container(
                        width: 15, // Yuvarlak boyutu
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF), // Yuvarlak rengi
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Padding'i sıfırla
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
                          machine,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
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
          top: 0, // Y ekseninde konum
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

    paintLine.color = Colors.brown.withOpacity(0.5);
    paintLine.strokeWidth = 1.5;
    double dashHeight = 4; // Kesik çizgilerin yüksekliği
    for (double i = 0; i < size.height; i += 9) {
      canvas.drawLine(Offset(0, i), Offset(0, i + dashHeight), paintLine);
    }

    final paintEdges = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintEdges);
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
