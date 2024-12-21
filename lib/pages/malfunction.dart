import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:io';

class MalfunctionPage extends StatelessWidget {
  const MalfunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Arıza Defteri',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFCFBF5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('error')
              .orderBy('timestamp', descending: true)
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
                String imagePath = malfunctionData['image_path'] ?? '';
                Timestamp timestamp =
                    malfunctionData['timestamp'] ?? Timestamp.now();

                DateTime dateTime = timestamp.toDate();
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateTime);
                String formattedTime = DateFormat('HH:mm').format(dateTime);
                String imageUrl = malfunctionData['image_url'] ??
                    ''; // 'image_url' Firestore'dan gelen URL alanı

                return Column(
                  children: [
                    _buildMalfunctionEntry(
                      context,
                      member: userName,
                      machine: machineName,
                      description: description,
                      date: formattedDate,
                      time: formattedTime,
                      imagePath: imagePath,
                      imageUrl: imageUrl, // Add this line
                    ),
                    const SizedBox(height: 20),
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
    required String imagePath, // Bu kısmı değiştireceğiz
    required String imageUrl, // Bu satırı ekledik
  }) {
    final random = Random();
    final randomAngle = (random.nextDouble() - 0.5) * 0.05;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      9,
                      (index) => Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        // Buradaki imagePath yerine imageUrl ekliyoruz
                        if (imagePath.isNotEmpty)
                          Image.file(
                            File(imagePath),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 4),
                        // Eğer image_url varsa, bunu da göstereceğiz
                        if (imagePath.isEmpty && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl, // Firestore'dan gelen URL
                            height: 200,
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
                                  date,
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
    final paintBrown = Paint()..color = const Color(0xFFF5DEB3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBrown);

    final paintLine = Paint()
      ..color = Colors.brown.withOpacity(0.25)
      ..strokeWidth = 1.0;
    double lineHeight = 24;
    for (double i = lineHeight; i < size.height; i += lineHeight) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintLine);
    }

    paintLine.color = Colors.brown.withOpacity(0.5);
    paintLine.strokeWidth = 1.5;
    double dashHeight = 4;
    for (double i = 0; i < size.height; i += 9) {
      canvas.drawLine(Offset(0, i), Offset(0, i + dashHeight), paintLine);
    }

    final paintEdges = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintEdges);

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
