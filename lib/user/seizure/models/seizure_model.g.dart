// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seizure_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeizureModelAdapter extends TypeAdapter<SeizureModel> {
  @override
  final int typeId = 2;

  @override
  SeizureModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeizureModel(
      id: fields[0] as String,
      seizureDateTime: fields[1] as DateTime,
      seizureTypes: (fields[2] as List).cast<String>(),
      durationMinutes: fields[3] as int,
      durationSeconds: fields[4] as int,
      triggers: (fields[5] as List).cast<String>(),
      notes: fields[6] as String?,
      isAutoDetected: fields[7] as bool,
      isSynced: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SeizureModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.seizureDateTime)
      ..writeByte(2)
      ..write(obj.seizureTypes)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.triggers)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isAutoDetected)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeizureModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
