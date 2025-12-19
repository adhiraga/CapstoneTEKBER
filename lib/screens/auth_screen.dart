import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool isRegistering = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty) {
      showSnackBar('Username field is empty');
      return;
    }

    if (email.isEmpty) {
      showSnackBar('Email field is empty');
      return;
    }

    if (password.isEmpty) {
      showSnackBar('Password field is empty');
      return;
    }

    if (confirmPassword.isEmpty) {
      showSnackBar('Please confirm your password');
      return;
    }

    if (!isValidEmail(email)) {
      showSnackBar('Please enter a valid email address');
      return;
    }

    if (!isValidPassword(password)) {
      showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      showSnackBar('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    try {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        showSnackBar('Username is already taken');
        setState(() => isLoading = false);
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'password': password,
        'aiWins': 0,
        'multiplayerWins': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      showSnackBar('Registration successful! Please login.');

      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      setState(() => isRegistering = false);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Email is already in use';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else {
        message = e.message ?? 'Registration failed';
      }
      showSnackBar(message);
    } catch (e) {
      showSnackBar('An error occurred: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> login() async {
    final loginInput = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (loginInput.isEmpty) {
      showSnackBar('Username or Email field is empty');
      return;
    }

    if (password.isEmpty) {
      showSnackBar('Password field is empty');
      return;
    }

    setState(() => isLoading = true);

    try {
      String? email;
      String? storedPassword;

      if (loginInput.contains('@')) {
        email = loginInput;
      } else {
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: loginInput)
            .get();

        if (usernameQuery.docs.isEmpty) {
          showSnackBar('Username not found');
          setState(() => isLoading = false);
          return;
        }

        final userData = usernameQuery.docs.first.data();
        email = userData['email'];
        storedPassword = userData['password'];
      }

      if (storedPassword != null) {
        if (storedPassword != password) {
          showSnackBar('Incorrect password');
          setState(() => isLoading = false);
          return;
        }
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email!,
          password: password,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Email not found';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else {
        message = e.message ?? 'Login failed';
      }
      showSnackBar(message);
    } catch (e) {
      showSnackBar('An error occurred: $e');
    }

    setState(() => isLoading = false);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isRegistering ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              if (isRegistering)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              TextField(
                controller: isRegistering ? emailController : usernameController,
                decoration: InputDecoration(
                  labelText: isRegistering ? 'Email' : 'Username or Email',
                  hintText: isRegistering
                      ? 'Enter your email'
                      : 'Enter username or email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: isRegistering
                      ? 'Password (min 6 characters)'
                      : 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (isRegistering) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : (isRegistering ? register : login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isRegistering ? 'Register' : 'Login',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          isRegistering = !isRegistering;
                          usernameController.clear();
                          emailController.clear();
                          passwordController.clear();
                          confirmPasswordController.clear();
                        });
                      },
                child: Text(
                  isRegistering
                      ? 'Already have an account? Login'
                      : 'Don\'t have an account? Register',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
