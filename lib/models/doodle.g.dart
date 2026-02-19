// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doodle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoodleAdapter extends TypeAdapter<Doodle> {
  @override
  final int typeId = 14;

  @override
  Doodle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Doodle(
      id: fields[0] as String,
      type: fields[1] as DoodleType,
      currentStroke: fields[2] as int,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      isCompleted: fields[5] as bool,
      pageIndex: fields[6] as int,
      positionIndex: fields[7] as int,
      colorIndex: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Doodle obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.currentStroke)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.pageIndex)
      ..writeByte(7)
      ..write(obj.positionIndex)
      ..writeByte(8)
      ..write(obj.colorIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoodleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DoodleCategoryAdapter extends TypeAdapter<DoodleCategory> {
  @override
  final int typeId = 12;

  @override
  DoodleCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DoodleCategory.simple;
      case 1:
        return DoodleCategory.medium;
      case 2:
        return DoodleCategory.complex;
      case 3:
        return DoodleCategory.rare;
      default:
        return DoodleCategory.simple;
    }
  }

  @override
  void write(BinaryWriter writer, DoodleCategory obj) {
    switch (obj) {
      case DoodleCategory.simple:
        writer.writeByte(0);
        break;
      case DoodleCategory.medium:
        writer.writeByte(1);
        break;
      case DoodleCategory.complex:
        writer.writeByte(2);
        break;
      case DoodleCategory.rare:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoodleCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DoodleTypeAdapter extends TypeAdapter<DoodleType> {
  @override
  final int typeId = 13;

  @override
  DoodleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DoodleType.star;
      case 1:
        return DoodleType.heart;
      case 2:
        return DoodleType.cloud;
      case 3:
        return DoodleType.moon;
      case 4:
        return DoodleType.house;
      case 5:
        return DoodleType.flower;
      case 6:
        return DoodleType.boat;
      case 7:
        return DoodleType.balloon;
      case 8:
        return DoodleType.tree;
      case 9:
        return DoodleType.bicycle;
      case 10:
        return DoodleType.rocket;
      case 11:
        return DoodleType.cat;
      case 12:
        return DoodleType.rainbowStar;
      case 13:
        return DoodleType.crown;
      case 14:
        return DoodleType.diamond;
      default:
        return DoodleType.star;
    }
  }

  @override
  void write(BinaryWriter writer, DoodleType obj) {
    switch (obj) {
      case DoodleType.star:
        writer.writeByte(0);
        break;
      case DoodleType.heart:
        writer.writeByte(1);
        break;
      case DoodleType.cloud:
        writer.writeByte(2);
        break;
      case DoodleType.moon:
        writer.writeByte(3);
        break;
      case DoodleType.house:
        writer.writeByte(4);
        break;
      case DoodleType.flower:
        writer.writeByte(5);
        break;
      case DoodleType.boat:
        writer.writeByte(6);
        break;
      case DoodleType.balloon:
        writer.writeByte(7);
        break;
      case DoodleType.tree:
        writer.writeByte(8);
        break;
      case DoodleType.bicycle:
        writer.writeByte(9);
        break;
      case DoodleType.rocket:
        writer.writeByte(10);
        break;
      case DoodleType.cat:
        writer.writeByte(11);
        break;
      case DoodleType.rainbowStar:
        writer.writeByte(12);
        break;
      case DoodleType.crown:
        writer.writeByte(13);
        break;
      case DoodleType.diamond:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoodleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
