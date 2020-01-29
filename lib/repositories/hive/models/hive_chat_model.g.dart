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
      membersData: (fields[2] as List)?.cast<HiveChatMemberModel>(),
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
      ..write(obj.membersData)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}

class HiveChatMemberModelAdapter extends TypeAdapter<HiveChatMemberModel> {
  @override
  final typeId = 1;

  @override
  HiveChatMemberModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatMemberModel(
      userID: fields[0] as String,
      name: fields[1] as String,
      photoUrl: fields[2] as String,
      status: fields[3] as String,
      createdAt: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatMemberModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userID)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
