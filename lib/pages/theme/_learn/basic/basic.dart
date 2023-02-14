import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_ez/models/theme.dart';
import 'package:memory_ez/pages/theme/_learn/basic/_end.dart';
import 'package:memory_ez/pages/theme/_learn/basic/_round_end.dart';
import 'package:memory_ez/widgets/card/card_face.dart';
import 'package:memory_ez/widgets/card/flippable_card.dart';
import 'package:memory_ez/widgets/my_draggable.dart';

class FlashcardLearn {
  final Flashcard card;
  bool validated = false;

  FlashcardLearn(this.card);
}

class Basic extends StatelessWidget {
  final FlashTheme theme;

  Basic({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(theme.name),
      ),
      body: FutureBuilder(
        future: theme.getFlashcards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Flashcard>> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Text("Document is empty");
          }

          if (snapshot.hasData == true) {
            return BasicContent(theme: theme, cards: snapshot.data!);
          }

          return const Text("loading...");
        },
      ),
    );
  }
}

class BasicContent extends StatefulWidget {
  final FlashTheme theme;
  final List<Flashcard> cards;
  late List<FlashcardLearn> cardsLearn;
  int index = 0;
  bool roundEnd = false;
  int prevRoundScore = 0;
  bool front = true;

  BasicContent({super.key, required this.theme, required this.cards}) {
    cardsLearn = cards.map((e) => FlashcardLearn(e)).toList()..shuffle();
  }

  @override
  _BasicContentState createState() => _BasicContentState();

  get card => cardsLearn[index].card;

  get validated => cardsLearn.where((e) => e.validated).length;

  get total => cardsLearn.length;

  get progress => validated / total;

  void next() {
    if (validated == total) {
      roundEnd = true;
      return;
    }
    front = true;

    do {
      index = index + 1;
      if (index >= cardsLearn.length) {
        index = 0;
        cardsLearn.shuffle();
        roundEnd = true;
      }
    } while (cardsLearn[index].validated);
  }

  void validate() {
    cardsLearn[index].validated = true;
    next();
  }
}

class _BasicContentState extends State<BasicContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgress(),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return LinearProgressIndicator(
      value: widget.progress,
      minHeight: 10,
      color: widget.theme.color,
      backgroundColor: widget.theme.colorAccent,
    );
  }

  Widget _buildContent() {
    return widget.roundEnd ? _buildRoundEnd() : _buildRound();
  }

  Widget _buildRoundEnd() {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _XIntent(_XIntentType.next),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const _XIntent(_XIntentType.next),
        LogicalKeySet(LogicalKeyboardKey.space): const _XIntent(_XIntentType.next),
      },
      actions: {
        _XIntent: CallbackAction<_XIntent>(
          onInvoke: (intent) {
            switch (intent.type) {
              case _XIntentType.next:
                setState(() {
                  widget.roundEnd = false;
                  widget.prevRoundScore = widget.validated;
                });
                break;
              case _XIntentType.validate:
                break;
              case _XIntentType.flip:
                break;
            }
            setState(() {});
          },
        ),
      },
      child: widget.total == widget.validated
          ? End(
              total: widget.total,
              onNext: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            )
          : RoundEnd(
              score: widget.validated,
              total: widget.total,
              prevScore: widget.prevRoundScore,
              onNext: () {
                setState(() {
                  widget.roundEnd = false;
                  widget.prevRoundScore = widget.validated;
                });
              },
            ),
    );
  }

  Widget _buildRound() {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _XIntent(_XIntentType.next),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const _XIntent(_XIntentType.validate),
        LogicalKeySet(LogicalKeyboardKey.space): const _XIntent(_XIntentType.flip),
      },
      actions: {
        _XIntent: CallbackAction<_XIntent>(
          onInvoke: (intent) {
            switch (intent.type) {
              case _XIntentType.next:
                widget.next();
                break;
              case _XIntentType.validate:
                widget.validate();
                break;
              case _XIntentType.flip:
                setState(() {
                  widget.front = !widget.front;
                });
                break;
            }
            setState(() {});
          },
        ),
      },
      child: Center(
          child: MyDraggable(
        childWidth: 300,
        childHeight: 300,
        buildFeedback: (x, y) => _buildCard(x, y),
        child: _buildCard(0, 0),
        onDragEnd: (x, y) {
          double dx = x / MediaQuery.of(context).size.width * 3;
          setState(() {
            if (dx > 0.4) {
              widget.validate();
            } else if (dx < -0.4) {
              widget.next();
            }
          });
        },
      )),
    );
  }

  Color _getCardColor(double x) {
    x = x / MediaQuery.of(context).size.width * 3;
    x *= 2;
    x = x.clamp(-1, 1);
    // from red to white to green
    if (x < 0) {
      return Color.lerp(Colors.white, Colors.red, -x)!;
    } else {
      return Color.lerp(Colors.white, Colors.green, x)!;
    }
  }

  Widget _buildCard(double x, double y) {
    return SizedBox(
      width: 300,
      height: 300,
      child: FlippableCard(
        onTap: () {
          setState(() {
            widget.front = !widget.front;
          });
        },
        borderColor: _getCardColor(x),
        isFront: widget.front,
        front: CardFaceContentParameters(
          text: widget.card.front,
        ),
        back: CardFaceContentParameters(
          text: widget.card.back
        ),
      ),
    );
  }
}

class _XIntent extends Intent {
  const _XIntent(this.type);

  final _XIntentType type;
}

enum _XIntentType { next, validate, flip }