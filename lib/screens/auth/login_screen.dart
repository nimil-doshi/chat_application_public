import 'dart:developer';

import 'package:chat_application/api/apis.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/screens/chat_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function for login
Future<void> _handleLogin(BuildContext context) async {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final username = usernameController.text.trim();
            final password = passwordController.text.trim();
            final email = "$username@gmail.com";

            if (username.isEmpty || password.isEmpty) {
              Dialogs.showSnackBar(context, 'Please fill all fields');
              return;
            }

            try {
              // Retrieve the document for the given username
              final userDoc = await _firestore
                  .collection('authentication')
                  .doc(username)
                  .get();

              if (userDoc.exists) {
                // Check if the password matches
                if (userDoc['password'] == password) {
                  // Sign in with FirebaseAuth
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // Navigate to ChatHomeScreen
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatHomeScreen(),
                    ),
                  );
                } else {
                  Dialogs.showSnackBar(
                      context, 'Incorrect password. Please try again.');
                }
              } else {
                Dialogs.showSnackBar(context, 'Username does not exist.');
              }
            } catch (e) {
              log('Error during login: $e');
              Dialogs.showSnackBar(context, 'Something went wrong. Try again.');
            }
          },
          child: const Text('Login'),
        ),
      ],
    ),
  );
}




  // Function for signup
  // Function for signup
Future<void> _handleSignup(BuildContext context) async {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Up'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final username = usernameController.text.trim();
            final password = passwordController.text.trim();
            final name = nameController.text.trim();
            final email = "$username@gmail.com";

            if (username.isEmpty || password.isEmpty || name.isEmpty) {
              Dialogs.showSnackBar(context, 'Please fill all fields');
              return;
            }

            try {
              final userDoc = await _firestore
                  .collection('authentication')
                  .doc(username)
                  .get();

              if (userDoc.exists) {
                Dialogs.showSnackBar(context, 'Username already exists');
              } else {
               
                // Create user with email and password
                final anonymousUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );


                // Check if user is successfully created
               if (anonymousUser != null){
                  await Apis.createNewUser(
                    name: name, username: username, password: password
                  );
                  await Apis.createUser(
                    name: name,
                   );

                  // Navigate to the chat home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChatHomeScreen()),
                  );
                } else {
                  Dialogs.showSnackBar(context, 'Authentication failed');
                }
              }
            } catch (e) {
              log('Error during signup: $e');
              Dialogs.showSnackBar(context, 'Something went wrong. Try again.');
            }
          },
          child: const Text('Sign Up'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chat Application'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () => _handleLogin(context),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () => _handleSignup(context),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  
}

