import 'package:flutter_fridge_server/src/generated/protocol.dart';
import 'package:flutter_fridge_server/src/utils/strings.dart';
import 'package:serverpod/serverpod.dart';

const magnetChannel = "magnet-channel";

int connectionsCount = 0;

class FridgeEndpoint extends Endpoint {
  Future<void> _addMagnetToDatabase(Session session, Magnet magnet) async {
    await Magnet.insert(session, magnet);
  }

  @override
  Future<void> streamOpened(StreamingSession session) async {
    connectionsCount += 1;

    sendStreamMessage(session, ConnectionChangeMessage(count: connectionsCount));
    session.messages.postMessage(magnetChannel, ConnectionChangeMessage(count: connectionsCount), global: false);

    final magnets = await Magnet.find(session);

    sendStreamMessage(session, MagnetStateMessage(magnets: magnets));

    session.messages.addListener(magnetChannel, (update) {
      sendStreamMessage(session, update);
    });
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {
    connectionsCount -= 1;
    sendStreamMessage(session, ConnectionChangeMessage(count: connectionsCount));
    session.messages.postMessage(magnetChannel, ConnectionChangeMessage(count: connectionsCount), global: false);
  }

  @override
  Future<void> handleStreamMessage(
    StreamingSession session,
    SerializableEntity message,
  ) async {
    if (message is MagnetCreateMessage) {
      late String identifier;

      while (true) {
        identifier = generateRandomString(8);

        final exists = (await Magnet.find(session, where: (m) => m.identifier.equals(identifier))).isNotEmpty;
        if (!exists) {
          break;
        }
      }

      final magnet = Magnet(
        identifier: identifier,
        x: message.x,
        y: message.y,
        color: message.color,
        text: message.text,
        createdAt: DateTime.now(),
      );

      session.messages.postMessage(magnetChannel, MagnetAppendMessage(magnet: magnet), global: false);

      await _addMagnetToDatabase(session, magnet);
    }

    if (message is MagnetUpdateMessage) {
      final magnet = await Magnet.findSingleRow(session, where: (m) => m.identifier.equals(message.identifier));

      if (magnet != null) {
        magnet.x = message.x;
        magnet.y = message.y;
        session.messages.postMessage(magnetChannel, MagnetUpdateMessage(identifier: magnet.identifier, x: magnet.x, y: magnet.y), global: false);
        await Magnet.update(session, magnet);
      }
    }
  }
}
