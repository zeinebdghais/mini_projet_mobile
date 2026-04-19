import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/controllers/user_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/models/absence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DemandeScreen extends StatefulWidget {
  const DemandeScreen({super.key});

  @override
  State<DemandeScreen> createState() => _Demandeviewstate();
}

class _Demandeviewstate extends State<DemandeScreen> {
  int currentIndex = 2;
  String _selectedType = 'conge';
  bool _isLoading = false;

  // Contrôleurs pour les formulaires
  final TextEditingController _motifController = TextEditingController();
  final TextEditingController _raisonController = TextEditingController();

  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;
  DateTime? _selectedDateAbsence;
  String? _selectedTypeConge;
  String? _selectedTypeAbsence;

  final CongeAbsenceController _controller = CongeAbsenceController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Utilisateur connecté (récupéré du UserController)
  get _currentUser => userController.currentUser;

  @override
  void dispose() {
    _motifController.dispose();
    _raisonController.dispose();
    super.dispose();
  }

  Widget blurCircle(Color color, double size, double top, double left) {
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
              color: color.withOpacity(0.4),
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/employe/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/employe/conges');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/employe/documents');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/employe/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          blurCircle(Colors.greenAccent, 150, 60, 20),
          blurCircle(Colors.yellowAccent, 120, 300, -50),
          blurCircle(Colors.blueAccent, 140, 500, 200),
          Column(
            children: [
              const SizedBox(height: 20),
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Nouvelle demande',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.deepPurple),
                      tooltip: 'Déconnexion',
                      onPressed: () {
                        userController.clearCurrentUser();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // TABS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildTab('Congé', 'conge'),
                    _buildTab('Absence', 'absence'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // FORMS
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedType == 'conge')
                          _buildCongeForm()
                        else if (_selectedType == 'absence')
                          _buildAbsenceForm(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavbar(
              currentIndex: currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, String value) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C2BD9) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCongeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails de la Demande',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Type de Congé
        _buildDropdown(
          'Type de Congé',
          _selectedTypeConge,
          [
            'Congé annuel',
            'Congé de maternité/paternité',
            'Congé maladie',
            'Congé sans solde',
            'Autre',
          ],
          (value) => setState(() => _selectedTypeConge = value),
        ),
        // Date de Début
        _buildDateField(
          'Date de Début',
          _selectedDateDebut,
          (date) => setState(() => _selectedDateDebut = date),
        ),
        // Date de Fin
        _buildDateField(
          'Date de Fin',
          _selectedDateFin,
          (date) => setState(() => _selectedDateFin = date),
        ),
        // Calcul du nombre de jours
        if (_selectedDateDebut != null && _selectedDateFin != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C2BD9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Nombre de jours: ${_selectedDateFin!.difference(_selectedDateDebut!).inDays + 1}',
                style: const TextStyle(
                  color: Color(0xFF6C2BD9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        // Motif
        _buildFormField(
          'Motif',
          'Entrez le motif...',
          _motifController,
          isTextArea: true,
        ),
        const SizedBox(height: 20),
        // Bouton Envoyer
        ElevatedButton(
          onPressed: _isLoading ? null : _submitCongeRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C2BD9),
            minimumSize: const Size(double.infinity, 50),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Envoyer la demande',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget _buildAbsenceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails de l\'Absence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Date de l'Absence
        _buildDateField(
          'Date de l\'Absence',
          _selectedDateAbsence,
          (date) => setState(() => _selectedDateAbsence = date),
        ),
        // Type d'Absence
        _buildDropdown(
          'Type d\'Absence',
          _selectedTypeAbsence,
          ['Absences injustifiées', 'Absence justifiée', 'Maladie'],
          (value) => setState(() => _selectedTypeAbsence = value),
        ),
        // Raison
        _buildFormField(
          'Raison',
          'Entrez la raison...',
          _raisonController,
          isTextArea: true,
        ),
        const SizedBox(height: 20),
        // Bouton Envoyer
        ElevatedButton(
          onPressed: _isLoading ? null : _submitAbsenceRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C2BD9),
            minimumSize: const Size(double.infinity, 50),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Signaler l\'absence',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isTextArea = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            maxLines: isTextArea ? 4 : 1,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Sélectionner...'),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: TextField(
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                onDateSelected(date);
              }
            },
            decoration: InputDecoration(
              hintText: 'Sélectionner une date',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF6C2BD9),
              ),
            ),
            controller: TextEditingController(
              text: selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : '',
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Récupère l'ID du manager (soit du user, soit cherche un manager/RH)
  Future<String> _getManagerId() async {
    // Si l'utilisateur a un manager assigné
    if (_currentUser?.managerId != null &&
        _currentUser!.managerId!.isNotEmpty) {
      return _currentUser!.managerId!;
    }

    // Sinon, cherche un RH pour approuver
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'rh')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('⚠️ Erreur récupération manager: $e');
    }

    return 'pending_approval'; // Fallback
  }

  /// Mappe le libellé de type de congé à l'enum
  TypeConge _mapTypeConge(String? label) {
    if (label == null) return TypeConge.sansSolde;

    if (label.toLowerCase().contains('annuel')) return TypeConge.annuel;
    if (label.toLowerCase().contains('maladie')) return TypeConge.maladie;
    return TypeConge.sansSolde;
  }

  /// Mappe le libellé de type d'absence à l'enum
  TypeAbsence _mapTypeAbsence(String? label) {
    if (label == null) return TypeAbsence.nonJustifiee;

    if (label.toLowerCase().contains('justifi')) return TypeAbsence.justifiee;
    if (label.toLowerCase().contains('maladie')) return TypeAbsence.maladie;
    return TypeAbsence.nonJustifiee;
  }

  /// Mappe le libellé de type de document à l'enum
  Future<void> _submitCongeRequest() async {
    if (_selectedTypeConge == null ||
        _selectedDateDebut == null ||
        _selectedDateFin == null ||
        _motifController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Vous devez être connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupère le manager
      final managerId = await _getManagerId();

      final conge = Conge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeId: _currentUser!.id,
        managerId: managerId,
        typeConge: _mapTypeConge(_selectedTypeConge),
        dateDebut: _selectedDateDebut!,
        dateFin: _selectedDateFin!,
        duree: _selectedDateFin!.difference(_selectedDateDebut!).inDays + 1,
        motif: _motifController.text,
        statut: StatutConge.enAttente,
        dateDemande: DateTime.now(),
      );

      await _controller.createCongeRequest(conge);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande de congé envoyée avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _resetCongeForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAbsenceRequest() async {
    if (_selectedTypeAbsence == null ||
        _selectedDateAbsence == null ||
        _raisonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Vous devez être connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupère le manager
      final managerId = await _getManagerId();

      final absence = Absence(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeId: _currentUser!.id,
        managerId: managerId,
        typeAbsence: _mapTypeAbsence(_selectedTypeAbsence),
        dateAbsence: _selectedDateAbsence!,
        motif: _raisonController.text,
        statut: StatutAbsence.enAttente,
        dateDemande: DateTime.now(),
      );

      await _controller.createAbsenceRequest(absence);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Absence signalée avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _resetAbsenceForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetCongeForm() {
    setState(() {
      _selectedTypeConge = null;
      _selectedDateDebut = null;
      _selectedDateFin = null;
      _motifController.clear();
    });
  }

  void _resetAbsenceForm() {
    setState(() {
      _selectedTypeAbsence = null;
      _selectedDateAbsence = null;
      _raisonController.clear();
    });
  }
}
