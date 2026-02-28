import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/movimientos_screen.dart';
import '../screens/cuentas_screen.dart';
import '../screens/reportes_screen.dart';
import '../screens/perfil_screen.dart';

class MainNavigation extends StatefulWidget {
  final String nombre;

  const MainNavigation({super.key, required this.nombre});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    final screens = [
      HomeScreen(nombre: widget.nombre),
      MovimientosScreen(nombre: widget.nombre),
      const CuentasScreen(),
      const ReportesScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Movimientos"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Cuentas"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reportes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}