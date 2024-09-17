import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final String _expectedQRCodeContent =
      'https://www.tthotels.com/tr'; // Buraya gerçek QR kod içeriğini ekleyin
  bool _popupShown =
      false; // Pop-up'ın gösterilip gösterilmediğini takip eden değişken

  void _showErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white
              .withOpacity(0.5), // Arka plan rengini %50 şeffaf beyaz yapıyoruz
          contentPadding:
              EdgeInsets.zero, // İçeriğin etrafındaki boşlukları sıfırla
          content: SizedBox(
            width: 200, // Pop-up genişliği
            height: 150, // Pop-up yüksekliği
            child: Center(
              child: Text(
                'Yeni Pop-up', // Boş bir pop-up için basit bir metin
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.black, // Kapat butonunun metin rengi siyah
              ),
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

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white
              .withOpacity(0.5), // Arka plan rengini %50 şeffaf beyaz yapıyoruz
          contentPadding:
              EdgeInsets.zero, // İçeriğin etrafındaki boşlukları sıfırla
          content: SizedBox(
            width: 300, // Pop-up genişliği
            height: 300, // Pop-up yüksekliği
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Başlık kenar boşlukları
                  child: const Text(
                    '1. Makine',
                    style: TextStyle(
                      fontSize: 18, // Başlık font boyutu
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Başlığı ortala
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.red.withOpacity(
                                0.5), // Arka plan rengini kırmızı ve %50 şeffaf yapıyoruz
                            elevation: 0, // Gölgeyi kaldır
                          ).copyWith(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Buton metin rengi siyah
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // İlk pop-up'ı kapat
                            _showErrorPopup(context); // Yeni pop-up'ı aç
                          },
                          child: const Center(
                            child: Text(
                              'Arıza Bildir',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        color: Colors.black, // Siyah çizgi
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.green.withOpacity(
                                0.5), // Arka plan rengini yeşil ve %50 şeffaf yapıyoruz
                            elevation: 0, // Gölgeyi kaldır
                          ).copyWith(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Buton metin rengi siyah
                          ),
                          onPressed: () {
                            // Kontrol Edildi butonuna basıldığında yapılacak işlemler
                            print('Kontrol Edildi butonuna basıldı');
                          },
                          child: const Center(
                            child: Text(
                              'Kontrol Edildi',
                              style: TextStyle(fontSize: 16),
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
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.black, // Kapat butonunun metin rengi siyah
              ),
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _popupShown =
                      false; // Pop-up kapatıldığında gösterim durumunu sıfırla
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
        title: const Text('QR Kodu Tarayıcı'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty
              ? barcodeCapture.barcodes.first
              : null;
          if (barcode != null) {
            final String? scannedCode = barcode.rawValue;
            // Taranan kod ile manuel olarak belirttiğiniz kodu karşılaştırıyoruz
            if (scannedCode != null &&
                scannedCode.trim() == _expectedQRCodeContent) {
              if (!_popupShown) {
                // Pop-up zaten gösterilmiyorsa
                setState(() {
                  _popupShown = true; // Pop-up'ı göstermek için durumu güncelle
                });
                _showPopup(context);
              }
            } else if (scannedCode != null) {
              if (!_popupShown) {
                // Eşleşme yok, sadece "Eşleşme yok" mesajı gösteriliyor
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
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ScanPage(),
  ));
}
