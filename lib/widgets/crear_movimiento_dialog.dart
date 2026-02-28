import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movimiento.dart';

class CrearMovimientoDialog extends StatefulWidget {
  final Movimiento? movimiento;
  final VoidCallback onSuccess;

  const CrearMovimientoDialog({
    super.key,
    this.movimiento,
    required this.onSuccess,
  });

  @override
  State<CrearMovimientoDialog> createState() =>
      _CrearMovimientoDialogState();
}

class _CrearMovimientoDialogState
    extends State<CrearMovimientoDialog> {

  final montoController = TextEditingController();
  final descripcionController = TextEditingController();

  String tipo = "gasto";
  final api = ApiService();

  @override
  void initState() {
    super.initState();

    if (widget.movimiento != null) {
      montoController.text =
          widget.movimiento!.monto.toString();
      descripcionController.text =
          widget.movimiento!.descripcion;
      tipo = widget.movimiento!.tipo;
    }
  }

  Future<void> guardar() async {

    final monto = double.tryParse(montoController.text);

    if (monto == null) return;

    if (widget.movimiento == null) {
      await api.crearMovimiento(
        cuentaId: 1,
        tipo: tipo,
        monto: monto,
        categoria: "General",
        descripcion: descripcionController.text,
      );
    } else {
      await api.editarMovimiento(
        id: widget.movimiento!.id,
        cuentaId: 1,
        tipo: tipo,
        monto: monto,
        categoria: "General",
        descripcion: descripcionController.text,
      );
    }

    widget.onSuccess();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.movimiento == null
          ? "Nuevo Movimiento"
          : "Editar Movimiento"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          DropdownButton<String>(
            value: tipo,
            items: const [
              DropdownMenuItem(value: "ingreso", child: Text("Ingreso")),
              DropdownMenuItem(value: "gasto", child: Text("Gasto")),
            ],
            onChanged: (value) {
              setState(() {
                tipo = value!;
              });
            },
          ),

          TextField(
            controller: montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Monto"),
          ),

          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: "Descripción"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: guardar,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}