import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MachinePage extends StatelessWidget {
  const MachinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Makineler',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFCFBF5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('machines').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var machineDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: machineDocs.length,
              itemBuilder: (context, index) {
                var machineData =
                    machineDocs[index].data() as Map<String, dynamic>;
                String documentName =
                    machineDocs[index].id; // club, royal, resort
                List<dynamic> machines = machineData['machines'] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        documentName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ExpansionTile(
                      title: Text(
                        'Makineler',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      children: List.generate(machines.length, (machineIndex) {
                        var machine = machines[machineIndex];
                        String machineName =
                            machine['machineName'] ?? 'Bilinmiyor';

                        return _buildMachineEntry(
                          context,
                          machine: machineName,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMachineEntry(
    BuildContext context, {
    required String machine,
  }) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('checked')
          .where('machine_name', isEqualTo: machine)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        bool isChecked = false;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          isChecked = true; // Makine kontrol edilmiş
        }

        return GestureDetector(
          onTap: () => _showMachineDetails(context, machine),
          child: Container(
            height: 60.0, // Sabit yükseklik
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: isChecked
                  ? Colors.green.withOpacity(0.5) // Kontrol edilmişse yeşil
                  : Colors.grey[200], // Kontrol edilmemişse gri
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                machine,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMachineDetails(
      BuildContext context, String machineName) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('checked')
          .where('machine_name', isEqualTo: machineName)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var checkedDoc =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        var timestamp = checkedDoc['timestamp']?.toDate();
        var userName = checkedDoc['user_name'] ?? 'Bilinmiyor';

        // Saat ve dakika formatlama
        String formattedHour =
            timestamp?.hour.toString().padLeft(2, '0') ?? '00';
        String formattedMinute =
            timestamp?.minute.toString().padLeft(2, '0') ?? '00';
        String time = "$formattedHour:$formattedMinute";

        // Detayları gösteren bir dialog açıyoruz
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text(machineName)),
              content: SizedBox(
                width: 300, // Sabit genişlik
                height: 150, // Sabit yükseklik
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'En Son Kontrol:\n${timestamp != null ? '${timestamp.toLocal()}'.split(' ')[0] : 'Bilinmiyor'} $time\n$userName',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text('Makine: $machineName')),
              content: SizedBox(
                width: 300, // Sabit genişlik
                height: 100, // Sabit yükseklik
                child: Center(
                  child:
                      const Text('Bu makine hakkında bilgi bulunmamaktadır.'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error fetching machine details: $e");
    }
  }
}
