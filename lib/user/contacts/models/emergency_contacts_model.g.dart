// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contacts_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmergencyContactsModelAdapter
    extends TypeAdapter<EmergencyContactsModel> {
  @override
  final int typeId = 1;

  @override
  EmergencyContactsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyContactsModel(
      id: fields[0] as String,
      name: fields[1] as String,
      relationship: fields[2] as String,
      phone: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContactsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
