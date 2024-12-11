import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginPage())); // LoginPage yönlendirmesi
  }

  void _showProfileDialog(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF89CFF0),
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'Kullanıcı Adı',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181A18),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData['email'] ?? 'E-posta',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoTile(
                        icon: Icons.phone,
                        title: 'Telefon',
                        value: userData['phone'] ?? 'Telefon',
                      ),
                      const SizedBox(height: 14),
                      _buildInfoTile(
                        icon: Icons.location_on,
                        title: 'Adres',
                        value: userData['address'] ?? 'Adres',
                      ),
                      const SizedBox(height: 14),
                      _buildInfoTile(
                        icon: Icons.date_range,
                        title: 'Doğum Tarihi',
                        value: userData['dob'] ?? 'Doğum Tarihi',
                      ),
                      const SizedBox(height: 14),
                      _buildInfoTile(
                        icon: Icons.work,
                        title: 'Meslek',
                        value: userData['occupation'] ?? 'Meslek',
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _signOut(context); // Çıkış yapma
                          Navigator.of(context).pop(); // Pop-up kapatma
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF6CAEED)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        child: const Text(
                          'ÇIKIŞ YAP',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addUserToTeamIfNotExists(String team) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kullanıcı verilerini al
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userName = userData['name'] ?? '';
      String userAddress = userData['address'] ?? '';

      // Kullanıcının adresine göre takımı belirle
      String teamForUser = _getTeamBasedOnAddress(userAddress);

      if (teamForUser == team) {
        // Ekip dokümanını kontrol et
        DocumentSnapshot teamDoc = await FirebaseFirestore.instance
            .collection('teams')
            .doc(team)
            .get();

        List<String> members = List<String>.from(teamDoc['members'] ?? []);

        // Kullanıcı zaten ekibin üyesi değilse, ekle
        if (!members.contains(userName)) {
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(team)
              .update({
            'members': FieldValue.arrayUnion([userName]),
          });
        }
      }
    }
  }

  // Adrese göre takım belirleme fonksiyonu
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF6CAEED)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181A18),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ekipler'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFBF5),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    _showProfileDialog(context, snapshot.data!);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFF89CFF0),
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

              // Kullanıcının ekibe dahil olup olmadığını kontrol et ve ekle
              _addUserToTeamIfNotExists(teamName);

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
}
