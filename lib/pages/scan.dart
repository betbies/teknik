import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final String _expectedQRCodeContent =
      'https://www.tthotels.com/en/hotel/aqi-pegasos-resort/b/isitmakazani1';
  bool _popupShown = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı verilerini Firestore'dan alma fonksiyonu
  Future<Map<String, dynamic>> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  // Timestamp ile veri ekleme fonksiyonu
  Future<void> _addCheckedEntry(String userName) async {
    final now = Timestamp.now(); // Firestore Timestamp formatı kullanılıyor

    // 'checked' koleksiyonuna yeni bir belge ekleyin
    await _firestore.collection('checked').add({
      'user_name': userName,
      'timestamp': now, // Timestamp olarak saklanacak
    });
  }

  void _showErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.5),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(bottom: 4),
          content: const SizedBox(
            width: 200,
            height: 150,
            child: Center(
              child: Text(
                'Arızayı yazınız...',
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPopup(BuildContext context) async {
    final userData = await _getUserData();
    String userName = userData['name'] ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.5),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(bottom: 4),
          content: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'ISITMA KAZANI 1',
                    style: TextStyle(
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
                            _showErrorPopup(context);
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
                            await _addCheckedEntry(userName);
                            Navigator.of(context).pop();
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
                  _popupShown = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('QR Kod Tarayıcı'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty
                    ? barcodeCapture.barcodes.first
                    : null;
                if (barcode != null) {
                  final String? scannedCode = barcode.rawValue;
                  if (scannedCode != null &&
                      scannedCode.trim() == _expectedQRCodeContent) {
                    if (!_popupShown) {
                      setState(() {
                        _popupShown = true;
                      });
                      _showPopup(context);
                    }
                  } else if (scannedCode != null) {
                    if (!_popupShown) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Eşleşme yok!'),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
