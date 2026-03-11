import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");

      // Aquí iría tu llamada al backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Iniciar Sesión",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Bienvenido de nuevo, por favor ingresa tus credenciales para continuar.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingresa tu email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    color: const Color(0xFFD1D6DB),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Mínimo 6 caracteres";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: const Text("Iniciar sesión"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}