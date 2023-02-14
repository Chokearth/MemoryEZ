import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/models/theme.dart';
import 'package:memory_ez/widgets/form/checkbox.dart';

import '../../widgets/form/color_picker.dart';

class CardObject {
  String? uid;
  String front;
  String back;
  bool isDeleted;
  FocusNode frontFocus = FocusNode();

  final String keyS =
      (DateTime.now().millisecondsSinceEpoch + Random().nextInt(2 ^ 32))
          .toString();

  CardObject({
    this.uid,
    this.front = '',
    this.back = '',
    this.isDeleted = false,
  });

  factory CardObject.fromFlashcard(Flashcard flashcard) {
    return CardObject(
      uid: flashcard.uid,
      front: flashcard.front,
      back: flashcard.back,
    );
  }

  get key => uid ?? keyS;
}

class ThemeEdit extends StatefulWidget {
  final FlashTheme theme;
  Future<List<CardObject>> cardsFuture = Future.value([]);
  List<CardObject> cards = [];

  ThemeEdit({Key? key, required this.theme}) : super(key: key) {
    if (theme.uid != null) {
      cardsFuture = theme.getFlashcards().then(
          (value) => value.map((e) => CardObject.fromFlashcard(e)).toList());
      cardsFuture.then((value) => cards = value);
    }
  }

  @override
  _ThemeEditState createState() => _ThemeEditState();

  Future<void> saveTheme(BuildContext context) async {
    theme.cardCount = cards.length;
    if (theme.uid == null) {
      await theme.create();
      await Future.forEach(cards, (card) async {
        card.uid = await theme.addCard(card.front, card.back);
      });
    } else {
      await theme.update();
      await Future.forEach(cards, (card) async {
        if (card.uid == null) {
          card.uid = await theme.addCard(card.front, card.back);
        } else if (card.isDeleted) {
          await theme.deleteCard(card.front);
        } else {
          await theme.updateCard(card.front, card.back);
        }
      });
    }
  }

  Future<void> deleteTheme(BuildContext context) async {
    if (theme.uid != null) {
      await theme.delete();
    }
  }
}

class _ThemeEditState extends State<ThemeEdit> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Theme Edit'),
        ),
        body: FutureBuilder(
            future: widget.cardsFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<CardObject>> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.hasData == true) {
                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: _buildThemeForm() + _buildCards(),
                                ),
                              ),
                            ),
                          ] +
                          _buildButtons(),
                    ),
                  ),
                );
              }

              return const Text("loading...");
            }));
  }

  List<Widget> _buildThemeForm() {
    return [
      TextFormField(
        initialValue: widget.theme.name,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
        onSaved: (value) {
          widget.theme.name = value!;
        },
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ColorFormField(
          label: 'Theme Color',
          initialValue: widget.theme.color,
          onSaved: (value) {
            if (value != null) {
              widget.theme.color = value;
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CheckboxFormField(
          label: 'Is Public',
          initialValue: widget.theme.public,
          onSaved: (value) {
            if (value != null) {
              widget.theme.public = value;
            }
          },
        ),
      ),
    ];
  }

  List<Widget> _buildButtons() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await widget.saveTheme(context);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await widget.deleteTheme(context);
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCards() {
    return [
      Column(
        children: [
          for (var card in widget.cards)
            if (!card.isDeleted)
              Card(
                key: Key(card.key),
                child: ListTile(
                  title: TextFormField(
                    initialValue: card.front,
                    decoration: const InputDecoration(
                      labelText: 'Front',
                    ),
                    focusNode: card.frontFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a front';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      card.front = value!;
                    },
                  ),
                  subtitle: TextFormField(
                    initialValue: card.back,
                    decoration: const InputDecoration(
                      labelText: 'Back',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a back';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      card.back = value!;
                    },
                  ),
                  trailing: IconButton(
                    alignment: Alignment.topRight,
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        if (card.uid != null) {
                          card.isDeleted = true;
                        } else {
                          widget.cards.remove(card);
                        }
                      });
                    },
                  ),
                ),
              ),
        ],
      ),
      ElevatedButton(
        onPressed: () {
          setState(() {
            CardObject card = CardObject();
            widget.cards.add(card);
            card.frontFocus.requestFocus();
          });
        },
        child: const Text('Add Card'),
      ),
    ];
  }
}
