// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 7;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      id: fields[0] as String,
      todoId: fields[1] as String?,
      type: fields[2] as FocusSessionType,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      plannedDuration: fields[5] as int,
      actualDuration: fields[6] as int,
      wasCompleted: fields[7] as bool,
      wasInterrupted: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.todoId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.plannedDuration)
      ..writeByte(6)
      ..write(obj.actualDuration)
      ..writeByte(7)
      ..write(obj.wasCompleted)
      ..writeByte(8)
      ..write(obj.wasInterrupted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusSessionTypeAdapter extends TypeAdapter<FocusSessionType> {
  @override
  final int typeId = 6;

  @override
  FocusSessionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FocusSessionType.work;
      case 1:
        return FocusSessionType.shortBreak;
      case 2:
        return FocusSessionType.longBreak;
      default:
        return FocusSessionType.work;
    }
  }

  @override
  void write(BinaryWriter writer, FocusSessionType obj) {
    switch (obj) {
      case FocusSessionType.work:
        writer.writeByte(0);
        break;
      case FocusSessionType.shortBreak:
        writer.writeByte(1);
        break;
      case FocusSessionType.longBreak:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
