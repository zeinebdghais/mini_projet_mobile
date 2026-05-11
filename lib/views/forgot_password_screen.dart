import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Téléphone, 2: Code, 3: Mot de passe
  bool _isLoading = false;
  String? _generatedCode; // Pour tester sans SMS réel

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
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 📱 ÉTAPE 1: Envoyer le code au téléphone
  Future<void> _handleSendCode() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showErrorAlert('Veuillez entrer votre numéro de téléphone');
      return;
    }

    if (phone.length < 8) {
      _showErrorAlert('Le numéro doit contenir au moins 8 chiffres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Vérifier que l'utilisateur existe
      final user = await _authService.getUserByPhoneNumber(phone);
      if (user == null) {
        throw Exception('Utilisateur non trouvé');
      }

      // Envoyer le code
      _generatedCode = await _authService.sendVerificationCode(phone);

      setState(() => _currentStep = 2);

      _showSuccessDialog(
        'Code envoyé',
        'Un code de vérification a été envoyé à $phone',
      );
    } catch (e) {
      _showErrorAlert(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ ÉTAPE 2: Vérifier le code
  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    final phone = _phoneController.text.trim();

    if (code.isEmpty) {
      _showErrorAlert('Veuillez entrer le code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _authService.verifyCode(phone, code);

      if (isValid) {
        setState(() => _currentStep = 3);
        _showSuccessDialog(
          'Code vérifié',
          'Veuillez créer un nouveau mot de passe',
        );
      }
    } catch (e) {
      _showErrorAlert(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔐 ÉTAPE 3: Changer le mot de passe
  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phone = _phoneController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorAlert('Veuillez remplir tous les champs');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorAlert('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorAlert('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(phone, newPassword);

      _showSuccessDialog('Succès', 'Votre mot de passe a été réinitialisé');

      // Rediriger vers login après succès
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showErrorAlert(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erreur'),
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

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ $title'),
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entrez votre numéro de téléphone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5F2EEA),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nous enverrons un code de vérification à ce numéro',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        const Text(
          'Numéro de téléphone',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '12 34 56 78',
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
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendCode,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C2BD9), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
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
                        'Envoyer le code',
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
        if (_generatedCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔐 Code test: $_generatedCode',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vérification du code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5F2EEA),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Entrez le code reçu par SMS',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        const Text(
          'Code de vérification',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '000000',
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
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyCode,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C2BD9), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
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
                        'Vérifier le code',
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
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text(
              '← Retour',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créer un nouveau mot de passe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5F2EEA),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choisissez un mot de passe sécurisé',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        const Text(
          'Nouveau mot de passe',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Entrez votre nouveau mot de passe',
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
        const Text(
          'Confirmer le mot de passe',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirmez votre mot de passe',
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
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C2BD9), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
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
                        'Réinitialiser le mot de passe',
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
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: const Text(
              '← Retour',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Récupération du mot de passe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  /// Indicateur d'étape
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(
                        number: 1,
                        isActive: _currentStep >= 1,
                        isCompleted: _currentStep > 1,
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        color: _currentStep > 1
                            ? const Color(0xFF7C3AED)
                            : Colors.grey[300],
                      ),
                      _buildStepIndicator(
                        number: 2,
                        isActive: _currentStep >= 2,
                        isCompleted: _currentStep > 2,
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        color: _currentStep > 2
                            ? const Color(0xFF7C3AED)
                            : Colors.grey[300],
                      ),
                      _buildStepIndicator(
                        number: 3,
                        isActive: _currentStep >= 3,
                        isCompleted: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  /// Contenu dynamique selon l'étape
                  if (_currentStep == 1) _buildStep1(),
                  if (_currentStep == 2) _buildStep2(),
                  if (_currentStep == 3) _buildStep3(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int number,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? const Color(0xFF7C3AED)
            : isActive
            ? const Color(0xFF7C3AED)
            : Colors.grey[300],
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white)
            : Text(
                '$number',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
