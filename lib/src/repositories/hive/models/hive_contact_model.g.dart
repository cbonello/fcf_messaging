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
      name: fields[0] as String,
      defaultEmail: fields[1] as String,
      emails: (fields[2] as List)?.cast<String>(),
      photo: fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveContactModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.defaultEmail)
      ..writeByte(2)
      ..write(obj.emails)
      ..writeByte(3)
      ..write(obj.photo);
  }
}
