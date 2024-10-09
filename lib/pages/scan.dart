import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _errorController = TextEditingController();
  bool _popupShown = false; // Pop-up gösterilip gösterilmediğini izleyen durum

  void _showErrorPopup(BuildContext context, String machineName) {
    if (_popupShown) return; // Pop-up açıksa bu fonksiyonu durdur
    _popupShown = true; // Pop-up gösterilmeye başlandığında durum güncelle

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(bottom: 4),
          content: SizedBox(
            width: 200,
            height: 200,
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Arızayı yazınız...',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _errorController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Arıza detaylarını girin',
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _popupShown = false; // Pop-up kapandığında durum güncelle
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Gönder'),
              onPressed: () {
                final error = _errorController.text;
                if (error.isNotEmpty) {
                  _getUserData().then((userData) {
                    String userName = userData['name'] ?? 'Unknown';
                    _addErrorEntry(userName, machineName, error);
                    Navigator.of(context).pop();
                    setState(() {
                      _popupShown =
                          false; // Hata pop-up'ı kapandığında durum güncelle
                    });
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPopup(BuildContext context, String machineName) async {
    if (_popupShown) return; // Pop-up açıksa bu fonksiyonu durdur
    _popupShown = true; // Pop-up gösterilmeye başlandığında durum güncelle

    final userData = await _getUserData();
    String userName = userData['name'] ?? 'Unknown';

    showDialog(
      context: context,
      barrierDismissible: false, // Pop-up dışında tıklanarak kapanamaz
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(bottom: 4),
          content: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    machineName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: const BeveledRectangleBorder(),
                            backgroundColor: Colors.red.withOpacity(0.5),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showErrorPopup(context, machineName);
                          },
                          child: Center(
                            child: Text(
                              'ARIZA BİLDİR',
                              style: GoogleFonts.tourney(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        color: Colors.black,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: const BeveledRectangleBorder(),
                            backgroundColor: Colors.green.withOpacity(0.5),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await _addCheckedEntry(userName, machineName);
                            Navigator.of(context).pop();
                            setState(() {
                              _popupShown =
                                  false; // Kontrol edildi pop-up'ı kapandığında durum güncelle
                            });
                          },
                          child: Center(
                            child: Text(
                              'KONTROL EDİLDİ',
                              style: GoogleFonts.tourney(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _popupShown =
                      false; // Kapatma butonuna tıklanınca durum güncelle
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _checkQRCode(String scannedCode) async {
    final snapshot =
        await _firestore.collection('machines').doc('resort').get();
    final machines = snapshot.data()?['machines'] as List<dynamic>?;

    if (machines != null) {
      for (var machine in machines) {
        if (machine['qrCode'] == scannedCode) {
          if (!_popupShown) {
            _showPopup(context, machine['machineName']);
          }
          return;
        }
      }

      if (!_popupShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eşleşme yok!'),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    // Kullanıcı verilerini almak için yazılacak fonksiyon
    // Örneğin:
    // return await FirebaseFirestore.instance.collection('users').doc(userId).get().then((doc) => doc.data());
    return {'name': 'Test User'}; // Test verisi
  }

  Future<void> _addCheckedEntry(String userName, String machineName) async {
    // Kontrol kayıtlarını Firestore'a ekleme işlemi
    await _firestore.collection('checked').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addErrorEntry(
      String userName, String machineName, String error) async {
    // Arıza kayıtlarını Firestore'a ekleme işlemi
    await _firestore.collection('error').add({
      'user_name': userName,
      'machine_name': machineName,
      'error': error,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final Barcode barcode in barcodes) {
            _checkQRCode(barcode.rawValue!);
          }
        },
      ),
    );
  }
}
