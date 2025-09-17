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
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      setState(() {}); // Rafraîchir l'UI quand le PIN change
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final pinLength = _pinController.text.length;
    final isValidLength = pinLength >= 4 && pinLength <= 6;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[850]!, Colors.grey[800]!]
                    : [
                      const Color(0xFFF5FDF6), // Vert très clair
                      const Color(0xFFE8F5E9),
                      const Color(0xFFE8F5E9),
                    ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo et titre
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode ? Colors.green[800] : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 60,
                            color:
                                isDarkMode ? Colors.white : Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nexor GeoTrack',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.white : Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suivi GPS professionnel',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDarkMode
                                    ? Colors.green[200]
                                    : Colors.green[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Carte de formulaire
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                'Connexion sécurisée',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Veuillez saisir votre code PIN (4-6 chiffres)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Champ PIN
                              TextFormField(
                                controller: _pinController,
                                obscureText: _obscurePin,
                                decoration: InputDecoration(
                                  labelText: 'Code PIN',
                                  hintText: 'Entre 4 et 6 chiffres',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color:
                                        isDarkMode
                                            ? Colors.green[300]
                                            : Colors.green[700],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePin
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color:
                                          isDarkMode
                                              ? Colors.green[300]
                                              : Colors.green[700],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePin = !_obscurePin;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre PIN';
                                  }
                                  if (value.length < 4 || value.length > 6) {
                                    return 'Le PIN doit contenir entre 4 et 6 chiffres';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return 'Le PIN ne doit contenir que des chiffres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              // Indicateur visuel de la longueur du PIN
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isValidLength
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isValidLength
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.orange.withOpacity(
                                                  0.3,
                                                ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '$pinLength/6',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isValidLength
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Message de verrouillage
                              if (authService.isBlocked())
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Compte verrouillé. Réessayez dans ${authService.getRemainingBlockTime().inMinutes} minutes',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Bouton de connexion
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      authService.isBlocked() || _isLoading
                                          ? null
                                          : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isValidLength && pinLength >= 4
                                            ? Colors.green[700]
                                            : Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Lien mot de passe oublié
                              TextButton(
                                onPressed: () {
                                  // TODO: Implémenter la récupération de PIN
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fonctionnalité à implémenter',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Code PIN oublié ?',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Informations de version ou copyright
                    Text(
                      'Version 1.0 • © 2023 Nexor GeoTrack',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Masquer le clavier
      FocusScope.of(context).unfocus();

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
          SnackBar(
            content: Text(result.error ?? 'Échec de la connexion'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pinController.removeListener(() {});
    _pinController.dispose();
    super.dispose();
  }
}
