// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_unregistered_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUnregisteredUserModelAdapter
    extends TypeAdapter<HiveUnregisteredUserModel> {
  @override
  final typeId = 3;

  @override
  HiveUnregisteredUserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUnregisteredUserModel(
      name: fields[0] as String,
      defaultEmail: fields[1] as String,
      emails: (fields[2] as List)?.cast<String>(),
      photo: fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUnregisteredUserModel obj) {
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
