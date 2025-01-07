import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
                      title: const Text(
                        'Makineler',
                        style: TextStyle(
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

  void _closeAllPopups(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
  }

  Future<void> _showMachineDetails(
      BuildContext context, String machineName) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('error')
          .where('machine_name', isEqualTo: machineName)
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text(machineName)),
              content: SizedBox(
                width: 300, // Sabit genişlik
                height: 350, // Sabit yükseklik
                child: ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, index) {
                    var errorDoc = querySnapshot.docs[index].data();

                    var error = errorDoc['error'] ?? 'Bilinmiyor';
                    var imageUrl = errorDoc['image_url'] ?? '';
                    var timestamp = errorDoc['timestamp']?.toDate();
                    var formattedTimestamp = timestamp != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
                        : 'Bilinmiyor';
                    var userName = errorDoc['user_name'] ?? 'Bilinmiyor';

                    var completedAt = errorDoc['completed_at']?.toDate();
                    var formattedCompletedAt = completedAt != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(completedAt)
                        : 'Tamamlanmadı';
                    var completedBy = errorDoc['completed_by'] ?? '-';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$error',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          if (imageUrl.isNotEmpty)
                            Center(
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('Görsel yüklenemedi');
                                },
                              ),
                            ),
                          const SizedBox(height: 8.0),
                          Text('Arıza Tarihi: $formattedTimestamp'),
                          Text('Arızayı Bildiren: $userName'),
                          const SizedBox(height: 8.0),
                          Text(
                              'Arızanın Tamamlanma Tarihi: $formattedCompletedAt'),
                          Text('Arızayı Tamamlayan: $completedBy'),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _closeAllPopups(context); // Tüm pop-up'ları kapat
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
              title: Center(child: Text(machineName)),
              content: const SizedBox(
                width: 300, // Sabit genişlik
                height: 100, // Sabit yükseklik
                child: Center(
                  child:
                      Text('Bu makine hakkında arıza kaydı bulunmamaktadır.'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _closeAllPopups(context); // Tüm pop-up'ları kapat
                  },
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error fetching machine errors: $e");
    }
  }
}
