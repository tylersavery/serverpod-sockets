import 'package:flutter/material.dart';
import 'package:flutter_fridge_client/flutter_fridge_client.dart';
import 'package:flutter_fridge_flutter/main.dart';
import 'package:flutter_fridge_flutter/src/utils.dart';

const List<String> colors = [
  "#000000",
  "#00008B",
  "#800000",
  "#556B2F",
  "#4B0082",
  "#E7691D",
];

const MIN_X = 8;
const MIN_Y = 64;

class FridgeContainer extends StatefulWidget {
  const FridgeContainer({super.key});

  @override
  State<FridgeContainer> createState() => _FridgeContainerState();
}

class _FridgeContainerState extends State<FridgeContainer> {
  late final StreamingConnectionHandler connectionHandler;
  final GlobalKey _key = GlobalKey();

  List<Magnet> magnets = [];
  int connectionsCount = 0;
  int animationDurationMs = 300;

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
      if (message is ConnectionChangeMessage) {
        setState(() {
          connectionsCount = message.count;
        });
      }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final MagnetCreateMessage? message = await showModalBottomSheet(
              backgroundColor: Colors.white,
              context: context,
              builder: (context) {
                return const CreateMessageModal();
              }) as MagnetCreateMessage?;

          if (message != null && message.text.isNotEmpty) {
            client.fridge.sendStreamMessage(message);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          key: _key,
          children: [
            ...magnets.map(
              (m) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: animationDurationMs),
                  key: Key(m.identifier),
                  left: m.x.toDouble(),
                  top: m.y.toDouble(),
                  child: Draggable(
                    feedback: Opacity(opacity: 0.5, child: MagnetContainer(m)),
                    childWhenDragging: Container(),
                    onDragStarted: () {
                      setState(() {
                        animationDurationMs = 0;
                      });
                    },
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

                        Future.delayed(const Duration(milliseconds: 300)).then((_) {
                          setState(() {
                            animationDurationMs = 300;
                          });
                        });
                      }
                    },
                    child: MagnetContainer(m),
                  ),
                );
              },
            ).toList(),
            Align(
              alignment: Alignment.topRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                      child: Text(
                        "$connectionsCount User${connectionsCount == 1 ? '' : 's'}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateMessageModal extends StatefulWidget {
  const CreateMessageModal({
    super.key,
  });

  @override
  State<CreateMessageModal> createState() => _CreateMessageModalState();
}

class _CreateMessageModalState extends State<CreateMessageModal> {
  String selectedColor = "#000000";
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Add Magnet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Message'),
              onSubmitted: (val) {
                Navigator.of(context).pop(MagnetCreateMessage(
                  x: MIN_X,
                  y: MIN_Y,
                  text: val,
                  color: selectedColor,
                ));
              },
              controller: messageController,
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: colors
                .map((e) => InkWell(
                      onTap: () {
                        setState(() {
                          selectedColor = e;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: selectedColor == e ? Border.all(color: Colors.lightGreen, width: 5) : null,
                          color: hexToColor(e),
                        ),
                        width: 50,
                        height: 40,
                      ),
                    ))
                .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    MagnetCreateMessage(
                      x: MIN_X,
                      y: MIN_Y,
                      text: messageController.text,
                      color: selectedColor,
                    ),
                  );
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: hexToColor(selectedColor),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [
            BoxShadow(offset: Offset(3, 3), spreadRadius: 0, blurRadius: 0, color: Colors.black12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
          child: Text(
            m.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: hexToColor(m.color),
            ),
          ),
        ),
      ),
    );
  }
}
