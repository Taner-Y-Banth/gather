import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:gather_app/pages/login/auth_gate.dart';
import 'package:gather_app/pages/functions/update_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  File? image;
  String? imageUrl;
  final ImagePicker picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    getUsernameAndPhoto();
  }

  Future<void> getUsernameAndPhoto() async {
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        usernameController.text = user.displayName ?? 'Username';
        imageUrl = user.photoURL;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        if (image != null) {
          // Upload the image to Firebase Storage
          final storageRef =
              storage.ref().child('profile_pictures/${user.uid}');
          await storageRef.putFile(image!);
          imageUrl = await storageRef.getDownloadURL();
        }
        // Update the user's display name and photo URL in FirebaseAuth
        await user.updateDisplayName(usernameController.text);
        if (imageUrl != null) {
          await user.updatePhotoURL(imageUrl!);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }

      UpdateUser().updateUser(usernameController.text, imageUrl!, user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null
                        ? FileImage(image!)
                        : (imageUrl != null ? NetworkImage(imageUrl!) : null),
                    child: image == null && imageUrl == null
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Color.fromARGB(255, 251, 197, 197),
                      child: Icon(Icons.edit,
                          size: 15, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
