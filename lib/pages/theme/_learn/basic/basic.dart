import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/widgets/card/card_face.dart';
import 'package:memory_ez/widgets/card/flippable_card.dart';

import '../../../../models/theme.dart';
import '../_learn_base.dart';

class Basic extends StatelessWidget {
  final FlashTheme theme;

  Basic({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(theme.name),
      ),
      body: LoadCards(
        theme: theme,
        builder: (context, theme, cards) => BasicContent(
          learn: LearnSystem(theme: theme, cards: cards),
        ),
      ),
    );
  }
}

class BasicContent extends StatefulWidget {
  final LearnSystem learn;
  bool front = true;

  double animPos = 0;
  double xStart = 0;
  double yStart = 0;
  double x = 0;
  double y = 0;

  BasicContent({Key? key, required this.learn}) : super(key: key) {}

  @override
  _BasicContentState createState() => _BasicContentState();

  void next() {
    front = true;
    animPos = 0;
    learn.next();
  }

  void animNext(bool isCorrect) {
    front = true;
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
    return Column(children: <Widget>[
      LearnSystemProgress(learn: widget.learn),
      LearnSystemRound(
        learn: widget.learn,
        onEnd: () {
          Navigator.pop(context);
        },
        onNextRound: () {
          setState(() {
            widget.learn.prevRoundScore = widget.learn.validated;
            widget.learn.roundEnd = false;
          });
        },
        child: Column(
          children: [
            Expanded(child: _buildCard(context)),
            _buildButtons(context),
          ],
        ),
      ),
    ]);
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          iconSize: 40,
          color: Colors.red,
          onPressed: () {
            if (widget.animPos != 0) return;
            setState(() {
              widget.animNext(false);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.flip),
          iconSize: 40,
          onPressed: () {
            if (widget.animPos != 0) return;
            setState(() {
              widget.front = !widget.front;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          iconSize: 40,
          color: Colors.green,
          onPressed: () {
            if (widget.animPos != 0) return;
            setState(() {
              widget.learn.validate();
              widget.animNext(true);
            });
          },
        ),
      ],
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
      onTap: () {
        setState(() {
          widget.front = !widget.front;
        });
      },
      onPanStart: (details) {
        setState(() {
          widget.xStart = details.globalPosition.dx;
          widget.yStart = details.globalPosition.dy;
        });
      },
      onPanUpdate: (details) {
        if (widget.animPos != 0) {
          return;
        }
        setState(() {
          widget.x = details.globalPosition.dx - widget.xStart;
          widget.y = details.globalPosition.dy - widget.yStart;
        });
      },
      onPanEnd: (details) {
        double x = widget.x / MediaQuery.of(context).size.width * 2;
        if (x > 0.3) {
          setState(() {
            widget.learn.validate();
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
                  opacity: widget.learn.hasNextCard
                      ? widget.animPos == 0
                          ? 0.1
                          : 1
                      : 0,
                  child:
                      _buildCardContainer(context, widget.learn.nextCard, true),
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
                child: _buildCardContainer(context, widget.learn.card, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(
      BuildContext context, Flashcard card, bool forceFront) {
    return FlippableCard(
      isFront: widget.front || forceFront || widget.animPos != 0,
      front: CardFaceContentParameters(text: card.front),
      back: CardFaceContentParameters(text: card.back),
      borderColor: widget.learn.theme.color,
    );
  }
}
