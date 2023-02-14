import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundEnd extends StatelessWidget {
  final int score;
  final int prevScore;
  final int total;
  final Function() onNext;

  const RoundEnd(
      {Key? key,
      required this.score,
      required this.prevScore,
      required this.total,
      required this.onNext})
      : super(key: key);

  get _successCount => score - prevScore;

  get _errorCount => total - score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Round ended',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Expanded(
            flex: 4,
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total score',
                  style: Theme.of(context).textTheme.headlineMedium),
              Text('$score/$total',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.inversePrimary)),
              const SizedBox(height: 20),
              Text('Round score',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              _buildProgressIndicator(context),
            ],
          )),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                ),
                onPressed: onNext,
                child: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 20,
        width: 250,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: _successCount,
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$_successCount',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  )),
            ),
            Expanded(
              flex: _errorCount,
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$_errorCount',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
