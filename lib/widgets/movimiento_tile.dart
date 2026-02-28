import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import 'package:intl/intl.dart';

class MovimientoTile extends StatelessWidget {
  final Movimiento movimiento;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MovimientoTile({
    super.key,
    required this.movimiento,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final formato = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          movimiento.tipo == "ingreso"
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: movimiento.tipo == "ingreso"
              ? Colors.green
              : Colors.red,
        ),
        title: Text(movimiento.descripcion),
        subtitle: Text(movimiento.categoria),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              formato.format(movimiento.monto),
              style: TextStyle(
                color: movimiento.tipo == "ingreso"
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),

            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}