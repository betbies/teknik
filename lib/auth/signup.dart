import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; // LoginPage'i içe aktar

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Telefon numarası için kontrolör

  String? _selectedDob; // Doğum tarihi için değişken
  String? _selectedAddress;
  String? _selectedOccupation;

  bool _isRegistering = false; // Kayıt işlemi durumu

  Future<void> _registerUser() async {
    if (_isRegistering) return; // Kayıt işlemi devam ediyorsa çık

    setState(() {
      _isRegistering = true; // Kayıt işlemi başladı
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı bilgilerini Firestore'a kaydet
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(), // Telefon numarasını kaydet
        'dob': _selectedDob, // Doğum tarihini kaydet
        'address': _selectedAddress,
        'occupation': _selectedOccupation,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Kayıt başarılı olunca bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı!')),
      );

      // Kayıt başarılı olunca giriş sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Hata durumunda mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isRegistering = false; // Kayıt işlemi tamamlandı
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDob =
            "${picked.day}/${picked.month}/${picked.year}"; // Gün/Ay/Yıl formatı
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6CAEED),
        title: const Text('Kayıt', style: TextStyle(color: Color(0xFFFBFAF5))),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181A18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      labelStyle: TextStyle(color: Color(0xFF181A18)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF6CAEED)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFDDEEFA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF181A18)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF6CAEED)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFDDEEFA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: TextStyle(color: Color(0xFF181A18)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF6CAEED)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFDDEEFA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller:
                        _phoneController, // Telefon numarası için TextField
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      labelStyle: TextStyle(color: Color(0xFF181A18)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF6CAEED)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFDDEEFA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Doğum tarihi seçimi için buton
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        labelStyle: TextStyle(color: Color(0xFF181A18)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF6CAEED)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFDDEEFA)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          _selectedDob ?? 'Doğum tarihinizi seçin',
                          style: const TextStyle(color: Color(0xFF181A18)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Adres Seçimi DropdownButton
                  DropdownButtonFormField<String>(
                    value: _selectedAddress,
                    hint: const Text('Adres'),
                    items: [
                      'AQI Pegasos Resort Hotel',
                      'AQI Pegasos Royal Hotel',
                      'AQI Pegasos Club Hotel',
                      'TUI'
                    ]
                        .map((address) => DropdownMenuItem<String>(
                              value: address,
                              child: Text(address),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meslek Seçimi DropdownButton
                  DropdownButtonFormField<String>(
                    value: _selectedOccupation,
                    hint: const Text('Meslek'),
                    items: [
                      'Elektrikçi',
                      'Tesisatçı',
                      'Boyacı',
                      'Marangoz',
                      'Vardiya Amiri',
                      'Şef',
                      'Asistan',
                      'Müdür',
                      'Yönetici'
                    ]
                        .map((occupation) => DropdownMenuItem<String>(
                              value: occupation,
                              child: Text(occupation),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOccupation = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF6CAEED), // primary yerine backgroundColor
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isRegistering
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                                color:
                                    Colors.white), // Yazı rengini beyaz yapıldı
                          ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Zaten bir hesabınız var mı?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text('Giriş Yapın.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
