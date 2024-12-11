import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/teams.dart';
import 'pages/shifts.dart';
import 'pages/scan.dart';
import 'pages/malfunction.dart';
import 'pages/machines.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6CAEED),
          primary: const Color(0xFF6CAEED),
          secondary: const Color(0xFF89CFF0),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFBFAF5),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF181A18),
            fontSize: 14,
          ),
          toolbarHeight: 20,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFCFBF5),
          selectedItemColor: Color(0xFF6CAEED),
          unselectedItemColor: Color(0xFFBDE0FE),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCFBF5),
        cardColor: const Color(0xFFDDEEFA),
      ),
      home: const RootPage(), // İlk sayfa RootPage olacak
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = <Widget>[
    const TeamsPage(),
    const ShiftsPage(),
    const ScanPage(),
    const MalfunctionPage(),
    const MachinePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('TEKNİK'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        items: const <Widget>[
          Icon(Icons.group, size: 30, color: Colors.white),
          Icon(Icons.access_time, size: 30, color: Colors.white),
          Icon(Icons.qr_code_scanner, size: 30, color: Colors.white),
          Icon(Icons.warning, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: const Color(0xFF181A18),
        buttonBackgroundColor: const Color(0xFF6CAEED),
        backgroundColor: const Color(0xFFFBFAF5),
        onTap: _onItemTapped,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        letIndexChange: (index) => true,
      ),
    );
  }
}
