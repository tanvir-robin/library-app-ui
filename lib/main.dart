import 'package:elmouaddibe_examen/auth/utils/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/route_manager.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'books_screen.dart';
import 'members_screen.dart';
import 'about_screen.dart';
import 'chatbot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BooksScreen(),
    MembersScreen(),
    chatbotScreen(),
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              accountName: Text(
                'PSTU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              accountEmail: Text(
                'Public Library',
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/library.png'),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(FirebaseAuth
                          .instance.currentUser?.photoURL ??
                      'https://miro.medium.com/v2/resize:fit:600/format:webp/1*PiHoomzwh9Plr9_GA26JcA.png')),
              title: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
                style: TextStyle(fontSize: 15),
              ),
              subtitle: const Text(
                'Administrator',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Home'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Book'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Members'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Chatbot'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('About'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
