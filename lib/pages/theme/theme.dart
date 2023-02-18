import 'package:flutter/material.dart';
import 'package:memory_ez/models/theme.dart';
import 'package:memory_ez/pages/theme/_learn/basic/basic.dart';
import 'package:memory_ez/pages/theme/_learn/typing/typing.dart';
import 'package:memory_ez/pages/theme_edit/theme_edit.dart';

import '_card.dart';

class LearnOption {
  final String name;
  final String description;
  final IconData icon;
  final Widget page;

  LearnOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.page,
  });
}

class ThemePage extends StatelessWidget {
  final FlashTheme theme;
  late List<LearnOption> options;

  ThemePage({Key? key, required this.theme}) : super(key: key) {
    options = [
      LearnOption(
        name: 'Memorize',
        description: 'Learn the theme by looking at the cards',
        icon: Icons.book,
        page: Basic(theme: theme),
      ),
      LearnOption(
        name: 'Typing',
        description: 'Can you write it ?',
        icon: Icons.keyboard,
        page: Typing(theme: theme),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(theme.name),
        actions: [
          _buildActionButton(context),
        ],
      ),
      body: FutureBuilder(
        future: theme.getFlashcards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Flashcard>> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && snapshot.data!.length == 0) {
            return const Text("Document is empty");
          }

          if (snapshot.hasData == true) {
            return _buildPage(context, snapshot.data!);
          }

          return const Text("loading...");
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return theme.isMine
        ? IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemeEdit(theme: theme),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          )
        : IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Clone theme"),
                    content: const Text(
                        "Are you sure you want to clone this theme ?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          theme.clone();
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/'),
                          );
                        },
                        child: const Text("Clone"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.copy),
          );
  }

  Widget _buildPage(BuildContext context, List<Flashcard> cards) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              children: options
                  .map((option) => Card(
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(option.icon, size: 28),
                            ],
                          ),
                          title: Text(option.name),
                          subtitle: Text(option.description),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => option.page,
                              ),
                            );
                          },
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Cards', style: Theme.of(context).textTheme.headlineSmall),
            Column(
              children: cards
                  .map((card) => CardDisplay(
                        front: card.front,
                        back: card.back,
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
