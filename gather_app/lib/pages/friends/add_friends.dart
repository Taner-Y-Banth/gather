import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest() async {
    User? user = auth.currentUser;
    if (user != null) {
      if (emailController.text == user.email) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You cannot send a friend request to yourself')),
        );
        return;
      }

      final request = {
        'from': user.email,
        'to': emailController.text,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('sent_requests')
          .add(request);

      final recipientSnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: emailController.text)
          .get();

      if (recipientSnapshot.docs.isNotEmpty) {
        final recipientId = recipientSnapshot.docs.first.id;
        await firestore
            .collection('users')
            .doc(recipientId)
            .collection('received_requests')
            .add(request);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
    }
  }

  Future<void> acceptFriendRequest(DocumentSnapshot request) async {
    User? user = auth.currentUser;
    if (user != null) {
      final acceptedRequest = {
        'from': request['from'],
        'to': request['to'],
        'status': 'accepted',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .add(acceptedRequest);

      await firestore
          .collection('users')
          .doc(request['from'])
          .collection('friends')
          .add(acceptedRequest);

      await request.reference.update({'status': 'accepted'});

      final senderSnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: request['from'])
          .get();

      if (senderSnapshot.docs.isNotEmpty) {
        final senderId = senderSnapshot.docs.first.id;
        await firestore
            .collection('users')
            .doc(senderId)
            .collection('sent_requests')
            .where('to', isEqualTo: request['to'])
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({'status': 'accepted'});
          }
        });

        await firestore
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .add(acceptedRequest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Friend\'s Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendFriendRequest,
              child: const Text('Send Friend Request'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Text('Friend Requests'),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('users')
                        .doc(auth.currentUser?.uid)
                        .collection('received_requests')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final requests = snapshot.data!.docs;
                      return Column(
                        children: requests.map((request) {
                          return ListTile(
                            title: Text(request['from']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    acceptFriendRequest(request);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    request.reference
                                        .update({'status': 'denied'});
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Friends List'),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('users')
                        .doc(auth.currentUser?.uid)
                        .collection('friends')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final friends = snapshot.data!.docs;
                      return Column(
                        children: friends.map((friend) {
                          return ListTile(
                            title: Text(friend['to'] == auth.currentUser?.email
                                ? friend['from']
                                : friend['to']),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
