import 'dart:io';

import 'package:chat_app/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();

  bool isLogin = true;
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredUserName = '';
  File? selectedImage;
  var isAuthenticating = false;
  void submit() async {
    final isValid = form.currentState!.validate();
    if (!isValid || !isLogin && selectedImage == null) {
      return;
    }
    form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUserName,
          'email': enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
                width: 300,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 20,
                  left: 30,
                  right: 30,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLogin)
                              UserImage(
                                onPickImage: (pickedImage) {
                                  selectedImage = pickedImage;
                                },
                              ),
                            if (!isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  enteredUserName = newValue!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (newValue) {
                                enteredEmail = newValue!;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                enteredPassword = newValue!;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!isAuthenticating)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: submit,
                                child: Text(isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!isAuthenticating)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: Text(
                                  isLogin
                                      ? 'Create new account'
                                      : 'I already have an account',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
