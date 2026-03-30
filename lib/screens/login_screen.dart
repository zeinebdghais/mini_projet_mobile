import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/services/auth_service.dart';
import 'package:sirh_mobile/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Widget buildBlurCircle({
    required Color color,
    required double size,
    required double top,
    required double left,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final motDePasse = _passwordController.text;

    if (email.isEmpty || motDePasse.isEmpty) {
      _showErrorAlert('Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(email, motDePasse);

      if (user != null) {
        // Rediriger selon le rôle
        _navigateByRole(user);
      } else {
        _showErrorAlert('Identifiants invalides');
      }
    } catch (e) {
      // Extraire le message d'erreur réel
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      _showErrorAlert(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateByRole(User user) {
    // Redirige selon le rôle de l'utilisateur (enum UserRole)
    if (user.role == UserRole.manager) {
      Navigator.of(context).pushReplacementNamed('/manager/dashboard');
    } else if (user.role == UserRole.employe) {
      Navigator.of(context).pushReplacementNamed('/employe/dashboard');
    } else if (user.role.toString().split('.').last == 'admin' ||
        user.role == UserRole.rh) {
      // Si tu veux un rôle admin, adapte ici selon l'enum ou la base
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
    } else {
      // Par défaut, redirige vers l'accueil employé
      Navigator.of(context).pushReplacementNamed('/employe/dashboard');
    }
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de connexion'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Bienvenue",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FAFF), Colors.white],
              ),
            ),
          ),

          /// Cercles flous
          buildBlurCircle(
            color: Colors.greenAccent,
            size: 150,
            top: 60,
            left: 20,
          ),
          buildBlurCircle(
            color: Colors.yellowAccent,
            size: 140,
            top: 0,
            left: size.width - 160,
          ),
          buildBlurCircle(
            color: Colors.blueAccent,
            size: 170,
            top: 200,
            left: size.width - 140,
          ),
          buildBlurCircle(
            color: Colors.orangeAccent,
            size: 150,
            top: size.height - 120,
            left: size.width - 150,
          ),

          /// Flou global
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          /// CONTENU
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  /// Adresse Email
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Adresse Email",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Entrez votre adresse e-mail",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Mot de passe
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Mot de passe", style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Entrez votre mot de passe",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Bouton
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLoading
                                ? [Colors.grey, Colors.grey]
                                : [
                                    const Color(0xFF6C2BD9),
                                    const Color(0xFF7C3AED),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Se Connecter",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
