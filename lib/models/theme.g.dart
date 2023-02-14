// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashTheme _$FlashThemeFromJson(Map<String, dynamic> json) => FlashTheme(
      name: json['name'] as String,
      color: const ColorSerializer().fromJson(json['color'] as List),
      cardCount: json['cardCount'] as int? ?? 0,
      public: json['public'] as bool? ?? false,
    )..ownerId = json['ownerId'] as String?;

Map<String, dynamic> _$FlashThemeToJson(FlashTheme instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': const ColorSerializer().toJson(instance.color),
      'cardCount': instance.cardCount,
      'public': instance.public,
      'ownerId': instance.ownerId,
    };

Flashcard _$FlashcardFromJson(Map<String, dynamic> json) => Flashcard(
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
    );

Map<String, dynamic> _$FlashcardToJson(Flashcard instance) => <String, dynamic>{
      'front': instance.front,
      'back': instance.back,
    };
