// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      priority: fields[4] as Priority,
      categoryIds: (fields[5] as List?)?.cast<String>(),
      createdAt: fields[6] as DateTime,
      dueDate: fields[7] as DateTime?,
      startDate: fields[8] as DateTime?,
      parentId: fields[9] as String?,
      recurrence: fields[10] as Recurrence,
      recurrenceDays: (fields[11] as List?)?.cast<int>(),
      notificationEnabled: fields[12] as bool,
      reminderOffsets: (fields[13] as List?)?.cast<int>(),
      completionHistory: (fields[14] as List?)?.cast<DateTime>(),
      sortOrder: fields[15] as int,
      isArchived: fields[16] as bool,
      deletedAt: fields[17] as DateTime?,
      tags: (fields[18] as List?)?.cast<String>(),
      estimatedMinutes: fields[19] as int?,
      actualMinutes: fields[20] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.categoryIds)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.parentId)
      ..writeByte(10)
      ..write(obj.recurrence)
      ..writeByte(11)
      ..write(obj.recurrenceDays)
      ..writeByte(12)
      ..write(obj.notificationEnabled)
      ..writeByte(13)
      ..write(obj.reminderOffsets)
      ..writeByte(14)
      ..write(obj.completionHistory)
      ..writeByte(15)
      ..write(obj.sortOrder)
      ..writeByte(16)
      ..write(obj.isArchived)
      ..writeByte(17)
      ..write(obj.deletedAt)
      ..writeByte(18)
      ..write(obj.tags)
      ..writeByte(19)
      ..write(obj.estimatedMinutes)
      ..writeByte(20)
      ..write(obj.actualMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 1;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.veryLow;
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      case 4:
        return Priority.veryHigh;
      default:
        return Priority.veryLow;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.veryLow:
        writer.writeByte(0);
        break;
      case Priority.low:
        writer.writeByte(1);
        break;
      case Priority.medium:
        writer.writeByte(2);
        break;
      case Priority.high:
        writer.writeByte(3);
        break;
      case Priority.veryHigh:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceAdapter extends TypeAdapter<Recurrence> {
  @override
  final int typeId = 2;

  @override
  Recurrence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Recurrence.none;
      case 1:
        return Recurrence.daily;
      case 2:
        return Recurrence.weekly;
      case 3:
        return Recurrence.monthly;
      case 4:
        return Recurrence.custom;
      default:
        return Recurrence.none;
    }
  }

  @override
  void write(BinaryWriter writer, Recurrence obj) {
    switch (obj) {
      case Recurrence.none:
        writer.writeByte(0);
        break;
      case Recurrence.daily:
        writer.writeByte(1);
        break;
      case Recurrence.weekly:
        writer.writeByte(2);
        break;
      case Recurrence.monthly:
        writer.writeByte(3);
        break;
      case Recurrence.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
