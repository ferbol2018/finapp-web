class Movimiento {
  final int id;
  final String tipo;
  final double monto;
  final String descripcion;
  final String categoria;
  final DateTime fecha;

  Movimiento({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      tipo: json['tipo'] ?? "desconocido",
      monto: (json['monto'] as num).toDouble(),
      categoria: json['categoria'] ?? "General",
      descripcion: json['descripcion'] ?? "Sin descripción",
      fecha: DateTime.parse(json['fecha']),
    );
  }
}