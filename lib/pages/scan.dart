import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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
  final Set<String> _activePopups = {}; // Açık olan pop-up'ları takip için
  final MobileScannerController _controller = MobileScannerController();
  bool _flashEnabled = false;
  File? _imageFile; // Fotoğrafı tutacak değişken

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
    String? imageUrl = await _uploadImage(); // Fotoğrafı yükle ve URL'yi al

    await _firestore.collection('error').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
      'error': error,
      'image_url': imageUrl ?? '', // Fotoğraf yoksa boş string atıyoruz
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('errors/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(_imageFile!);
      String downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl; // Fotoğrafın URL'sini döndürür
    } catch (e) {
      print("Fotoğraf yüklenirken hata oluştu: $e");
      return null;
    }
  }

  Future<void> _addCheckedEntry(String userName, String machineName) async {
    final now = Timestamp.now();
    final checkedSnapshot = await _firestore
        .collection('checked')
        .where('machine_name', isEqualTo: machineName)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (checkedSnapshot.docs.isNotEmpty) {
      final lastChecked = checkedSnapshot.docs.first;
      final lastCheckedTimestamp = lastChecked['timestamp'] as Timestamp;
      final lastCheckedTime = lastCheckedTimestamp.toDate();

      // 30 dakika kontrol süresi
      final thirtyMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 30));

      if (lastCheckedTime.isAfter(thirtyMinutesAgo)) {
        // Eğer son kontrol 30 dakika içinde yapılmışsa, uyarı ver
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu makineyi zaten kontrol ettiniz!')),
        );
        return;
      }
    }

    // Eğer 30 dakika geçmişse, kontrol işlemini ekle
    await _firestore.collection('checked').add({
      'user_name': userName,
      'machine_name': machineName,
      'timestamp': now,
    });
    _closeAllPopups(); // Pop-up'ları kapatıyoruz
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
            height: 300, // Popup boyutunu ayarlayalım
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
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40), // Kamera ikonu
                  onPressed: _pickImage, // Kamera açma
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
            )
          ],
        );
      },
    );
  }

  void _closeAllPopups() {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    setState(() {
      _popupShown = false;
      _activePopups.clear(); // Tüm pop-up'ları listeden kaldır
    });
  }

  void _showPopup(
      BuildContext context, String docName, String machineName) async {
    // Eğer pop-up zaten gösteriliyorsa çıkış yap
    if (_activePopups.contains(machineName)) {
      return;
    }

    // Yeni pop-up için ekle
    _activePopups.add(machineName);
    final userData = await _getUserData();
    String userName = userData['name'] ?? 'Unknown';

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
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        docName,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        machineName,
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
                                fontSize: 22,
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
                            // Eğer makine adı 'su deposu' içeriyorsa % değer için pop-up aç
                            if (machineName
                                .toLowerCase()
                                .contains('su deposu')) {
                              _showFillLevelPopup(context, machineName);
                            }
                            // Eğer makine adı '+' veya '-' içeriyorsa derece için pop-up aç
                            else if (machineName.contains('+') ||
                                machineName.contains('-')) {
                              _showTemperaturePopup(context, machineName);
                            } else {
                              await _addCheckedEntry(userName, machineName);
                              _closeAllPopups(); // Pop-up'ları kapatıyoruz
                            }
                          },
                          child: Center(
                            child: Text(
                              'KONTROL EDİLDİ',
                              style: GoogleFonts.tourney(
                                fontSize: 22,
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
                _closeAllPopups(); // Burada tüm pop-up'ları kapatıyoruz
              },
            ),
          ],
        );
      },
    );
  }

  bool _isSubmitting = false; // Gönder butonu durumu

  void _showTemperaturePopup(BuildContext context, String machineName) async {
    final TextEditingController temperatureController = TextEditingController();

    // Check if the machine has already been checked in the last 30 minutes
    final checkedSnapshot = await _firestore
        .collection('checked')
        .where('machine_name', isEqualTo: machineName)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (checkedSnapshot.docs.isNotEmpty) {
      final lastChecked = checkedSnapshot.docs.first;
      final lastCheckedTimestamp = lastChecked['timestamp'] as Timestamp;
      final lastCheckedTime = lastCheckedTimestamp.toDate();

      // 30 dakika kontrol süresi
      final thirtyMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 30));

      if (lastCheckedTime.isAfter(thirtyMinutesAgo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu makineyi zaten kontrol ettiniz!')),
        );
        _closeAllPopups(); // Pop-up'ları kapatıyoruz
        return;
      }
    }

    // Eğer 30 dakika geçmişse, derece popup'ını göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lütfen makine derecesini giriniz (°C):\n(Derece girerken , yerine . kullanınız)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: temperatureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                if (_isSubmitting)
                  return; // Eğer işlem devam ediyorsa buton çalışmaz
                _isSubmitting = true; // İşlem başladı

                final temperature = temperatureController.text;
                if (temperature.isNotEmpty) {
                  try {
                    final userData = await _getUserData();
                    String userName = userData['name'] ?? 'Unknown';
                    await _firestore.collection('checked').add({
                      'user_name': userName,
                      'machine_name': machineName,
                      'timestamp': Timestamp.now(),
                      'temperature': double.tryParse(temperature) ?? 0.0,
                    });
                    Navigator.of(context).pop();
                    _closeAllPopups(); // Pop-up'ları kapatıyoruz
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Derece kaydedildi!')),
                    );
                  } finally {
                    _isSubmitting = false; // İşlem bitti
                  }
                } else {
                  _isSubmitting = false; // Eğer giriş boşsa durumu sıfırla
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  void _showFillLevelPopup(BuildContext context, String machineName) async {
    final TextEditingController fillLevelController = TextEditingController();

    // Check if the machine has already been checked in the last 30 minutes
    final checkedSnapshot = await _firestore
        .collection('checked')
        .where('machine_name', isEqualTo: machineName)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (checkedSnapshot.docs.isNotEmpty) {
      final lastChecked = checkedSnapshot.docs.first;
      final lastCheckedTimestamp = lastChecked['timestamp'] as Timestamp;
      final lastCheckedTime = lastCheckedTimestamp.toDate();

      // 30 dakika kontrol süresi
      final thirtyMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 30));

      if (lastCheckedTime.isAfter(thirtyMinutesAgo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu makineyi zaten kontrol ettiniz!')),
        );
        _closeAllPopups(); // Pop-up'ları kapatıyoruz
        return;
      }
    }

    // Eğer 30 dakika geçmişse, doluluk oranı popup'ını göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lütfen doluluk oranını giriniz (%):',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fillLevelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                if (_isSubmitting)
                  return; // Eğer işlem devam ediyorsa buton çalışmaz
                _isSubmitting = true; // İşlem başladı

                final fillLevel = fillLevelController.text;
                if (fillLevel.isNotEmpty) {
                  try {
                    final userData = await _getUserData();
                    String userName = userData['name'] ?? 'Unknown';
                    await _firestore.collection('checked').add({
                      'user_name': userName,
                      'machine_name': machineName,
                      'timestamp': Timestamp.now(),
                      'fill_level':
                          int.tryParse(fillLevel) ?? 0, // Doluluk oranı
                    });
                    Navigator.of(context).pop();
                    _closeAllPopups(); // Pop-up'ları kapatıyoruz
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Doluluk oranı kaydedildi!')),
                    );
                  } finally {
                    _isSubmitting = false; // İşlem bitti
                  }
                } else {
                  _isSubmitting = false; // Eğer giriş boşsa durumu sıfırla
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkQRCode(String scannedCode) async {
    final documentNames = ['resort', 'club', 'royal'];

    for (var docName in documentNames) {
      final snapshot =
          await _firestore.collection('machines').doc(docName).get();
      final machines = snapshot.data()?['machines'] as List<dynamic>?;

      if (machines != null) {
        for (var machine in machines) {
          if (machine['qrCode'] == scannedCode) {
            if (!_activePopups.contains(machine['machineName'])) {
              _showPopup(context, docName, machine['machineName']);
            }
            return;
          }
        }
      }
    }

    // Eğer hiçbir eşleşme bulunmadıysa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eşleşme yok!'),
      ),
    );
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

          // 5 saniyelik bekleme
          Future.delayed(const Duration(seconds: 4), () {
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
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: _onDetectBarcode,
                  fit: BoxFit.cover,
                  controller: _controller,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      _flashEnabled ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _flashEnabled = !_flashEnabled;
                        _controller.toggleTorch();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
