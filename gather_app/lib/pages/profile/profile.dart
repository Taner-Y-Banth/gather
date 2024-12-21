import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? imageUrl;
        if (_image != null) {
          // Upload the image to Firebase Storage
          final storageRef =
              _storage.ref().child('profile_pictures/${user.uid}');
          await storageRef.putFile(_image!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Check if the user document exists
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Create the user document if it doesn't exist
          await userDoc.set({
            'email': user.email,
            'username': usernameController.text,
            'profilePicture': imageUrl,
          });
        } else {
          // Update the user's profile in Firestore
          await userDoc.update({
            'username': usernameController.text,
            'profilePicture': imageUrl,
          });
        }

        // Optionally, update the user's display name and photo URL in FirebaseAuth
        await user.updateDisplayName(usernameController.text);
        if (imageUrl != null) {
          await user.updatePhotoURL(imageUrl);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Adjust the route as needed
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
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
