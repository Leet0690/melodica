// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'melody.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MelodyAdapter extends TypeAdapter<Melody> {
  @override
  final int typeId = 0;

  @override
  Melody read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Melody(
      id: fields[0] as String,
      name: fields[1] as String,
      mode: fields[2] as String,
      notes: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Melody obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mode)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MelodyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
