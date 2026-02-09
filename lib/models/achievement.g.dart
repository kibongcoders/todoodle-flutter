// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 10;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      type: fields[1] as AchievementType,
      unlockedAt: fields[2] as DateTime?,
      currentProgress: fields[3] as int,
      targetProgress: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.unlockedAt)
      ..writeByte(3)
      ..write(obj.currentProgress)
      ..writeByte(4)
      ..write(obj.targetProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementTypeAdapter extends TypeAdapter<AchievementType> {
  @override
  final int typeId = 11;

  @override
  AchievementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementType.firstTodo;
      case 1:
        return AchievementType.complete10;
      case 2:
        return AchievementType.complete50;
      case 3:
        return AchievementType.complete100;
      case 4:
        return AchievementType.complete500;
      case 5:
        return AchievementType.streak3;
      case 6:
        return AchievementType.streak7;
      case 7:
        return AchievementType.streak30;
      case 8:
        return AchievementType.plantGrown;
      case 9:
        return AchievementType.forest10;
      case 10:
        return AchievementType.focusHour;
      case 11:
        return AchievementType.focusDay;
      case 12:
        return AchievementType.earlyBird;
      case 13:
        return AchievementType.nightOwl;
      case 14:
        return AchievementType.perfectDay;
      default:
        return AchievementType.firstTodo;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementType obj) {
    switch (obj) {
      case AchievementType.firstTodo:
        writer.writeByte(0);
        break;
      case AchievementType.complete10:
        writer.writeByte(1);
        break;
      case AchievementType.complete50:
        writer.writeByte(2);
        break;
      case AchievementType.complete100:
        writer.writeByte(3);
        break;
      case AchievementType.complete500:
        writer.writeByte(4);
        break;
      case AchievementType.streak3:
        writer.writeByte(5);
        break;
      case AchievementType.streak7:
        writer.writeByte(6);
        break;
      case AchievementType.streak30:
        writer.writeByte(7);
        break;
      case AchievementType.plantGrown:
        writer.writeByte(8);
        break;
      case AchievementType.forest10:
        writer.writeByte(9);
        break;
      case AchievementType.focusHour:
        writer.writeByte(10);
        break;
      case AchievementType.focusDay:
        writer.writeByte(11);
        break;
      case AchievementType.earlyBird:
        writer.writeByte(12);
        break;
      case AchievementType.nightOwl:
        writer.writeByte(13);
        break;
      case AchievementType.perfectDay:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
