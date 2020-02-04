// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_registered_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveRegisteredUserModelAdapter
    extends TypeAdapter<HiveRegisteredUserModel> {
  @override
  final typeId = 2;

  @override
  HiveRegisteredUserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveRegisteredUserModel(
      userID: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      status: fields[3] as String,
      photoUrl: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveRegisteredUserModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userID)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.photoUrl);
  }
}
