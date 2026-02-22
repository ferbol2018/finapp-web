import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/reportes_screen.dart';
import '../screens/cuentas_screen.dart';
import '../screens/perfil_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(nombre: "Usuario"),
    ReportesScreen(),
    CuentasScreen(),
    PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onVoicePressed() {
    print("Micrófono presionado");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onVoicePressed,
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Inicio", 0),
              _buildNavItem(Icons.bar_chart, "Reportes", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.account_balance_wallet, "Cuentas", 2),
              _buildNavItem(Icons.person, "Perfil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? Colors.blue : Colors.grey),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 12)),
        ],
      ),
    );
  }
}