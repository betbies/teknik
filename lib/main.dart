import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/teams.dart';
import 'pages/shifts.dart';
import 'pages/scan.dart';
import 'pages/malfunction.dart';
import 'pages/profile.dart';

void main() {
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
          primary: const Color(0xFF6CAEED), // Primary color for the app
          secondary: const Color(0xFF89CFF0), // Secondary color for the app
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFBFAF5), // Background color of AppBar
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF181A18), // Text color in AppBar
            fontSize: 14, // Font size of the title
          ),
          toolbarHeight: 20, // Height of the AppBar
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:
              Color(0xFFFCFBF5), // Background color of BottomNavigationBar
          selectedItemColor: Color(0xFF6CAEED), // Color of selected item
          unselectedItemColor: Color(0xFFBDE0FE), // Color of unselected items
        ),
        scaffoldBackgroundColor:
            const Color(0xFFFCFBF5), // Background color of the Scaffold
        cardColor: const Color(0xFFDDEEFA), // Background color of cards
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Başlangıç olarak 'Scan' sayfası seçili olacak.

  final List<Widget> _pages = <Widget>[
    const TeamsPage(),
    const ShiftsPage(),
    const ScanPage(),
    const MalfunctionPage(),
    const ProfilePage(),
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
        title: const Text('TEKNİK'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        items: const <Widget>[
          Icon(Icons.group, size: 30, color: Colors.white), // Ekipler
          Icon(Icons.access_time, size: 30, color: Colors.white), // Vardiyalar
          Icon(Icons.qr_code_scanner, size: 30, color: Colors.white), // Scan
          Icon(Icons.warning, size: 30, color: Colors.white), // Arızalar
          Icon(Icons.person, size: 30, color: Colors.white), // Profil
        ],
        color: const Color(0xFF181A18), // Color of the navigation bar
        buttonBackgroundColor: const Color(0xFF6CAEED), // Color of the button
        backgroundColor:
            const Color(0xFFFBFAF5), // Background color of the navigation bar
        onTap: _onItemTapped,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        letIndexChange: (index) => true,
      ),
    );
  }
}
