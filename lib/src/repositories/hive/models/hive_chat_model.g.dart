// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveChatModelAdapter extends TypeAdapter<HiveChatModel> {
  @override
  final typeId = 0;

  @override
  HiveChatModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatModel(
      documentID: fields[0] as String,
      private: fields[1] as bool,
      members: (fields[2] as List)?.cast<HiveUserModel>(),
      name: fields[3] as String,
      photoUrl: fields[4] as String,
      createdAt: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.documentID)
      ..writeByte(1)
      ..write(obj.private)
      ..writeByte(2)
      ..write(obj.members)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
