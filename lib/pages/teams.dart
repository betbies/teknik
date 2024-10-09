import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ekipler'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5),
      ),
      backgroundColor: const Color(0xFFFCFBF5),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teams').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var teams = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              var teamData = teams[index].data() as Map<String, dynamic>;
              String teamName = teams[index].id;
              List<String> members =
                  List<String>.from(teamData['members'] ?? []);

              // Kullanıcı adlarını alfabetik sıraya göre sırala
              members.sort();

              return Column(
                children: [
                  _buildTeamTile(context, teamName, members),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamTile(
      BuildContext context, String teamName, List<String> members) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var users = snapshot.data!.docs;
        Map<String, String> memberOccupations = {};

        // Kullanıcıların meslek bilgilerini al
        for (var userDoc in users) {
          var userData = userDoc.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? '';
          String occupation = userData['occupation'] ?? 'Bilinmiyor';
          if (members.contains(userName)) {
            memberOccupations[userName] = occupation;
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFDDDDFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              title: Text(
                teamName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: members.map((member) {
                String occupation = memberOccupations[member] ?? 'Bilinmiyor';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    member,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Text(
                    occupation,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Tüm kullanıcıları ekiplere ekleme fonksiyonu
  Future<void> _addAllUsersToTeams() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final String address = userData['address'] ?? '';
      final String userName = userData['name'] ?? '';

      final team = _getTeamBasedOnAddress(address);

      // Kullanıcıyı ilgili ekibe ekle
      await FirebaseFirestore.instance.collection('teams').doc(team).update({
        'members': FieldValue.arrayUnion([userName]),
      });
    }
  }

  String _getTeamBasedOnAddress(String address) {
    if (address == 'AQI Pegasos Resort Hotel') {
      return 'Resort Teknik Servis Ekibi';
    } else if (address == 'AQI Pegasos Royal Hotel') {
      return 'Royal Teknik Servis Ekibi';
    } else if (address == 'AQI Pegasos Club Hotel') {
      return 'Club Teknik Servis Ekibi';
    } else if (address == 'TUI') {
      return 'Yönetim Ekibi';
    } else {
      return 'Diğer'; // Adres tanımlanmadıysa genel bir ekip
    }
  }
}
