import 'package:flutter/material.dart';

import '../../../models/theme.dart';
import '_end.dart';
import '_round_end.dart';

class FlashcardLearn {
  final Flashcard card;
  bool validated = false;

  FlashcardLearn(this.card);
}

class LoadCards extends StatelessWidget {
  final FlashTheme theme;
  final Function(BuildContext context, FlashTheme theme, List<Flashcard>)
      builder;

  const LoadCards({Key? key, required this.theme, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: theme.getFlashcards(),
      builder: (BuildContext context, AsyncSnapshot<List<Flashcard>> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Text("Document is empty");
        }

        if (snapshot.hasData == true) {
          return builder(context, theme, snapshot.data!);
        }

        return const Text("loading...");
      },
    );
  }
}

class LearnSystem {
  final FlashTheme theme;
  final List<Flashcard> cards;
  late List<FlashcardLearn> cardsLearn;
  int index = 0;
  bool roundEnd = false;
  int prevRoundScore = 0;

  LearnSystem({Key? key, required this.theme, required this.cards}) {
    cardsLearn = cards.map((e) => FlashcardLearn(e)).toList()..shuffle();
  }

  get card => cardsLearn[index].card;

  get nextCard {
    int i = index;
    do {
      i = i + 1;
      if (i >= cardsLearn.length) {
        return card;
      }
    } while (cardsLearn[i].validated);
    return cardsLearn[i].card;
  }

  get hasNextCard {
    int i = index;
    do {
      i = i + 1;
      if (i >= cardsLearn.length) {
        return false;
      }
    } while (cardsLearn[i].validated);
    return true;
  }

  get validated => cardsLearn.where((e) => e.validated).length;

  get total => cardsLearn.length;

  get progress => validated / total;

  get prevProgress => prevRoundScore / total;

  void next() {
    if (validated == total) {
      roundEnd = true;
      return;
    }

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
  }
}

class LearnSystemProgress extends StatelessWidget {
  final LearnSystem learn;

  const LearnSystemProgress({Key? key, required this.learn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: learn.prevProgress, end: learn.progress),
      duration: const Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 10,
          color: learn.theme.color,
          backgroundColor: learn.theme.colorAccent,
        );
      },
    );
  }
}

class LearnSystemRound extends StatelessWidget {
  final LearnSystem learn;
  final Widget child;
  final Function() onNextRound;
  final Function() onEnd;

  const LearnSystemRound(
      {Key? key,
      required this.learn,
      required this.child,
      required this.onNextRound,
      required this.onEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: learn.roundEnd ? _buildRoundEnd(context) : child);
  }

  Widget _buildRoundEnd(BuildContext context) {
    return learn.validated == learn.total
        ? End(
            total: learn.total,
            onNext: onEnd,
          )
        : RoundEnd(
            total: learn.total,
            prevScore: learn.prevRoundScore,
            score: learn.validated,
            onNext: onNextRound,
          );
  }
}
