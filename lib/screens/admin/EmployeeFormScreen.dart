import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sirh_mobile/screens/admin/bottom_navbar.dart';

class EmployeeFormScreen extends StatefulWidget {
  final bool isEditing; // true pour modifier, false pour ajouter
  const EmployeeFormScreen({super.key, this.isEditing = false});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  int _currentIndex = 1;

  // Méthode de background identique
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? "Modifier Employé" : "Ajouter un Employé",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- BACKGROUND ---
          Container(decoration: const BoxDecoration(color: Color(0xFFF8FAFF))),
          buildBlurCircle(
            color: Colors.greenAccent,
            size: 150,
            top: 60,
            left: 20,
          ),
          buildBlurCircle(
            color: Colors.blueAccent,
            size: 170,
            top: 400,
            left: size.width - 140,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          // --- FORMULAIRE ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              child: Column(
                children: [
                  // Section Photo (Style Profil)
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/150?u=newuser',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF5F2EEA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sync,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Upload Photo",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // Regroupement par sections pour plus de clarté
                  _buildSectionTitle("Informations Personnelles"),
                  _buildTextField("Nom", Icons.person_outline),
                  _buildTextField("Prénom", Icons.person_outline),
                  _buildTextField("Email", Icons.email_outlined),
                  _buildTextField(
                    "Mot de passe",
                    Icons.lock_outline,
                    obscure: true,
                  ),
                  _buildTextField("Téléphone", Icons.phone_outlined),
                  _buildTextField("CIN", Icons.badge_outlined),
                  _buildTextField("Nationalité", Icons.flag_outlined),
                  _buildTextField("Adresse", Icons.location_on_outlined),
                  _buildDatePicker("Date de Naissance"),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Informations Professionnelles"),
                  _buildDropdown("Rôle Utilisateur", [
                    "Employé",
                    "Manager",
                    "Admin",
                  ]),
                  _buildTextField(
                    "Salaire",
                    Icons.payments_outlined,
                    isNumber: true,
                  ),
                  _buildDatePicker("Date d'Embauche"),
                  _buildDropdown("Département", [
                    "IT",
                    "RH",
                    "Finance",
                    "Marketing",
                  ]),
                  _buildDropdown("Manager Direct", [
                    "Zeineb Dghais",
                    "Nadia Fassi",
                    "Aucun",
                  ]),
                  _buildTextField(
                    "Solde Congé Total",
                    Icons.event_available,
                    isNumber: true,
                  ),

                  const SizedBox(height: 30),

                  // Bouton Valider
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F2EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.isEditing
                            ? "Mettre à jour"
                            : "Enregistrer l'employé",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF5F2EEA),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    bool obscure = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          TextField(
            obscureText: obscure,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF5F2EEA), size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Sélectionner"),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Sélectionner une date",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF5F2EEA),
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
