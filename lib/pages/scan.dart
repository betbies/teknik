import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketini ekliyoruz
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final String _expectedQRCodeContent =
      'https://www.tthotels.com/en/hotel/aqi-pegasos-resort/b/isitmakazani1'; // Buraya gerçek QR kod içeriğini ekleyin
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
          actionsPadding: const EdgeInsets.only(
              bottom: 4), // Alt boşluk oranını azaltıyoruz
          content: const SizedBox(
            width: 200, // Bu genişliği ihtiyaca göre ayarlayabilirsiniz
            height: 150, // Bu yüksekliği ihtiyaca göre ayarlayabilirsiniz
            child: Center(
              child: Text(
                'Arızayı yazınız...', // Boş bir pop-up için basit bir metin
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
          actionsPadding: const EdgeInsets.only(
              bottom: 4), // Alt boşluk oranını azaltıyoruz
          content: SizedBox(
            width: MediaQuery.of(context).size.width -
                32, // Kamera alanının genişliği
            height: MediaQuery.of(context).size.height *
                0.5, // Kamera alanının yüksekliği
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Başlık kenar boşlukları
                  child: const Text(
                    'ISITMA KAZANI 1',
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
                            shape:
                                const BeveledRectangleBorder(), // Yuvarlamayı kaldırdık
                            backgroundColor: Colors.red
                                .withOpacity(0.5), // Arka plan kırmızı
                            elevation: 0, // Gölgeyi kaldır
                          ).copyWith(
                            foregroundColor: WidgetStateProperty.all(
                                Colors.black), // Buton metin rengi siyah
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // İlk pop-up'ı kapat
                            _showErrorPopup(context); // Yeni pop-up'ı aç
                          },
                          child: Center(
                            child: Text(
                              'ARIZA BİLDİR',
                              style: GoogleFonts.tourney(
                                fontSize: 26, // Daha büyük font boyutu
                                fontWeight: FontWeight.w700, // Orta kalınlıkta
                                color: Colors.black, // Yazı rengi siyah
                              ),
                              textAlign: TextAlign.center, // Metni ortala
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
                            shape:
                                const BeveledRectangleBorder(), // Yuvarlamayı kaldırdık
                            backgroundColor: Colors.green
                                .withOpacity(0.5), // Arka plan yeşil
                            elevation: 0, // Gölgeyi kaldır
                          ).copyWith(
                            foregroundColor: WidgetStateProperty.all(
                                Colors.black), // Buton metin rengi siyah
                          ),
                          onPressed: () {
                            // Kontrol Edildi butonuna basıldığında artık hiçbir işlem yapmıyor
                          },
                          child: Center(
                            child: Text(
                              'KONTROL EDİLDİ',
                              style: GoogleFonts.tourney(
                                fontSize: 26, // Daha büyük font boyutu
                                fontWeight: FontWeight.w700, // Orta kalınlıkta
                                color: Colors.black, // Yazı rengi siyah
                              ),
                              textAlign: TextAlign.center, // Metni ortala
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
        automaticallyImplyLeading: false, // Geri tuşunu kaldırır
        title: const Text('QR Kod Tarayıcı'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(
              16.0), // Kamera çerçevesinin etrafındaki boşluk
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                16.0), // Kamera çerçevesinin köşelerini yuvarlama
            child: MobileScanner(
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
                        _popupShown =
                            true; // Pop-up'ı göstermek için durumu güncelle
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
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ScanPage(),
  ));
}
