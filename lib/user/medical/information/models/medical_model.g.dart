// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalModelAdapter extends TypeAdapter<MedicalModel> {
  @override
  final int typeId = 0;

  @override
  MedicalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalModel(
      notDiagnosed: fields[0] as bool,
      diagnosisDate: fields[1] as DateTime?,
      seizureTypes: (fields[2] as List).cast<String>(),
      seizureFrequency: fields[3] as String?,
      height: fields[4] as double?,
      weight: fields[5] as double?,
      bloodType: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.notDiagnosed)
      ..writeByte(1)
      ..write(obj.diagnosisDate)
      ..writeByte(2)
      ..write(obj.seizureTypes)
      ..writeByte(3)
      ..write(obj.seizureFrequency)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.bloodType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
