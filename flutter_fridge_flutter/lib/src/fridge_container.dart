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
    return Stack(
      children: [
        Image.asset(
          "assets/background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Fridge"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final MagnetCreateMessage? message = await showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  builder: (context) {
                    return CreateMessageModal();
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
        ),
      ],
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
  List<String> colors = ["#000000", "#00008B", "#800000", "#556B2F", "#4B0082", "#FFA500"];
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
          Text(
            'New Magnet',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Message'),
              onSubmitted: (val) {
                Navigator.of(context).pop(MagnetCreateMessage(
                  x: 0,
                  y: 0,
                  text: val,
                  color: selectedColor,
                ));
              },
              controller: messageController,
            ),
          ),
          Text(
            'Color',
            style: Theme.of(context).textTheme.headlineSmall,
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
                    Navigator.of(context).pop(MagnetCreateMessage(
                      x: 0,
                      y: 0,
                      text: messageController.text,
                      color: selectedColor,
                    ));
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(fontSize: 20, color: hexToColor(selectedColor)),
                  )),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(spreadRadius: 3, blurRadius: 5, color: Colors.black12),
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
