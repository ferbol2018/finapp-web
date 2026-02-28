import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaldoCard extends StatelessWidget {
  final double total;
  final double ingresos;
  final double gastos;

  const SaldoCard({
    super.key,
    required this.total,
    required this.ingresos,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context) {

    final formato = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            formato.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ingresos: ${formato.format(ingresos)}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Gastos: ${formato.format(gastos)}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}