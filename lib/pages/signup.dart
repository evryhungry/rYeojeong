import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final pconfirmController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    pconfirmController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // 데이터베이스에 사용자 정보 저장
  Future<void> _saveUserToDatabase(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user: $e')),
      );
    }
  }

  // 회원가입 처리
  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firebase Authentication에 사용자 생성
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Firestore에 사용자 추가
        await _saveUserToDatabase(userCredential.user!.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );

        // 회원가입 완료 후 로그인 페이지로 이동
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }
    }
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is invalid';
    }
    final letterRegex = RegExp(r'[A-Za-z]');
    final numberRegex = RegExp(r'[0-9]');
    int letterCount =
        value.split('').where((char) => letterRegex.hasMatch(char)).length;
    if (letterCount < 3) {
      return 'Username must contain at least 3 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 150),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                controller: usernameController,
                validator: _validateInput,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: pconfirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Confirm Password doesn’t match Password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('SIGN UP'),
                    onPressed: _signup,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
