import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_ez/widgets/card/card_face.dart';
import 'package:memory_ez/widgets/card/flippable_card.dart';

import '../../../../models/theme.dart';
import '../basic/_end.dart';
import '../basic/_round_end.dart';

class FlashcardLearn {
  final Flashcard card;
  bool validated = false;

  FlashcardLearn(this.card);
}

class Typing extends StatelessWidget {
  final FlashTheme theme;

  Typing({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(theme.name),
      ),
      body: FutureBuilder<List<Flashcard>>(
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
            return TypingContent(theme: theme, cards: snapshot.data!);
          }

          return const Text("loading...");
        },
      ),
    );
  }
}

class TypingContent extends StatefulWidget {
  final FlashTheme theme;
  final List<Flashcard> cards;
  late List<FlashcardLearn> cardsLearn;
  int index = 0;
  bool roundEnd = false;
  int prevRoundScore = 0;
  bool front = true;

  TypingContent({super.key, required this.theme, required this.cards}) {
    cardsLearn = cards.map((e) => FlashcardLearn(e)).toList()..shuffle();
  }

  @override
  _TypingContentState createState() => _TypingContentState();

  get card => cardsLearn[index];

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
    card.validated = true;
    next();
  }
}

class _TypingContentState extends State<TypingContent> {
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
    if (widget.roundEnd) {
      return _buildRoundEnd();
    }

    return _buildRound();
  }

  Widget _buildRoundEnd() {
    return widget.total == widget.validated
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
          );
  }

  Widget _buildRound() {
    return Column(
      children: [
        Expanded(
          child: _buildCard(),
        ),
        widget.front ? _buildInput() : ElevatedButton(
          onPressed: () {
            setState(() {
              widget.next();
            });
          },
          child: const Text("Next"),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: FlippableCard(
          front: CardFaceContentParameters(
            text: widget.card.card.front,
          ),
          back: CardFaceContentParameters(
            text: widget.card.card.back,
          ),
          isFront: widget.front,
        ),
      ),
    );
  }

  Widget _buildInput() {
    final controller = TextEditingController();


    submit(String value) {
      if (value.trim().toLowerCase() == widget.card.card.back.trim().toLowerCase()) {
        setState(() {
          widget.validate();
        });
      } else {
        setState(() {
          widget.front = false;
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              autofocus: true,
              onSubmitted: submit,
              decoration: const InputDecoration(
                hintText: "Type the answer",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              submit(controller.text);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}