import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geotrack_frontend/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Couleurs personnalisées
  final Color _primaryGreen = const Color(0xFF2ECC40); // Vert Nexor
  final Color _backgroundWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: _backgroundWhite,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        title: const Text(''),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Entrez votre PIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _pinController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      labelStyle: TextStyle(color: _primaryGreen),
                      filled: true,
                      fillColor: _primaryGreen.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                      prefixIcon: Icon(Icons.lock, color: _primaryGreen),
                      counterText: '',
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
                  const SizedBox(height: 18),
                  if (authService.isBlocked())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Compte verrouillé. Réessayez dans ${authService.getRemainingBlockTime().inMinutes} minutes',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed:
                          authService.isBlocked() || _isLoading
                              ? null
                              : _handleLogin,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // TODO: Naviguer vers la page de récupération du PIN
                      Navigator.pushNamed(context, '/forgot_pin');
                    },
                    child: Text(
                      'Code PIN oublié ?',
                      style: TextStyle(
                        color: _primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

      final authService = Provider.of<AuthService>(context, listen: false);
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
