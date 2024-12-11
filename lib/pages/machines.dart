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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: machines.length,
                      itemBuilder: (context, machineIndex) {
                        var machine = machines[machineIndex];
                        String machineName =
                            machine['machineName'] ?? 'Bilinmiyor';

                        return _buildMachineEntry(
                          context,
                          machine: machineName,
                        );
                      },
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          machine,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
