// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoTemplateAdapter extends TypeAdapter<TodoTemplate> {
  @override
  final int typeId = 8;

  @override
  TodoTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      emoji: fields[3] as String,
      items: (fields[4] as List).cast<TemplateItem>(),
      createdAt: fields[5] as DateTime,
      useCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TodoTemplate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.useCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateItemAdapter extends TypeAdapter<TemplateItem> {
  @override
  final int typeId = 9;

  @override
  TemplateItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateItem(
      title: fields[0] as String,
      description: fields[1] as String?,
      priority: fields[2] as Priority,
      categoryIds: (fields[3] as List?)?.cast<String>(),
      estimatedMinutes: fields[4] as int?,
      tags: (fields[5] as List?)?.cast<String>(),
      dueDayOffset: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.categoryIds)
      ..writeByte(4)
      ..write(obj.estimatedMinutes)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.dueDayOffset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
