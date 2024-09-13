import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff/screen/chat.dart';
import 'package:ff/widgets/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

final FirebaseAuth _firebase = FirebaseAuth.instance;

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() {
    return _AuthscreenState();
  }
}

class _AuthscreenState extends State<Authscreen> {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  File? _selectedIm;
  bool _isLoading = false;
  bool isl = false;
  bool isuploading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedIm == null) {
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        isuploading = true;
      });
      if (_isLogin) {
        // Email/Password Login
        final user = await _firebase.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        isl = true;

        print('User logged in: $user');
      } else {
        // Email/Password Sign Up
        final user = await _firebase.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final Storageref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.user!.uid}.jpg');
        await Storageref.putFile(_selectedIm!);
        final imageurl = await Storageref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(user.user!.uid).set({
          'username': _username,
          'email': _email,
          'image': imageurl,
        });
      }
    } on FirebaseAuthException catch (error) {
      String message = 'Authentication failed';
      if (error.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (error.code == 'invalid-email') {
        message = 'This email address is not valid.';
      } else if (error.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (error.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (error.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickim: (picked) {
                                _selectedIm = picked;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter a valid Username';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _username = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
