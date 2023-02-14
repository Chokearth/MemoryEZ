import 'package:flutter/material.dart';

import '../../models/theme.dart';
import '../../services/theme.dart';
import '../theme/theme.dart';
import '../theme_edit/theme_edit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your themes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThemeEdit(
                          theme: FlashTheme(name: 'New', color: Colors.purple)),
                    ),
                  ).then((value) => setState(() {}));
                },
                child: const Text('New theme'),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            child: _buildScrollSection(_getYourThemes(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollSection(Future<List<Widget>> cards) {
    return FutureBuilder<List<Widget>>(
      future: cards,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return snapshot.data![index];
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return const CircularProgressIndicator();
      },
    );
  }

  Future<List<Widget>> _getYourThemes(BuildContext context) async {
    return getPersonalThemes().then((value) => value
        .map((e) => SizedBox(
              width: 200,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThemePage(theme: e),
                    ),
                  ).then((value) => setState(() {}));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: e.color, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          e.cardCount > 1
                              ? '${e.cardCount} cards'
                              : '${e.cardCount} card',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList());
  }
}
