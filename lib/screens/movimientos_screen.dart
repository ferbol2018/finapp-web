import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import '../models/movimiento.dart';
import '../services/api_service.dart';
import '../widgets/crear_movimiento_dialog.dart';
import '../widgets/movimiento_tile.dart';
import '../services/sound_service.dart';

class MovimientosScreen extends StatefulWidget {
  final String nombre;

  const MovimientosScreen({super.key, required this.nombre});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen>
    with SingleTickerProviderStateMixin {

  late Future<List<Movimiento>> movimientosFuture;
  late stt.SpeechToText speech;
  final AudioPlayer player = AudioPlayer();

  bool escuchando = false;
  String textoEscuchado = "";

  late AnimationController _animController;

  final SoundService soundService = SoundService();

  @override
  void initState() {
    super.initState();
    cargarMovimientos();
    speech = stt.SpeechToText();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);
  }

  void cargarMovimientos() {
    movimientosFuture = ApiService.obtenerMovimientos();
  }

  @override
  void dispose() {
    speech.stop();
    _animController.dispose();
    super.dispose();
  }

  Future<void> sonidoInicio() async {
    await soundService.playStart();
  }

  Future<void> sonidoFin() async {
    await soundService.playStop();
  }

  Future<void> escucharVoz() async {
    if (escuchando) {
      await speech.stop();
      await sonidoFin();
      setState(() {
        escuchando = false;
        textoEscuchado = "";
      });
      return;
    }

    bool disponible = await speech.initialize();

    if (!disponible) return;

    await sonidoInicio();

    setState(() {
      escuchando = true;
      textoEscuchado = "";
    });

    speech.listen(
      localeId: "es_CO",
      partialResults: true,
      onResult: (result) async {
        setState(() {
          textoEscuchado = result.recognizedWords;
        });

        if (result.finalResult) {
          await speech.stop();
          await sonidoFin();
          setState(() => escuchando = false);

          if (textoEscuchado.isNotEmpty) {
            analizarYConfirmar(textoEscuchado);
          }
        }
      },
    );
  }

  Future<void> analizarYConfirmar(String texto) async {
    final data = await ApiService.analizarTexto(texto);

    final tipo = data["tipo"];
    final monto = data["monto"];
    final categoria = data["categoria"];
    final descripcion = data["descripcion"];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar movimiento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tipo: $tipo"),
            Text("Monto: \$ $monto"),
            Text("Categoría: $categoria"),
            const SizedBox(height: 10),
            Text(descripcion),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => textoEscuchado = "");
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => textoEscuchado = "");
              escucharVoz();
            },
            child: const Text("Repetir"),
          ),
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
          setState(() => cargarMovimientos());
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

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final mov = lista[i];

                    return MovimientoTile(
                      movimiento: mov,
                      onDelete: () async {
                        final confirmar =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                                const Text("Eliminar movimiento"),
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
                          setState(() => cargarMovimientos());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              ScaleTransition(
                scale: _animController,
                child: FloatingActionButton(
                  heroTag: "voz",
                  backgroundColor:
                      escuchando ? Colors.red : Colors.blue,
                  child: Icon(
                      escuchando
                          ? Icons.mic
                          : Icons.mic_none),
                  onPressed: escucharVoz,
                ),
              ),

              const SizedBox(height: 10),

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