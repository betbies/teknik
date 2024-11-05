import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _popupShown = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _errorController = TextEditingController();
  Timer? _debounce;
  bool _isScanningAllowed = true;
  String? _imageUrl;

  Future<Map<String, dynamic>> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> _addErrorEntry(
      String userName, String machineName, String error) async {
    final now = Timestamp.now();
    await _firestore.collection('error').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
      'error': error,
      'image_url': _imageUrl,
    });
  }

  Future<void> _addCheckedEntry(String userName, String machineName) async {
    final now = Timestamp.now();
    await _firestore.collection('checked').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
    });
  }

  void _showErrorPopup(BuildContext context, String machineName) {
    _popupShown = true;
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Arıza detaylarını girin',
                    ),
                    maxLines: 3,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      setState(() {
                        _imageUrl = pickedFile.path;
                      });
                    }
                  },
                  child: const Text('Fotoğraf Çek'),
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
                      _popupShown = false;
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

  void _showPopup(
      BuildContext context, String docName, String machineName) async {
    final userData = await _getUserData();
    String userName = userData['name'] ?? 'Unknown';
    _popupShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                // Doküman adı ve makine adı üst üste ekleniyor
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        docName, // Doküman adı
                        style: GoogleFonts.rubik(
                          // Yazı tipi Roboto olarak ayarlandı
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey, // Metin rengi gri yapıldı
                          fontStyle: FontStyle.italic, // Metin italik yapıldı
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        machineName, // Makine adı
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                              _popupShown = false;
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
                  _popupShown = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkQRCode(String scannedCode) async {
    // 'resort', 'club' ve 'royal' dokümanlarını belirtiyoruz
    final documentNames = ['resort', 'club', 'royal'];

    for (var docName in documentNames) {
      final snapshot =
          await _firestore.collection('machines').doc(docName).get();
      final machines = snapshot.data()?['machines'] as List<dynamic>?;

      if (machines != null) {
        for (var machine in machines) {
          if (machine['qrCode'] == scannedCode) {
            if (!_popupShown) {
              // Doküman adı ve makine adını gönderiyoruz
              _showPopup(context, docName, machine['machineName']);
            }
            return;
          }
        }
      }
    }

    // Eşleşme yoksa bildirim gösteriliyor
    if (!_popupShown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eşleşme yok!'),
        ),
      );
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
        if (scannedCode != null && !_popupShown && _isScanningAllowed) {
          _checkQRCode(scannedCode.trim());
          _isScanningAllowed = false;
          Future.delayed(const Duration(seconds: 1), () {
            _isScanningAllowed = true;
          });
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
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0), // Kenarlık yuvarlatıldı
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: MobileScanner(
              onDetect: _onDetectBarcode,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
