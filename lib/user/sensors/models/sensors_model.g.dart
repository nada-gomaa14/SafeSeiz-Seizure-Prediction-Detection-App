// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensors_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SensorReadingModelAdapter extends TypeAdapter<SensorReadingModel> {
  @override
  final int typeId = 4;

  @override
  SensorReadingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SensorReadingModel(
      timestamp: fields[0] as String,
      hr: fields[1] as double,
      spo2: fields[2] as double,
      rri: fields[3] as double,
      accelX: fields[4] as double,
      accelY: fields[5] as double,
      accelZ: fields[6] as double,
      gyroX: fields[7] as double,
      gyroY: fields[8] as double,
      gyroZ: fields[9] as double,
      label: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SensorReadingModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.hr)
      ..writeByte(2)
      ..write(obj.spo2)
      ..writeByte(3)
      ..write(obj.rri)
      ..writeByte(4)
      ..write(obj.accelX)
      ..writeByte(5)
      ..write(obj.accelY)
      ..writeByte(6)
      ..write(obj.accelZ)
      ..writeByte(7)
      ..write(obj.gyroX)
      ..writeByte(8)
      ..write(obj.gyroY)
      ..writeByte(9)
      ..write(obj.gyroZ)
      ..writeByte(10)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorReadingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
