import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento.dart';
import '../services/api_service.dart';
import '../widgets/crear_movimiento_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final String nombre;

  const DashboardScreen({super.key, required this.nombre});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Movimiento>> movimientos;

final formatoCOP = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
);

  @override
  void initState() {
    super.initState();
    cargarMovimientos();
  }

  void cargarMovimientos() {
    movimientos = ApiService.obtenerMovimientos();
  }

  void _abrirDialogEditar(Movimiento mov) {
  showDialog(
    context: context,
    builder: (_) => CrearMovimientoDialog(
      movimiento: mov, // 🔥 modo edición
      onSuccess: () {
        setState(() {
          cargarMovimientos();
        });
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hola, ${widget.nombre} 👋"),
      ),
      body: FutureBuilder<List<Movimiento>>(
        future: movimientos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final lista = snapshot.data!;

          if (lista.isEmpty) {
            return const Center(child: Text("No hay movimientos"));
          }

          // 🔥 Calcular totales
          double total = 0;
          double totalIngresos = 0;
          double totalGastos = 0;

          for (var mov in lista) {
            if (mov.tipo == "ingreso") {
              total += mov.monto;
              totalIngresos += mov.monto;
            } else {
              total -= mov.monto;
              totalGastos += mov.monto;
            }
          }

          return Column(
            children: [

              // 🔹 TARJETA DE SALDO
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  margin: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: total >= 0 ? Colors.green.shade600 : Colors.red.shade600,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Saldo total",
        style: TextStyle(color: Colors.white70),
      ),
      const SizedBox(height: 8),
      Text(
        total < 0
          ? "-${formatoCOP.format(total.abs())}"
          : formatoCOP.format(total),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 12),

      // 🔥 AQUÍ VA EL ROW
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Ingresos: ${formatoCOP.format(totalIngresos)}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Gastos: ${formatoCOP.format(totalGastos)}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ],
  ),
),

              // 🔹 LISTA DE MOVIMIENTOS
              Expanded(
                child: ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final mov = lista[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          mov.tipo == "ingreso"
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: mov.tipo == "ingreso"
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(mov.descripcion),
                        subtitle: Text(mov.categoria),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // 💰 MONTO
                            Text(
                              formatoCOP.format(mov.monto),
                              style: TextStyle(
                                color: mov.tipo == "ingreso"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 6),

                            // ✏️ EDITAR
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _abrirDialogEditar(mov);
                              },
                            ),

                            // 🗑 ELIMINAR
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final ok = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Eliminar movimiento"),
                                    content: const Text("¿Seguro que deseas eliminarlo?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Eliminar"),
                                      ),
                                    ],
                                  ),
                                );

                                if (ok == true) {
                                  await ApiService.eliminarMovimiento(mov.id);
                                  setState(() => cargarMovimientos());
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CrearMovimientoDialog(
              onSuccess: () {
                setState(() {
                  cargarMovimientos();
                });
              }, movimiento: null,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}