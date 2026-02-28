import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../services/api_service.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/saldo_card.dart';

class HomeScreen extends StatefulWidget {
  final String nombre;

  const HomeScreen({super.key, required this.nombre});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movimiento>> movimientosFuture;

  @override
  void initState() {
    super.initState();
    movimientosFuture = ApiService.obtenerMovimientos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movimiento>>(
      future: movimientosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lista = snapshot.data!;

        double total = 0;
        double ingresos = 0;
        double gastos = 0;

        for (var m in lista) {
          if (m.tipo == "ingreso") {
            ingresos += m.monto;
            total += m.monto;
          } else {
            gastos += m.monto;
            total -= m.monto;
          }
        }

        final ultimos = lista.take(3).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Hola, ${widget.nombre} 👋",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SaldoCard(
                total: total,
                ingresos: ingresos,
                gastos: gastos,
              ),

              const SizedBox(height: 20),

              const Text(
                "Últimos movimientos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: ultimos.length,
                  itemBuilder: (_, i) {
                    return MovimientoTile(
                      movimiento: ultimos[i],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}