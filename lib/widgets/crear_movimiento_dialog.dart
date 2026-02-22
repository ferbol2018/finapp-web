import 'package:finanzas_app/models/movimiento.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

class _CrearMovimientoDialogState extends State<CrearMovimientoDialog> {

  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  String tipo = "ingreso";
  final api = ApiService();

  // 🔥 IMPORTANTE → detectar modo edición
  @override
  void initState() {
    super.initState();

    if (widget.movimiento != null) {
      _montoController.text = widget.movimiento!.monto.toString();
      _descripcionController.text = widget.movimiento!.descripcion;
      tipo = widget.movimiento!.tipo;
    }
  }

  Future<void> guardar() async {
    bool ok;

    // 🔥 CREAR
    if (widget.movimiento == null) {
      ok = await api.crearMovimiento(
        cuentaId: 1,
        tipo: tipo,
        monto: double.parse(_montoController.text),
        categoria: "General",
        descripcion: _descripcionController.text,
      );
    }
    // 🔥 EDITAR
    else {
      ok = await api.editarMovimiento(
        id: widget.movimiento!.id,
        cuentaId: 1,
        tipo: tipo,
        monto: double.parse(_montoController.text),
        categoria: "General",
        descripcion: _descripcionController.text,
      );
    }

    if (ok) {
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.movimiento == null
            ? "Nuevo Movimiento"
            : "Editar Movimiento",
      ),
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
            controller: _montoController,
            decoration: const InputDecoration(labelText: "Monto"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _descripcionController,
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
          child: Text(
            widget.movimiento == null ? "Crear" : "Actualizar",
          ),
        ),
      ],
    );
  }
}