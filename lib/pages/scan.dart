import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Debounce mekanizması için gerekli

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _popupShown = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _errorController =
      TextEditingController(); // Hata girişi için kontrolör
  Timer? _debounce; // Debounce mekanizması için zamanlayıcı

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

  // Hata verisini Firestore'a kaydetme fonksiyonu
  Future<void> _addErrorEntry(
      String userName, String machineName, String error) async {
    final now = Timestamp.now();
    await _firestore.collection('error').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
      'error': error,
    });
  }

  // Kontrol verisini Firestore'a kaydetme fonksiyonu
  Future<void> _addCheckedEntry(String userName, String machineName) async {
    final now = Timestamp.now();
    await _firestore.collection('checked').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
    });
  }

  void _showErrorPopup(BuildContext context, String machineName) {
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
                  });
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Pop-up kapandığında çalışacak kısım
      setState(() {
        _popupShown = false;
      });
    });
    _popupShown = true;
  }

  void _showPopup(BuildContext context, String machineName) async {
    final userData = await _getUserData();
    String userName = userData['name'] ?? 'Unknown';

    showDialog(
      context: context,
      barrierDismissible: true, // Boş alana tıklayınca kapansın
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
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Pop-up kapandığında çalışacak kısım
      setState(() {
        _popupShown = false;
      });
    });

    // Pop-up açık olduğunda QR kod okumayı durdur
    _popupShown = true;
  }

  Future<void> _checkQRCode(String scannedCode) async {
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

  void _onDetectBarcode(BarcodeCapture barcodeCapture) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 100), () {
      final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty
          ? barcodeCapture.barcodes.first
          : null;
      if (barcode != null) {
        final String? scannedCode = barcode.rawValue;
        if (scannedCode != null && !_popupShown) {
          _checkQRCode(scannedCode.trim());
        }
      }
    });
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
            borderRadius: BorderRadius.circular(16), // Kenarları yuvarlak yap
            child: MobileScanner(
              onDetect: _onDetectBarcode,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _errorController.dispose();
    super.dispose();
  }
}
