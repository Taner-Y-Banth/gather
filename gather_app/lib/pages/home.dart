import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:gather_app/pages/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({
    super.key,
    required this.title,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  void logout() async {
    // logout firebase user
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GATHER',
          style: TextStyle(
            color: Color.fromARGB(255, 63, 61, 61),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 229, 200, 200),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    avatarShape: const CircleBorder(side: BorderSide.none),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 200),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle),
            label: 'Circles',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
      ),
      body: <Widget>[
        Container(
          color: Colors.lightBlue,
          alignment: Alignment.center,
          child: const Text('HOME'),
        ),
        const Messages(),
        Container(
          color: Colors.pink,
          alignment: Alignment.center,
          child: const Text('CIRCLES'),
        ),
        Container(
          color: Colors.purple,
          alignment: Alignment.center,
          child: const Text('NOTIFS'),
        ),
      ][currentPageIndex],
    );
  }
}
