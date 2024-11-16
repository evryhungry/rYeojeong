import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _errorMessage;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home'); // 로그인 성공 시 홈 화면으로 이동
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 120.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                ),
                TextButton(
                  child: const Text('Sign Up'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text('NEXT'),
                  onPressed: _login,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  final _auth = FirebaseAuth.instance;

  String? _errorMessage;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context); // 회원가입 후 로그인 화면으로 이동
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    pconfirmController.dispose();
    emailController.dispose();
    super.dispose();
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
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Email Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: pconfirmController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your Password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // 로그아웃 후 로그인 화면으로 이동
            },
          ),
        ],
      ),
      body: Center(
        child: const Text('Welcome to the Home Screen!'),
      ),
    );
  }
}
