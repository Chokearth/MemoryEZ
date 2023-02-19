import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_ez/widgets/card/card_face.dart';
import 'package:memory_ez/widgets/card/flippable_card.dart';

import '../../../../models/theme.dart';
import '../_learn_base.dart';

class Typing extends StatelessWidget {
  final FlashTheme theme;

  Typing({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(theme.name),
      ),
      body: LoadCards(
        theme: theme,
        builder: (context, theme, cards) => TypingContent(
          learn: LearnSystem(theme: theme, cards: cards),
        ),
      ),
    );
  }
}

class TypingContent extends StatefulWidget {
  final LearnSystem learn;
  bool front = true;

  TypingContent({Key? key, required this.learn}) : super(key: key) {}

  @override
  _TypingContentState createState() => _TypingContentState();

  void next() {
    front = true;
    learn.next();
  }
}

class _TypingContentState extends State<TypingContent> {
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: _buildRound(),
        ),
      ],
    );
  }

  Widget _buildRound() {
    return Column(
      children: [
        Expanded(
          child: _buildCard(),
        ),
        widget.front
            ? _buildInput()
            : Stack(
                children: [
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: TextField(
                      autofocus: true,
                      enabled: true,
                      decoration: const InputDecoration(
                        hintText: "Type the answer",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          widget.next();
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.next();
                      });
                    },
                    child: const Text("Next"),
                  ),
                ],
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
            text: widget.learn.card.front,
          ),
          back: CardFaceContentParameters(
            text: widget.learn.card.back,
          ),
          isFront: widget.front,
        ),
      ),
    );
  }

  Widget _buildInput() {
    final controller = TextEditingController();

    submit(String value) {
      if (value.trim().toLowerCase() ==
          widget.learn.card.back.trim().toLowerCase()) {
        setState(() {
          widget.learn.validate();
          widget.next();
        });
        _focusNode.requestFocus();
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
              focusNode: _focusNode,
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
