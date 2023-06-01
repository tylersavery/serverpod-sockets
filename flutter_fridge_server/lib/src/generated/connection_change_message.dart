/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

class ConnectionChangeMessage extends _i1.SerializableEntity {
  ConnectionChangeMessage({required this.count});

  factory ConnectionChangeMessage.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ConnectionChangeMessage(
        count:
            serializationManager.deserialize<int>(jsonSerialization['count']));
  }

  int count;

  @override
  Map<String, dynamic> toJson() {
    return {'count': count};
  }

  @override
  Map<String, dynamic> allToJson() {
    return {'count': count};
  }
}
