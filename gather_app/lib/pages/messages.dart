import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedUser;

  void _sendMessage() async {
    if (_controller.text.isNotEmpty && _selectedUser != null) {
      try {
        await _firestore.collection('messages').add({
          'text': _controller.text,
          'sender': _auth.currentUser?.email,
          'receiver': _selectedUser,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _controller.clear();
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final users = snapshot.data!.docs;
              if (users.isEmpty) {
                return const Center(
                  child: Text('No users found'),
                );
              }

              List<DropdownMenuItem<String>> userItems = users.map((user) {
                final userEmail = user['email'];
                return DropdownMenuItem<String>(
                  value: userEmail,
                  child: Text(userEmail),
                );
              }).toList();

              return DropdownButton<String>(
                hint: const Text('Select a user'),
                value: _selectedUser,
                items: userItems,
                onChanged: (value) {
                  setState(() {
                    _selectedUser = value;
                  });
                },
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('sender', isEqualTo: _auth.currentUser?.email)
                  .where('receiver', isEqualTo: _selectedUser)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;

                List<Widget> messageWidgets = messages.map((message) {
                  final messageText = message['text'];
                  final messageSender = message['sender'];

                  return ListTile(
                    title: Text(messageSender),
                    subtitle: Text(messageText),
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
