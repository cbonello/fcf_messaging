// ignore_for_file: always_specify_types, prefer_final_locals, avoid_as

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveContactModelAdapter extends TypeAdapter<HiveContactModel> {
  @override
  final typeId = 2;

  @override
  HiveContactModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveContactModel(
      documentID: fields[0] as String,
      name: fields[1] as String,
      emails: (fields[3] as List)?.cast<String>(),
      photoUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveContactModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.documentID)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.emails);
  }
}
