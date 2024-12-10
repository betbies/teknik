import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Kullanıcı verilerini Firestore'dan alma fonksiyonu
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

  // Çıkış yapma fonksiyonu
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginPage())); // LoginPage yönlendirmesi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFAF5),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFCFBF5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No user data found.'));
            }

            final userData = snapshot.data!;

            return Stack(
              children: [
                Center(
                  child: Container(), // Ekran ortası boş kaldı
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Profil resmine tıklandığında pop-up açma
                      _showProfileDialog(context, userData);
                    },
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF89CFF0),
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Profil detaylarını içeren pop-up
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
                      // Profil Resmi
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
                      // Kullanıcı Adı
                      Text(
                        userData['name'] ?? 'Kullanıcı Adı',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181A18),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Kullanıcı E-postası
                      Text(
                        userData['email'] ?? 'E-posta',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bilgiler
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
                      // Çıkış Yap Butonu
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
                        Navigator.of(context).pop(); // Pop-up kapama
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
}
