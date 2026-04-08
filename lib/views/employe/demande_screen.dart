import 'package:flutter/material.dart';
import 'package:sirh_mobile/views/employe/custom_bottom_navbar.dart';
import 'package:sirh_mobile/controllers/conge_absence_controller.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/models/absence.dart';

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
  final TextEditingController _typeDocController = TextEditingController();
  final TextEditingController _raisonJustificatifController =
      TextEditingController();

  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;
  DateTime? _selectedDateAbsence;
  String? _selectedTypeConge;
  String? _selectedTypeAbsence;

  final CongeAbsenceController _controller = CongeAbsenceController();

  @override
  void dispose() {
    _motifController.dispose();
    _raisonController.dispose();
    _typeDocController.dispose();
    _raisonJustificatifController.dispose();
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Nouvelle Demande',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.add_circle,
                        color: Color(0xFF6C2BD9),
                        size: 26,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Type Selection
                  const Text(
                    'Type de Demande',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTypeCard(
                    'Demande de Congé',
                    'conge',
                    Icons.calendar_today,
                    'Demander un congé annuel, de maladie, etc.',
                  ),
                  _buildTypeCard(
                    'Demande d\'Absence',
                    'absence',
                    Icons.close_rounded,
                    'Signaler une absence non planifiée',
                  ),
                  _buildTypeCard(
                    'Demande de Justificatif',
                    'justificatif',
                    Icons.description,
                    'Demander une attestation ou un justificatif',
                  ),
                  const SizedBox(height: 24),
                  // Form based on selection
                  if (_selectedType == 'conge')
                    _buildCongeForm()
                  else if (_selectedType == 'absence')
                    _buildAbsenceForm()
                  else if (_selectedType == 'justificatif')
                    _buildJustificatifForm(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
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

  Widget _buildTypeCard(
    String title,
    String value,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C2BD9).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C2BD9)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C2BD9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6C2BD9), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF6C2BD9)),
          ],
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
          ['Annuel', 'Maladie', 'Sans Solde'],
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitCongeRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C2BD9),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Envoyer la Demande',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
          ['Non Justifiée', 'Justifiée', 'Maladie'],
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitAbsenceRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C2BD9),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Signaler l\'Absence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildJustificatifForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de Justificatif',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFormField(
          'Type de Document',
          'Attestation d\'Emploi',
          _typeDocController,
        ),
        _buildFormField(
          'Raison de la Demande',
          'Entrez la raison...',
          _raisonJustificatifController,
          isTextArea: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de justificatif envoyée!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C2BD9),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Envoyer la Demande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
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
        GestureDetector(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFF6C2BD9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: selectedDate != null
                        ? Colors.black87
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitCongeRequest() async {
    if (_selectedTypeConge == null ||
        _selectedDateDebut == null ||
        _selectedDateFin == null ||
        _motifController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conge = Conge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeId: 'employe_id', // À récupérer de l'utilisateur connecté
        managerId: 'manager_id', // À récupérer de Firestore
        typeConge: _selectedTypeConge == 'Annuel'
            ? TypeConge.annuel
            : _selectedTypeConge == 'Maladie'
            ? TypeConge.maladie
            : TypeConge.sansSolde,
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
            content: Text('✅ Demande de congé envoyée!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetCongeForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
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
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final absence = Absence(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeId: 'employe_id', // À récupérer de l'utilisateur connecté
        managerId: 'manager_id', // À récupérer de Firestore
        typeAbsence: _selectedTypeAbsence == 'Non Justifiée'
            ? TypeAbsence.nonJustifiee
            : _selectedTypeAbsence == 'Justifiée'
            ? TypeAbsence.justifiee
            : TypeAbsence.maladie,
        dateAbsence: _selectedDateAbsence!,
        motif: _raisonController.text,
        statut: StatutAbsence.enAttente,
        dateDemande: DateTime.now(),
      );

      await _controller.createAbsenceRequest(absence);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Absence signalée!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetAbsenceForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
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
