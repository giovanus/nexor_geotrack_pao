import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geotrack_frontend/services/auth_service.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureOldPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  final Color _primaryGreen = const Color(0xFF2ECC40);

  @override
  void initState() {
    super.initState();
    // Pré-remplir l'email si disponible
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userEmail != null) {
      _emailController.text = authService.userEmail!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        title: const Text('Modifier le PIN'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.lock, size: 80, color: _primaryGreen),
                const SizedBox(height: 24),
                Text(
                  'Modification du PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                    prefixIcon: Icon(Icons.email, color: _primaryGreen),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _oldPinController,
                  obscureText: _obscureOldPin,
                  decoration: InputDecoration(
                    labelText: 'Ancien PIN',
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
                    prefixIcon: Icon(Icons.lock_outline, color: _primaryGreen),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPin
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: _primaryGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureOldPin = !_obscureOldPin;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre ancien PIN';
                    }
                    if (value.length != 4) {
                      return 'Le PIN doit contenir 4 chiffres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPinController,
                  obscureText: _obscureNewPin,
                  decoration: InputDecoration(
                    labelText: 'Nouveau PIN',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPin
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: _primaryGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPin = !_obscureNewPin;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau PIN';
                    }
                    if (value.length != 4) {
                      return 'Le PIN doit contenir 4 chiffres';
                    }
                    if (value == _oldPinController.text) {
                      return 'Le nouveau PIN doit être différent de l\'ancien';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: _obscureConfirmPin,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau PIN',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPin
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: _primaryGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPin = !_obscureConfirmPin;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre nouveau PIN';
                    }
                    if (value != _newPinController.text) {
                      return 'Les PIN ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
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
                    onPressed: _isLoading ? null : _handleChangePin,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Modifier le PIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Annuler',
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
    );
  }

  Future<void> _handleChangePin() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.changePin(
        _emailController.text,
        _oldPinController.text,
        _newPinController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
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
    _emailController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}
