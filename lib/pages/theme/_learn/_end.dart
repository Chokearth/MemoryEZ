import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class End extends StatefulWidget {
  final int total;
  final Function() onNext;

  const End({Key? key, required this.total, required this.onNext})
      : super(key: key);

  @override
  State<End> createState() => _EndState();
}

class _EndState extends State<End> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Yay!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You have learned ${widget.total} cards',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onNext,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0,
            numberOfParticles: 100,
            gravity: 0.05,
            shouldLoop: false,
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
