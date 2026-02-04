// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 5;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as String,
      type: fields[1] as PlantType,
      growthStage: fields[2] as int,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      isFullyGrown: fields[5] as bool,
      positionX: fields[6] as int,
      positionY: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.growthStage)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.isFullyGrown)
      ..writeByte(6)
      ..write(obj.positionX)
      ..writeByte(7)
      ..write(obj.positionY);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlantTypeAdapter extends TypeAdapter<PlantType> {
  @override
  final int typeId = 4;

  @override
  PlantType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlantType.grass;
      case 1:
        return PlantType.flower;
      case 2:
        return PlantType.tree;
      default:
        return PlantType.grass;
    }
  }

  @override
  void write(BinaryWriter writer, PlantType obj) {
    switch (obj) {
      case PlantType.grass:
        writer.writeByte(0);
        break;
      case PlantType.flower:
        writer.writeByte(1);
        break;
      case PlantType.tree:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
