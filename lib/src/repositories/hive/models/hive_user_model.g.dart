// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserModelAdapter extends TypeAdapter<HiveUserModel> {
  @override
  final typeId = 2;

  @override
  HiveUserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserModel(
      type: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      userID: fields[3] as String,
      status: fields[4] as String,
      photoUrl: fields[5] as String,
      emails: (fields[6] as List)?.cast<String>(),
      photo: fields[7] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.userID)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.photoUrl)
      ..writeByte(6)
      ..write(obj.emails)
      ..writeByte(7)
      ..write(obj.photo);
  }
}
