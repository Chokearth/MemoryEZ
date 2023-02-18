import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/pages/theme/_learn/basic/_end.dart';
import 'package:memory_ez/pages/theme/_learn/basic/_round_end.dart';

import '../../../../models/theme.dart';

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

  double animPos = 0;
  double xStart = 0;
  double yStart = 0;
  double x = 0;
  double y = 0;

  BasicContent({Key? key, required this.theme, required this.cards})
      : super(key: key) {
    cardsLearn = cards.map((e) => FlashcardLearn(e)).toList()..shuffle();
  }

  @override
  _BasicContentState createState() => _BasicContentState();

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
    front = true;
    animPos = 0;

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

  void animNext(bool isCorrect) {
    if (isCorrect) {
      animPos = 1;
    } else {
      animPos = -1;
    }
  }
}

class _BasicContentState extends State<BasicContent>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
            _buildProgress(context),
          ] +
          _buildContent(context),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: widget.prevProgress, end: widget.progress),
      duration: const Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 10,
          color: widget.theme.color,
          backgroundColor: widget.theme.colorAccent,
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          color: Colors.red,
          onPressed: () {
            setState(() {
              widget.animNext(false);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.flip),
          onPressed: () {
            setState(() {
              widget.front = !widget.front;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            setState(() {
              widget.validate();
              widget.animNext(true);
            });
          },
        ),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    return widget.roundEnd
        ? [
            Expanded(child: _buildRoundEnd(context)),
          ]
        : [
            Expanded(child: _buildCard(context)),
            _buildButtons(context),
          ];
  }

  Widget _buildRoundEnd(BuildContext context) {
    return widget.validated == widget.total
        ? End(
            total: widget.total,
            onNext: () {
              Navigator.pop(context);
            },
          )
        : RoundEnd(
            total: widget.total,
            prevScore: widget.prevRoundScore,
            score: widget.validated,
            onNext: () {
              setState(() {
                widget.prevRoundScore = widget.validated;
                widget.roundEnd = false;
              });
            },
          );
  }

  Widget _buildCard(BuildContext context) {
    double centerX = MediaQuery.of(context).size.width / 2;
    double centerY = 300;

    double xPos = centerX + (300 + centerX) * widget.animPos - 150 + widget.x;
    double yPos = centerY -
        150 +
        1 /
            (1 + exp(-widget.y / MediaQuery.of(context).size.height / 1.5)) *
            centerY *
            2 -
        centerY;

    double size = widget.animPos == 0 ? 250 : 300;
    double yPos2 = centerY - size / 2 - (widget.animPos == 0 ? 50 : 0);

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          widget.xStart = details.globalPosition.dx;
          widget.yStart = details.globalPosition.dy;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          widget.x = details.globalPosition.dx - widget.xStart;
          widget.y = details.globalPosition.dy - widget.yStart;
        });
      },
      onPanEnd: (details) {
        double x = widget.x / MediaQuery.of(context).size.width * 2;
        if (x > 0.3) {
          setState(() {
            widget.validate();
            widget.animNext(true);
          });
        } else if (x < -0.3) {
          setState(() {
            widget.animNext(false);
          });
        }

        setState(() {
          widget.x = 0;
          widget.y = 0;
        });
      },
      child: Center(
        child: SizedBox(
          width: centerX * 2,
          height: centerY * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                width: size,
                height: size,
                top: yPos2,
                duration: Duration(milliseconds: widget.animPos == 0 ? 0 : 600),
                curve: Curves.linear,
                child: AnimatedOpacity(
                  duration:
                      Duration(milliseconds: widget.animPos == 0 ? 0 : 600),
                  curve: Curves.linear,
                  opacity: widget.hasNextCard ? widget.animPos == 0 ? 0.1 : 1 : 0,
                  child: _buildCardContainer(context, widget.nextCard, true),
                ),
              ),
              AnimatedPositioned(
                left: xPos,
                top: yPos,
                width: 300,
                height: 300,
                duration: Duration(milliseconds: widget.animPos == 0 ? 0 : 600),
                curve: Curves.easeInSine,
                onEnd: () {
                  if (widget.animPos != 0) {
                    setState(() {
                      widget.next();
                    });
                  }
                },
                child: _buildCardContainer(context, widget.card, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(
      BuildContext context, Flashcard card, bool forceFront) {
    return Center(
      child: Card(
        color: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: widget.theme.color,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.front || forceFront ? card.front : card.back,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
