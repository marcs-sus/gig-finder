import 'package:flutter/material.dart';

import 'app_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Gig Finder'),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppShell()),
                  );
                }, // TODO: implement auth → AppShell
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {}, // TODO: password recovery
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Name')),
          const TextField(
            decoration: InputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Phone number'),
            keyboardType: TextInputType.phone,
          ),
          const TextField(decoration: InputDecoration(labelText: 'City')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // TODO: create user → AppShell
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
