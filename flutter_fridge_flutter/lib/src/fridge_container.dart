import 'package:flutter/material.dart';
import 'package:flutter_fridge_client/flutter_fridge_client.dart';
import 'package:flutter_fridge_flutter/main.dart';
import 'package:flutter_fridge_flutter/src/utils.dart';

class FridgeContainer extends StatefulWidget {
  const FridgeContainer({super.key});

  @override
  State<FridgeContainer> createState() => _FridgeContainerState();
}

class _FridgeContainerState extends State<FridgeContainer> {
  late final StreamingConnectionHandler connectionHandler;
  final GlobalKey _key = GlobalKey();

  List<Magnet> magnets = [];

  @override
  void initState() {
    super.initState();

    listenForUpdates();

    connectionHandler = StreamingConnectionHandler(
      client: client,
      listener: (connectionState) {
        setState(() {});
      },
    );
    connectionHandler.connect();
  }

  Future<void> listenForUpdates() async {
    await for (var message in client.fridge.stream) {
      if (message is MagnetStateMessage) {
        setState(() {
          magnets = message.magnets;
        });
      }

      if (message is MagnetAppendMessage) {
        setState(() {
          magnets = [...magnets, message.magnet];
        });
      }

      if (message is MagnetUpdateMessage) {
        final index = magnets.indexWhere((m) => m.identifier == message.identifier);
        if (index > -1) {
          Magnet updatedMagnet = magnets[index];
          updatedMagnet.x = message.x;
          updatedMagnet.y = message.y;

          final updatedMagnets = [...magnets]
            ..removeAt(index)
            ..insert(index, updatedMagnet);

          setState(() {
            magnets = updatedMagnets;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fridge"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final message = MagnetCreateMessage(
            x: 0,
            y: 0,
            text: "Test",
            color: "#ffff00",
          );

          client.fridge.sendStreamMessage(message);
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black45,
        child: Stack(
          key: _key,
          children: magnets.map(
            (m) {
              return Positioned(
                left: m.x.toDouble(),
                top: m.y.toDouble(),
                child: Draggable(
                  feedback: Opacity(opacity: 0.5, child: MagnetContainer(m)),
                  childWhenDragging: Container(),
                  onDragEnd: (dragDetails) {
                    final RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
                    final Offset? position = box?.localToGlobal(Offset.zero);

                    if (position != null) {
                      final x = dragDetails.offset.dx - position.dx;
                      final y = dragDetails.offset.dy - position.dy;

                      final message = MagnetUpdateMessage(
                        identifier: m.identifier,
                        x: x.round(),
                        y: y.round(),
                      );

                      client.fridge.sendStreamMessage(message);
                    }
                  },
                  child: MagnetContainer(m),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class MagnetContainer extends StatelessWidget {
  final Magnet m;
  const MagnetContainer(
    this.m, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: hexToColor(m.color),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            m.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
