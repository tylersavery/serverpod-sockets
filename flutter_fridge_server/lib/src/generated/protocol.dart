/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;
import 'connection_change_message.dart' as _i2;
import 'create_magnet_message.dart' as _i3;
import 'magnet.dart' as _i4;
import 'magnet_state_message.dart' as _i5;
import 'new_magnet_message.dart' as _i6;
import 'update_magnet_message.dart' as _i7;
import 'protocol.dart' as _i8;
import 'package:serverpod/protocol.dart' as _i9;
export 'connection_change_message.dart';
export 'create_magnet_message.dart';
export 'magnet.dart';
export 'magnet_state_message.dart';
export 'new_magnet_message.dart';
export 'update_magnet_message.dart'; // ignore_for_file: equal_keys_in_map

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.ConnectionChangeMessage) {
      return _i2.ConnectionChangeMessage.fromJson(data, this) as T;
    }
    if (t == _i3.MagnetCreateMessage) {
      return _i3.MagnetCreateMessage.fromJson(data, this) as T;
    }
    if (t == _i4.Magnet) {
      return _i4.Magnet.fromJson(data, this) as T;
    }
    if (t == _i5.MagnetStateMessage) {
      return _i5.MagnetStateMessage.fromJson(data, this) as T;
    }
    if (t == _i6.MagnetAppendMessage) {
      return _i6.MagnetAppendMessage.fromJson(data, this) as T;
    }
    if (t == _i7.MagnetUpdateMessage) {
      return _i7.MagnetUpdateMessage.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.ConnectionChangeMessage?>()) {
      return (data != null
          ? _i2.ConnectionChangeMessage.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i3.MagnetCreateMessage?>()) {
      return (data != null
          ? _i3.MagnetCreateMessage.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i4.Magnet?>()) {
      return (data != null ? _i4.Magnet.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i5.MagnetStateMessage?>()) {
      return (data != null ? _i5.MagnetStateMessage.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i6.MagnetAppendMessage?>()) {
      return (data != null
          ? _i6.MagnetAppendMessage.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i7.MagnetUpdateMessage?>()) {
      return (data != null
          ? _i7.MagnetUpdateMessage.fromJson(data, this)
          : null) as T;
    }
    if (t == List<_i8.Magnet>) {
      return (data as List).map((e) => deserialize<_i8.Magnet>(e)).toList()
          as dynamic;
    }
    try {
      return _i9.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.ConnectionChangeMessage) {
      return 'ConnectionChangeMessage';
    }
    if (data is _i3.MagnetCreateMessage) {
      return 'MagnetCreateMessage';
    }
    if (data is _i4.Magnet) {
      return 'Magnet';
    }
    if (data is _i5.MagnetStateMessage) {
      return 'MagnetStateMessage';
    }
    if (data is _i6.MagnetAppendMessage) {
      return 'MagnetAppendMessage';
    }
    if (data is _i7.MagnetUpdateMessage) {
      return 'MagnetUpdateMessage';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'ConnectionChangeMessage') {
      return deserialize<_i2.ConnectionChangeMessage>(data['data']);
    }
    if (data['className'] == 'MagnetCreateMessage') {
      return deserialize<_i3.MagnetCreateMessage>(data['data']);
    }
    if (data['className'] == 'Magnet') {
      return deserialize<_i4.Magnet>(data['data']);
    }
    if (data['className'] == 'MagnetStateMessage') {
      return deserialize<_i5.MagnetStateMessage>(data['data']);
    }
    if (data['className'] == 'MagnetAppendMessage') {
      return deserialize<_i6.MagnetAppendMessage>(data['data']);
    }
    if (data['className'] == 'MagnetUpdateMessage') {
      return deserialize<_i7.MagnetUpdateMessage>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i9.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i4.Magnet:
        return _i4.Magnet.t;
    }
    return null;
  }
}
