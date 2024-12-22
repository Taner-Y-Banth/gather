import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gather_app/pages/login/auth_gate.dart';
import 'package:gather_app/pages/functions/password_check.dart';
import 'package:gather_app/pages/functions/update_user.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Sign up the user and take to the home page
  Future<void> signUp() async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      UpdateUser().setUser(emailController.text, auth.currentUser);

      // Navigate to the home page if sign up is successful
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    } catch (e) {
      String error = e.toString();
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
            child: Image(
              image: AssetImage('assets/logo-circle.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: passwordConfirmationController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    PasswordCheck().checkPassword(
                      passwordController,
                      passwordConfirmationController,
                      context,
                      signUp,
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
