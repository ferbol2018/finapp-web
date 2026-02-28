import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/movimiento.dart';
import '../services/api_service.dart';
import '../widgets/crear_movimiento_dialog.dart';
import '../widgets/movimiento_tile.dart';

class MovimientosScreen extends StatefulWidget {
  final String nombre;

  const MovimientosScreen({super.key, required this.nombre});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late Future<List<Movimiento>> movimientosFuture;

  late stt.SpeechToText speech;
  bool escuchando = false;
  String textoEscuchado = "";

  @override
  void initState() {
    super.initState();
    cargarMovimientos();
    speech = stt.SpeechToText();
  }

  void cargarMovimientos() {
    movimientosFuture = ApiService.obtenerMovimientos();
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  // 🎤 ESCUCHAR VOZ
  Future<void> escucharVoz() async {
    if (escuchando) {
      await speech.stop();
      setState(() {
        escuchando = false;
        textoEscuchado = "";
      });
      return;
    }

    bool disponible = await speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          setState(() => escuchando = false);
        }
      },
    );

    if (!disponible) return;

    setState(() {
      escuchando = true;
      textoEscuchado = "";
    });

    speech.listen(
      localeId: "es_CO",
      partialResults: true,
      onResult: (result) {
        setState(() {
          textoEscuchado = result.recognizedWords;
        });

        if (result.finalResult) {
          speech.stop();
          setState(() => escuchando = false);

          if (textoEscuchado.isNotEmpty) {
            mostrarDialogoConfirmacion(textoEscuchado);
          }
        }
      },
    );
  }

  // 📋 DIÁLOGO CONFIRMAR / REPETIR
  void mostrarDialogoConfirmacion(String texto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar movimiento"),
        content: Text(
          texto,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [

          // ❌ Cancelar
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                textoEscuchado = "";
              });
            },
            child: const Text("Cancelar"),
          ),

          // 🔁 Repetir
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                textoEscuchado = "";
              });
              escucharVoz();
            },
            child: const Text("Repetir"),
          ),

          // ✅ Confirmar
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final ok =
                  await ApiService.registrarTexto(texto);

              if (ok) {
                setState(() {
                  textoEscuchado = "";
                  cargarMovimientos();
                });
              }
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void abrirDialogCrear() {
    showDialog(
      context: context,
      builder: (_) => CrearMovimientoDialog(
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
    return FutureBuilder<List<Movimiento>>(
      future: movimientosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lista = snapshot.data!;

        return Scaffold(
          body: Column(
            children: [

              // 🎤 TEXTO EN VIVO
              if (escuchando || textoEscuchado.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  child: Text(
                    textoEscuchado.isEmpty
                        ? "🎤 Escuchando..."
                        : textoEscuchado,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

              // 📋 LISTA
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final mov = lista[i];

                    return MovimientoTile(
                      movimiento: mov,

                      // ✏ EDITAR
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => CrearMovimientoDialog(
                            movimiento: mov,
                            onSuccess: () {
                              setState(() {
                                cargarMovimientos();
                              });
                            },
                          ),
                        );
                      },

                      // 🗑 ELIMINAR CON CONFIRMACIÓN
                      onDelete: () async {
                        final confirmar =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Eliminar movimiento"),
                            content: const Text(
                                "¿Seguro que deseas eliminarlo?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        context, false),
                                child:
                                    const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        context, true),
                                child:
                                    const Text("Eliminar"),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          await ApiService
                              .eliminarMovimiento(mov.id);
                          setState(() {
                            cargarMovimientos();
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 🔘 BOTONES
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              // 🎤 Voz
              FloatingActionButton(
                heroTag: "voz",
                backgroundColor:
                    escuchando ? Colors.red : Colors.blue,
                child: Icon(
                    escuchando
                        ? Icons.mic_off
                        : Icons.mic),
                onPressed: escucharVoz,
              ),

              const SizedBox(height: 10),

              // ➕ Crear manual
              FloatingActionButton(
                heroTag: "crear",
                child: const Icon(Icons.add),
                onPressed: abrirDialogCrear,
              ),
            ],
          ),
        );
      },
    );
  }
}