// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = 3;

  @override
  MedicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      takenStatus: (fields[3] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<int, bool>())),
      frequency: fields[4] as int,
      times: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.takenStatus)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.times);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
