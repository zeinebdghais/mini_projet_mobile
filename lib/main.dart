import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sirh_mobile/screens/first_page.dart';
import 'package:sirh_mobile/screens/employe/acceuil_employeee.dart';
import 'package:sirh_mobile/screens/employe/conges_screen.dart';
import 'package:sirh_mobile/screens/employe/documents_screen.dart';
import 'package:sirh_mobile/screens/employe/profile_screen.dart';
import 'package:sirh_mobile/screens/employe/demande_screen.dart';
import 'package:sirh_mobile/screens/manager/demandes_screen.dart';
import 'package:sirh_mobile/screens/manager/manager_dashboard_screen.dart';
import 'package:sirh_mobile/screens/manager/team_screen.dart';
import 'package:sirh_mobile/screens/manager/profile_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sirh_mobile/screens/admin/AdminDashboardScreen.dart';
//import 'package:sirh_mobile/screens/admin/EmployeeFormScreen.dart';
import 'package:sirh_mobile/screens/admin/EmployeeManagementScreen.dart';
import 'package:sirh_mobile/screens/admin/DocumentManagementScreen.dart';
import 'package:sirh_mobile/screens/admin/demandes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon SIRH Mobile',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstPage(),
        '/employe/dashboard': (context) => const AcceuilEmployeee(),
        '/manager/dashboard': (context) => const ManagerDashboardScreen(),
        '/manager/demandes': (context) => DemandesScreen(),
        '/manager/team': (context) => TeamScreen(),
        '/manager/profile': (context) => const ProfileScreenManager(),
        // ADMIN ROUTES
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/employees': (context) => const EmployeeManagementScreen(),
        '/admin/demandes': (context) => const DemandesAdminScreen(),
        '/admin/documents': (context) => const DocumentManagementScreen(),
        // Employé
        '/employe/conges': (context) => const CongesScreen(),
        '/employe/demande': (context) => const DemandeScreen(),
        '/employe/documents': (context) => const DocumentsScreen(),
        '/employe/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
