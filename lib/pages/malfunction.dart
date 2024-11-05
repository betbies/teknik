import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore ekledik
import 'dart:math'; // Rastgele sayı üretmek için
import 'dart:io'; // File sınıfını kullanmak için

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
                String imagePath =
                    malfunctionData['image_path'] ?? ''; // Fotoğraf yolu
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
                      context,
                      member: userName,
                      machine: machineName,
                      description: description,
                      date: formattedDate,
                      time: formattedTime,
                      imagePath: imagePath, // Fotoğraf yolunu ekle
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
    required String member,
    required String machine,
    required String description,
    required String date,
    required String time,
    required String imagePath, // Yeni parametre
  }) {
    final formattedDate = date;
    final random = Random();
    final randomAngle = (random.nextDouble() - 0.5) * 0.05; // Rastgele açı

    return Stack(
      children: [
        Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()..rotateZ(randomAngle),
          child: CustomPaint(
            painter: OldPaperPainter(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(9.0),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                machine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.error,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (imagePath.isNotEmpty) // Eğer fotoğraf varsa göster
                          Image.file(
                            File(imagePath), // Burada Image.file kullanıyoruz
                            height: 200, // Görsel boyutu
                            width: double.infinity,
                            fit: BoxFit.cover,
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
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: -0.5,
              child: const Icon(
                Icons.attach_file,
                size: 30,
                color: Colors.brown,
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

    // Sayfa altındaki gölgelendirme
    final paintShadow = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height - 10, size.width, 10), paintShadow);
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
