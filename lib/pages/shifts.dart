import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiftsPage extends StatelessWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";
    String formattedTime = "${now.hour}:${now.minute}";

    int currentHour = now.hour;

    // Shift'in otomatik olarak genişletilmesi için kontrol
    bool isShiftA = currentHour >= 8 && currentHour < 16;
    bool isShiftB = currentHour >= 16 && currentHour < 24;
    bool isShiftC = currentHour >= 0 && currentHour < 8;

    List<Widget> shifts;

    // Şu anki vardiyaya göre sıralamayı belirliyoruz
    if (isShiftA) {
      shifts = [
        _buildShiftTile(
            'Shift C',
            Icons.nights_stay,
            Colors.deepPurpleAccent,
            'Details about the night shift...',
            false,
            0,
            currentHour,
            true,
            false),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift A',
            Icons.wb_sunny,
            Colors.orangeAccent,
            'Details about the morning shift...',
            true,
            8,
            currentHour,
            false,
            false),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift B',
            Icons.cloud,
            Colors.blueAccent,
            'Details about the evening shift...',
            false,
            16,
            currentHour,
            false,
            true),
      ];
    } else if (isShiftB) {
      shifts = [
        _buildShiftTile(
            'Shift A',
            Icons.wb_sunny,
            Colors.orangeAccent,
            'Details about the morning shift...',
            false,
            8,
            currentHour,
            false,
            true),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift B',
            Icons.cloud,
            Colors.blueAccent,
            'Details about the evening shift...',
            true,
            16,
            currentHour,
            false,
            false),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift C',
            Icons.nights_stay,
            Colors.deepPurpleAccent,
            'Details about the night shift...',
            false,
            0,
            currentHour,
            true,
            false),
      ];
    } else {
      shifts = [
        _buildShiftTile(
            'Shift B',
            Icons.cloud,
            Colors.blueAccent,
            'Details about the evening shift...',
            false,
            16,
            currentHour,
            true,
            false),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift C',
            Icons.nights_stay,
            Colors.deepPurpleAccent,
            'Details about the night shift...',
            true,
            0,
            currentHour,
            false,
            false),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift A',
            Icons.wb_sunny,
            Colors.orangeAccent,
            'Details about the morning shift...',
            false,
            8,
            currentHour,
            false,
            true),
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0x00fbfaf5),
      appBar: AppBar(
        title: const Text('Vardiyalar'), // Üst bar başlığı
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5), // İstediğiniz renk
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFCFBF5), // Arka plan rengi
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: GoogleFonts.anta(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    formattedTime,
                    style: GoogleFonts.anta(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: shifts,
            ),
          ),
        ],
      ),
    );
  }

  // Vardiyanın kaç saat önce bittiğini hesaplayan fonksiyon
  String _hoursAgo(int shiftEndHour, int currentHour) {
    if (currentHour < shiftEndHour) {
      return ''; // Henüz bitmemiş vardiya için boş dön.
    } else {
      int hoursAgo = currentHour - shiftEndHour;
      return '$hoursAgo saat önce bitti';
    }
  }

  // Vardiyanın kaç saat sonra başlayacağını hesaplayan fonksiyon
  String _hoursUntil(int shiftStartHour, int currentHour) {
    if (currentHour >= shiftStartHour && currentHour < (shiftStartHour + 8)) {
      return ''; // Vardiya devam ediyorsa boş döner.
    } else if (currentHour >= (shiftStartHour + 8)) {
      return ''; // Vardiya bitmişse boş döner.
    } else {
      int hoursUntil = shiftStartHour - currentHour;
      return '$hoursUntil saat sonra başlayacak';
    }
  }

  Widget _buildShiftTile(
    String title,
    IconData icon,
    Color color,
    String content,
    bool isInitiallyExpanded,
    int shiftHour, // Vardiyanın başlangıç saati
    int currentHour, // Şu anki saat
    bool isPastShift, // Vardiya bitti mi?
    bool isFutureShift, // Vardiya henüz başlamadı mı?
  ) {
    // Arka plan renginin opaklığını yarıya düşür
    Color backgroundColor = color.withOpacity(0.5);

    String statusText;
    if (isPastShift) {
      statusText = _hoursAgo(shiftHour + 8, currentHour); // Vardiya bitiş saati
    } else if (isFutureShift) {
      statusText = _hoursUntil(shiftHour, currentHour);
    } else {
      statusText = 'Devam ediyor';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, backgroundColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // İkon ve metin arasındaki boşluğu ayarlama
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              // Kutu kapalıyken durum bilgisini gösteriyoruz
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          initiallyExpanded: isInitiallyExpanded,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
