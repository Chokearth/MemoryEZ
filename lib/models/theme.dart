import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme.g.dart';

@JsonSerializable()
class FlashTheme {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? uid;
  String name;
  @ColorSerializer()
  Color color;
  @JsonKey(defaultValue: 0)
  int cardCount;
  @JsonKey(defaultValue: false)
  bool public;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? ownerId;

  FlashTheme({
    required this.name,
    required this.color,
    this.cardCount = 0,
    this.public = false,
  });

  factory FlashTheme.fromJson(Map<String, dynamic> json) =>
      _$FlashThemeFromJson(json);

  factory FlashTheme.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return FlashTheme.fromJson(data)..uid = snapshot.id;
  }

  get colorAccent =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Map<String, dynamic> toJson() => _$FlashThemeToJson(this);

  Future<List<Flashcard>> getFlashcards() async {
    CollectionReference flashcards = FirebaseFirestore.instance
        .collection('themes')
        .doc(uid)
        .collection('cards');
    QuerySnapshot snapshot = await flashcards.get();
    return snapshot.docs.map(Flashcard.fromSnapshot).toList();
  }

  Future<String> create() async {
    CollectionReference themes =
        FirebaseFirestore.instance.collection('themes');
    Map<String, dynamic> json = toJson();
    json['ownerId'] = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference doc = await themes.add(json);
    uid = doc.id;
    return doc.id;
  }

  Future<void> clone() async {
    var cards = await getFlashcards();
    public = false;
    await create();
    await Future.forEach(cards, (card) async {
      card.uid = await addCard(card.front, card.back);
    });
  }

  Future<void> update() async {
    CollectionReference themes =
        FirebaseFirestore.instance.collection('themes');
    await themes.doc(uid).update(toJson());
  }

  Future<String> addCard(String front, String back) async {
    CollectionReference flashcards = FirebaseFirestore.instance
        .collection('themes')
        .doc(uid)
        .collection('cards');
    DocumentReference doc = await flashcards.add({
      'front': front,
      'back': back,
    });
    return doc.id;
  }

  Future<void> deleteCard(String front) async {
    CollectionReference flashcards = FirebaseFirestore.instance
        .collection('themes')
        .doc(uid)
        .collection('cards');
    QuerySnapshot snapshot =
        await flashcards.where('front', isEqualTo: front).get();
    await snapshot.docs.first.reference.delete();
  }

  Future<void> updateCard(String front, String back) async {
    CollectionReference flashcards = FirebaseFirestore.instance
        .collection('themes')
        .doc(uid)
        .collection('cards');
    QuerySnapshot snapshot =
        await flashcards.where('front', isEqualTo: front).get();
    await snapshot.docs.first.reference.update({
      'front': front,
      'back': back,
    });
  }

  Future<void> delete() async {
    CollectionReference themes =
        FirebaseFirestore.instance.collection('themes');
    await themes.doc(uid).delete();
  }

  get isMine => FirebaseAuth.instance.currentUser!.uid == ownerId;
}

@JsonSerializable()
class Flashcard {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String uid;
  String front;
  String back;

  Flashcard({
    this.front = '',
    this.back = '',
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);

  factory Flashcard.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Flashcard.fromJson(data)..uid = snapshot.id;
  }

  Map<String, dynamic> toJson() => _$FlashcardToJson(this);
}

class ColorSerializer implements JsonConverter<Color, List<dynamic>> {
  const ColorSerializer();

  @override
  Color fromJson(List<dynamic> json) {
    return Color.fromRGBO(json[0], json[1], json[2], 1);
  }

  @override
  List<dynamic> toJson(Color object) {
    return [object.red, object.green, object.blue];
  }
}
