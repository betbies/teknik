import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore eklendi
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication eklendi

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Kullanıcı verilerini Firestore'dan alma fonksiyonu
  Future<Map<String, dynamic>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Şu anki kullanıcıyı al
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(); // Kullanıcı verilerini Firestore'dan çek
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  // Adrese göre ekibe kullanıcıyı ekleme fonksiyonu
  Future<void> _addUserToTeams() async {
    // Kullanıcı verilerini al
    final QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Kullanıcı adlarını tutacak bir liste oluştur
    List<String> userNames = [];

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data() as Map<String, dynamic>;
      String address = userData['address'] ?? '';
      String userName = userData['name'] ?? '';

      String team = _getTeamBasedOnAddress(address);

      // Kullanıcı adını listeye ekle
      userNames.add(userName);

      // Firestore'daki 'teams' koleksiyonunda ilgili ekibe kullanıcıyı ekle
      await FirebaseFirestore.instance.collection('teams').doc(team).update({
        'members': FieldValue.arrayUnion([userName]),
      });
    }

    // Kullanıcı adlarını alfabetik sıraya göre sırala
    userNames.sort();

    // Sıralanmış kullanıcı adlarını istediğiniz gibi kullanabilirsiniz.
    // Örneğin, kullanıcı adlarını bir liste olarak döndürebilirsiniz.
    print("Sıralanmış Kullanıcı Adları: $userNames");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri tuşunu kaldırır
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFAF5),
        elevation: 0, // Düz bir AppBar tasarımı için gölgeyi kaldırıyoruz
      ),
      backgroundColor: const Color(0xFFFCFBF5), // Arka plan rengi
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(), // Kullanıcı verilerini çek
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // Veriler yükleniyor
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // Hata durumu
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child:
                        Text('No user data found.')); // Kullanıcı verisi yoksa
              }

              final userData = snapshot.data!;

              // Tüm kullanıcıları ekiplere ekleme işlemi
              _addUserToTeams();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFDDEEFA), // Daha hafif bir arka plan rengi
                      borderRadius:
                          BorderRadius.circular(30.0), // Daha yuvarlak köşeler
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF181A18)
                              .withOpacity(0.2), // Gölgede tema rengi
                          blurRadius: 12.0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF89CFF0), // Tema mavi renk
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name'] ?? '', // Kullanıcı adı
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181A18),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData['email'] ?? '', // Kullanıcı e-posta
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoTile(
                          icon: Icons.phone,
                          title: 'Telefon',
                          value: userData['phone'] ?? '', // Telefon numarası
                        ),
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          icon: Icons.location_on,
                          title: 'Adres',
                          value: userData['address'] ?? '', // Adres
                        ),
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          icon: Icons.date_range,
                          title: 'Doğum Tarihi',
                          value: userData['dob'] ?? '', // Doğum tarihi
                        ),
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          icon: Icons.work,
                          title: 'Meslek',
                          value: userData['occupation'] ?? '', // Meslek
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF6CAEED)), // Tema rengi
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
                  color: Color(0xFF181A18), // Koyu tema rengi
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
}
