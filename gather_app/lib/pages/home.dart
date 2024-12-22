import 'package:flutter/material.dart';
import 'package:gather_app/pages/profile/profile.dart';
import 'package:gather_app/pages/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gather_app/pages/friends/add_friends.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({
    super.key,
    required this.title,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  void logout() async {
    // logout firebase user
    await FirebaseAuth.instance.signOut();
  }

  void showAddFriendsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          child: AddFriendsPage(),
        );
      },
    );
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
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: FloatingActionButton(
          onPressed: showAddFriendsPopup,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 50,
        notchMargin: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                setState(() {
                  currentPageIndex = 1;
                });
              },
            ),
            const SizedBox(width: 40), // The FAB is in the middle
            IconButton(
              icon: const Icon(Icons.circle),
              onPressed: () {
                setState(() {
                  currentPageIndex = 2;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {
                setState(() {
                  currentPageIndex = 3;
                });
              },
            ),
          ],
        ),
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

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        30; // Adjust the value to lower the FAB
    return Offset(fabX, fabY);
  }
}
