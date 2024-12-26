import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

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
                      imageUrl: imageUrl,
                      documentId: malfunctionDocs[index].id,
                      malfunctionData: malfunctionData, // Bu satırı ekleyin
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
    required String imagePath,
    required String imageUrl,
    required String documentId, // Arıza doküman ID'si
    required Map<String, dynamic> malfunctionData,
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
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
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
                              size: 20,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                machine,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
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
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                description,
                                style: GoogleFonts.nunito(
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (imagePath.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _showFullImage(context, File(imagePath));
                            },
                            child: Image.file(
                              File(imagePath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (imagePath.isEmpty && imageUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _showFullImage(context, imageUrl);
                            },
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Arıza tarihi ve saatine ek olarak ikonun gösterimi
                        // Arıza tarihi ve saatine ek olarak ikonun gösterimi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // completed_at tarihini burada ekliyoruz
                                if (malfunctionData['completed_at'] !=
                                    null) ...[
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                          (malfunctionData['completed_at']
                                                  as Timestamp)
                                              .toDate(),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.green, // Aynı yeşil renk
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const IconButton(
                                        icon: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        onPressed: null, // Artık tıklanamaz
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors
                                          .red, // Tamamlanmamış arızalar için kırmızı
                                      size: 30,
                                    ),
                                    onPressed: malfunctionData[
                                                'completed_at'] ==
                                            null
                                        ? () async {
                                            // Eğer 'completed_at' daha önce ayarlanmamışsa güncelleniyor
                                            await FirebaseFirestore.instance
                                                .collection('error')
                                                .doc(documentId)
                                                .update({
                                              'completed_at':
                                                  FieldValue.serverTimestamp(),
                                            });
                                          }
                                        : null, // Eğer zaten tamamlanmışsa tıklanamaz hale getiriliyor
                                  ),
                                ],
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black45,
                                  ),
                                ),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 15,
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

  void _showFullImage(BuildContext context, dynamic image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Marginleri kaldırıyoruz
          backgroundColor: Colors.transparent, // Arka planı şeffaf yapıyoruz
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Resme tıklanarak dialog'dan çıkılıyor
            },
            child: Stack(
              children: [
                // Saydam siyah arka plan
                Container(
                  color: Colors.black.withOpacity(
                      0.7), // Arka planı siyah ve %70 saydam yapıyoruz
                  width: double.infinity,
                  height: double.infinity,
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        0), // Resmin köşelerini yuvarlatmadan tam şekilde gösteriyoruz
                    child: InteractiveViewer(
                      panEnabled: true, // Pan hareketine izin veriyoruz
                      scaleEnabled:
                          true, // Yakınlaştırma/uzaklaştırma işlemlerine izin veriyoruz
                      child: image is File
                          ? Image.file(
                              image,
                              fit: BoxFit
                                  .contain, // Resmi orijinal boyutlarında, tam olarak ekrana sığacak şekilde gösteriyoruz
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.network(
                              image,
                              fit: BoxFit
                                  .contain, // Resmi orijinal boyutlarında, tam olarak ekrana sığacak şekilde gösteriyoruz
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
