import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore'u kullanabilmek için ekliyoruz.

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  _ShiftsPageState createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage> {
  DateTime selectedDate = DateTime.now();
  late int day, month, year;

  // Firestore'dan kontrol bilgilerini almak için bir liste
  List<Map<String, dynamic>> checkedRecords = [];

  @override
  void initState() {
    super.initState();
    day = selectedDate.day;
    month = selectedDate.month;
    year = selectedDate.year;
    fetchCheckedRecords(); // Kontrol kayıtlarını al
  }

  void _showDateDetails(DateTime selectedDate) {
    String formattedDate =
        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";

    // Filter records by selected date
    List<Map<String, dynamic>> filteredRecords = checkedRecords.where((record) {
      DateTime timestamp = (record['timestamp'] as Timestamp).toDate();
      return timestamp.year == selectedDate.year &&
          timestamp.month == selectedDate.month &&
          timestamp.day == selectedDate.day;
    }).toList();

    // Create lists for each shift
    Map<String, List<Map<String, dynamic>>> shiftC = {};
    Map<String, List<Map<String, dynamic>>> shiftA = {};
    Map<String, List<Map<String, dynamic>>> shiftB = {};

    // Group records by shift and machine name
    filteredRecords.forEach((record) {
      DateTime timestamp = (record['timestamp'] as Timestamp).toDate();
      String machineName = record['machine_name'];
      String userName = record['user_name'];
      String formattedHour = timestamp.hour.toString().padLeft(2, '0');
      String formattedMinute = timestamp.minute.toString().padLeft(2, '0');
      String time = "$formattedHour:$formattedMinute";

      if (timestamp.hour >= 0 && timestamp.hour < 8) {
        shiftC[machineName] = (shiftC[machineName] ?? [])
          ..add({'user_name': userName, 'time': time});
      } else if (timestamp.hour >= 8 && timestamp.hour < 16) {
        shiftA[machineName] = (shiftA[machineName] ?? [])
          ..add({'user_name': userName, 'time': time});
      } else if (timestamp.hour >= 16 && timestamp.hour < 24) {
        shiftB[machineName] = (shiftB[machineName] ?? [])
          ..add({'user_name': userName, 'time': time});
      }
    });

    // Create details widget for shifts
    List<Widget> detailsWidgets = [];

    void appendShiftDetails(String shiftName, Color color,
        Map<String, List<Map<String, dynamic>>> shiftData) {
      if (shiftData.isNotEmpty) {
        detailsWidgets.add(
          Text(
            shiftName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        );
        shiftData.forEach((machineName, records) {
          detailsWidgets.add(Text(
            machineName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ));
          records.forEach((record) {
            detailsWidgets.add(Text(
              "${record['user_name']} - ${record['time']}",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ));
          });
          detailsWidgets
              .add(Divider(color: Colors.grey)); // Divider for each machine
        });
      }
    }

    // Append each shift's details in C, A, B order
    appendShiftDetails("Shift C", Colors.red, shiftC);
    appendShiftDetails("Shift A", Colors.green, shiftA);
    appendShiftDetails("Shift B", Colors.blue, shiftB);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            width: 350,
            height: 500,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Divider(color: Colors.grey), // Divider between date and content
                SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: detailsWidgets.isEmpty
                        ? Center(
                            child: Text('No data available for this date.'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: detailsWidgets,
                          ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiftColumn(String shiftName, List<String> shiftDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shiftName,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        ),
        SizedBox(height: 8),
        ...shiftDetails.map((detail) {
          var parts = detail.split('\n');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parts[0], // Machine Name
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${parts[1]}', // User and Time
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        Divider(color: Colors.grey), // Divider between shifts
      ],
    );
  }

  Future<void> fetchCheckedRecords() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('checked').get();

    setState(() {
      checkedRecords = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList()
        ..sort((a, b) {
          DateTime aTimestamp = (a['timestamp'] as Timestamp).toDate();
          DateTime bTimestamp = (b['timestamp'] as Timestamp).toDate();
          return aTimestamp.compareTo(bTimestamp);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";
    String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

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
            _getShiftCheckDetails('C'), // Makine ve kullanıcı bilgilerini ekle
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
            _getShiftCheckDetails('A'), // Makine ve kullanıcı bilgilerini ekle
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
            _getShiftCheckDetails('B'), // Makine ve kullanıcı bilgilerini ekle
            false,
            16,
            currentHour,
            false,
            true,
            "Akşam Vardiyası"),
      ];
    } else if (isShiftB) {
      DateTime nextDay =
          now.add(const Duration(days: 1)); // Sonraki günün tarihi

      shifts = [
        _buildShiftTile(
            'Shift A',
            Icons.wb_sunny,
            Colors.orangeAccent,
            _getShiftCheckDetails('A'), // Makine ve kullanıcı bilgilerini ekle
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
            _getShiftCheckDetails('B'), // Makine ve kullanıcı bilgilerini ekle
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
            _getShiftCheckDetails('C', nextDay), // Gece vardiyası için yeni gün
            false,
            0,
            currentHour,
            false,
            true,
            "Gece Vardiyası"),
      ];
    } else {
      DateTime previousDay =
          now.subtract(const Duration(days: 1)); // Bir önceki günün tarihi

      shifts = [
        _buildShiftTile(
            'Shift B',
            Icons.cloud,
            Colors.blueAccent,
            _getShiftCheckDetails(
                'B', previousDay), // Bir önceki günün vardiyası
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
            _getShiftCheckDetails('C'), // Mevcut günün gece vardiyası
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
            _getShiftCheckDetails('A'), // Mevcut günün gündüz vardiyası
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
        automaticallyImplyLeading: false, // Geri tuşunu kaldırır
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
                    _showDateDetails(
                        selected); // Call the new function to show the details
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
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

  String _getShiftCheckDetails(String shift, [DateTime? specificDate]) {
    String details = '';
    DateTime now = specificDate ??
        DateTime.now(); // Eğer belirli bir tarih varsa onu kullan

    Map<String, List<Map<String, dynamic>>> machineGroup =
        {}; // Makine adı ile kullanıcıları grupla

    for (var record in checkedRecords) {
      DateTime timestamp = (record['timestamp'] as Timestamp).toDate();
      String machineName = record['machine_name'];
      String userName = record['user_name'];

      // Aynı gün veya belirli gün için kontrol kayıtlarını al
      if (timestamp.year == now.year &&
          timestamp.month == now.month &&
          timestamp.day == now.day) {
        if ((shift == 'A' && timestamp.hour >= 8 && timestamp.hour < 16) ||
            (shift == 'B' && timestamp.hour >= 16 && timestamp.hour < 24) ||
            (shift == 'C' && timestamp.hour < 8 && timestamp.hour >= 0)) {
          // Eğer bu makine daha önce kontrol edildiyse, kullanıcı ve zaman bilgilerini ekle
          if (machineGroup.containsKey(machineName)) {
            machineGroup[machineName]!.add({
              'userName': userName,
              'timestamp': timestamp,
            });
          } else {
            // İlk defa kontrol edilen makineyi gruba ekle
            machineGroup[machineName] = [
              {
                'userName': userName,
                'timestamp': timestamp,
              }
            ];
          }
        }
      }
    }

    // Her makine için bilgileri topla
    machineGroup.forEach((machineName, records) {
      details += "$machineName\n"; // Makine adını bir kez yaz

      // Kontrol eden kullanıcıları ve zamanları alt alta ekle
      for (var record in records) {
        details +=
            "${record['userName']} - ${record['timestamp'].hour.toString().padLeft(2, '0')}:${record['timestamp'].minute.toString().padLeft(2, '0')}\n";
      }

      details += "----------\n"; // Kayıtlar arasında çizgi ekle
    });

    return details.isEmpty ? 'Henüz kontrol edilmedi.' : details.trim();
  }

  String _hoursAgo(int shiftEndHour, int currentHour) {
    // Mevcut saat ve vardiya bitiş saati arasındaki saat farkını hesapla.
    int hoursAgo = (currentHour - shiftEndHour + 24) % 24;
    if (hoursAgo < 0) {
      hoursAgo += 24; // Negatif değerler için düzeltme.
    }
    if (hoursAgo == 0) {
      return 'Biraz önce bitti';
    }
    return (hoursAgo > 0) ? '$hoursAgo saat önce bitti' : '';
  }

  String _hoursUntil(int shiftStartHour, int currentHour) {
    int hoursUntil = (shiftStartHour - currentHour + 24) % 24;
    if (hoursUntil < 0) {
      hoursUntil += 24; // Negatif değerler için düzeltme.
    }

    if (currentHour < shiftStartHour) {
      if (hoursUntil == 0) {
        return 'Biraz sonra başlayacak';
      }
      return '$hoursUntil saat sonra başlayacak';
    } else if (currentHour < shiftStartHour + 8) {
      return 'Devam ediyor';
    } else {
      hoursUntil = (24 - currentHour + shiftStartHour) % 24;
      if (hoursUntil == 0) {
        return 'Biraz sonra başlayacak';
      }
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
              child: Text(content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
