import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geotrack_frontend/services/auth_service.dart'; // Gardé tel quel

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context); // Changé ici

    return Scaffold(
      appBar: AppBar(title: const Text('Nexor GeoTrack Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 300, height: 300),
              const SizedBox(height: 30),
              const Text(
                'Entrez votre PIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pinController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre PIN';
                  }
                  if (value.length != 4) {
                    return 'Le PIN doit contenir 4 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (authService.isBlocked())
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Compte verrouillé. Réessayez dans ${authService.getRemainingBlockTime().inMinutes} minutes',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      authService.isBlocked() || _isLoading
                          ? null
                          : _handleLogin,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Connexion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(
        // Changé ici
        context,
        listen: false,
      );
      final result = await authService.login(_pinController.text);

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Échec de la connexion')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
