import 'package:flutter/material.dart';
import 'package:gather_app/pages/messages.dart';

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
