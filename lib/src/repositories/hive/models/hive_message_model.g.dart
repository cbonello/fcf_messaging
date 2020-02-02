// ignore_for_file: always_specify_types, prefer_final_locals, avoid_as

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMessageModelAdapter extends TypeAdapter<HiveMessageModel> {
  @override
  final typeId = 3;

  @override
  HiveMessageModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMessageModel(
      documentID: fields[0] as String,
      sender: fields[1] as String,
      type: fields[3] as int,
      text: fields[2] as String,
      timestamp: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMessageModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.documentID)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.timestamp);
  }
}
