import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  _ShiftsPageState createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage> {
  DateTime selectedDate = DateTime.now();
  late int day, month, year;

  @override
  void initState() {
    super.initState();
    day = selectedDate.day;
    month = selectedDate.month;
    year = selectedDate.year;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";
    String formattedTime = "${now.hour}:${now.minute}";

    int currentHour = now.hour;

    bool isShiftA = currentHour >= 8 && currentHour < 16;
    bool isShiftB = currentHour >= 16 && currentHour < 24;
    bool isShiftC = currentHour >= 0 && currentHour < 8;

    List<Widget> shifts;

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
            false,
            "Gece Vardiyası"),
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
            false,
            "Gündüz Vardiyası"),
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
            true,
            "Akşam Vardiyası"),
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
            true,
            false,
            "Gündüz Vardiyası"),
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
            false,
            "Akşam Vardiyası"),
        const SizedBox(height: 16),
        _buildShiftTile(
            'Shift C',
            Icons.nights_stay,
            Colors.deepPurpleAccent,
            'Details about the night shift...',
            false,
            0,
            currentHour,
            false,
            true,
            "Gece Vardiyası"),
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
            false,
            "Akşam Vardiyası"),
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
            false,
            "Gece Vardiyası"),
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
            true,
            "Gündüz Vardiyası"),
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0x00fbfaf5),
      appBar: AppBar(
        title: const Text('Vardiyalar'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            color: const Color(0xFFFCFBF5),
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
          Container(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              color: const Color(0xFFFCFBF5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: day,
                          items: List.generate(31, (index) => index + 1)
                              .map((day) => DropdownMenuItem<int>(
                                    value: day,
                                    child: Text(
                                      day.toString(),
                                      style: const TextStyle(
                                          fontSize: 12), // Smaller font size
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              day = value ?? day;
                            });
                          },
                          hint: const Text(
                            'Gün',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 4), // Reduced space between dropdowns
                      Expanded(
                        child: DropdownButton<int>(
                          value: month,
                          items: List.generate(12, (index) => index + 1)
                              .map((month) => DropdownMenuItem<int>(
                                    value: month,
                                    child: Text(
                                      month.toString(),
                                      style: const TextStyle(
                                          fontSize: 12), // Smaller font size
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              month = value ?? month;
                            });
                          },
                          hint: const Text(
                            'Ay',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 4), // Reduced space between dropdowns
                      Expanded(
                        child: DropdownButton<int>(
                          value: year,
                          items: List.generate(10, (index) => 2024 - index)
                              .map((year) => DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(
                                      year.toString(),
                                      style: const TextStyle(
                                          fontSize: 12), // Smaller font size
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              year = value ?? year;
                            });
                          },
                          hint: const Text(
                            'Yıl',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final selected = DateTime(year, month, day);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4), // Reduced padding
                    textStyle:
                        const TextStyle(fontSize: 12), // Smaller text size
                  ),
                  child: const Text('Tarihe Git'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hoursAgo(int shiftEndHour, int currentHour) {
    // Mevcut saat ve vardiya bitiş saati arasındaki saat farkını hesapla.
    int hoursAgo = (currentHour - shiftEndHour + 24) % 24;
    if (hoursAgo < 0) {
      hoursAgo += 24; // Negatif değerler için düzeltme.
    }
    return (hoursAgo > 0) ? '$hoursAgo saat önce bitti' : '';
  }

  String _hoursUntil(int shiftStartHour, int currentHour) {
    int hoursUntil = (shiftStartHour - currentHour + 24) % 24;
    if (hoursUntil < 0) {
      hoursUntil += 24; // Negatif değerler için düzeltme.
    }

    if (currentHour < shiftStartHour) {
      return '$hoursUntil saat sonra başlayacak';
    } else if (currentHour < shiftStartHour + 8) {
      return 'Devam ediyor';
    } else {
      hoursUntil = (24 - currentHour + shiftStartHour) % 24;
      return '$hoursUntil saat sonra başlayacak';
    }
  }

  Widget _buildShiftTile(
    String title,
    IconData icon,
    Color color,
    String content,
    bool isInitiallyExpanded,
    int shiftHour,
    int currentHour,
    bool isPastShift,
    bool isFutureShift,
    String shiftType,
  ) {
    Color backgroundColor = color.withOpacity(0.5);

    String statusText;
    if (isPastShift) {
      statusText = _hoursAgo(shiftHour + 8, currentHour); // Bitmiş shift için
    } else if (isFutureShift) {
      statusText = _hoursUntil(shiftHour, currentHour); // Başlayacak shift için
    } else {
      statusText = 'Devam ediyor'; // Aktif shift için
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 4),
              Text(
                shiftType,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
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
