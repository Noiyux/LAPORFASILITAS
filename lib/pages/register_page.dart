import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool isLoading = false;

  // ================= REGISTER =================
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal';

      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password minimal 6 karakter';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ===== EMAIL =====
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Email wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              // ===== PASSWORD =====
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v == null || v.length < 6
                    ? 'Password minimal 6 karakter'
                    : null,
              ),

              const SizedBox(height: 12),

              // ===== KONFIRMASI =====
              TextFormField(
                controller: _confirmController,
                decoration:
                    const InputDecoration(labelText: 'Konfirmasi Password'),
                obscureText: true,
                validator: (v) => v != _passwordController.text
                    ? 'Password tidak sama'
                    : null,
              ),

              const SizedBox(height: 24),

              // ===== BUTTON REGISTER =====
              ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
