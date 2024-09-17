import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // PNG'den çözümlenmiş QR kod içeriğini düz metin olarak buraya girin
  final String _expectedQRCodeContent =
      'https://www.tthotels.com/tr'; // Buraya gerçek QR kod içeriğini ekleyin

  bool _popupShown =
      false; // Pop-up'ın gösterilip gösterilmediğini takip eden değişken

  // Eşleşme olduğunda pop-up açmak için bu fonksiyon kullanılıyor
  void _showPopup(BuildContext context, String scannedCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Kodu Tanındı'),
          content: Text('QR kodu başarıyla tanındı: $scannedCode'),
          actions: [
            TextButton(
              child: const Text('Tamam'),
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
                _showPopup(context, scannedCode);
              }
            } else if (scannedCode != null) {
              if (!_popupShown) {
                // Pop-up zaten gösterilmiyorsa
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Eşleşme yok! Taranan QR kodu: $scannedCode'),
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
