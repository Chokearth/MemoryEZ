import 'package:flutter/material.dart';

import '../../models/theme.dart';
import '../../services/theme.dart';
import '../theme/theme.dart';
import '../theme_edit/theme_edit.dart';

class Public extends StatefulWidget {
  const Public({super.key});

  @override
  _PublicState createState() => _PublicState();
}

class _PublicState extends State<Public> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _buildScrollSection()
    );
  }

  Widget _buildScrollSection() {
    return FutureBuilder<List<FlashTheme>>(
      future: getPublicThemes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 100,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemePage(theme: snapshot.data![index]),
                      ),
                    ).then((value) => setState(() {}));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: snapshot.data![index].color, width: 5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            snapshot.data![index].name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.data![index].cardCount > 1
                                ? '${snapshot.data![index].cardCount} cards'
                                : '${snapshot.data![index].cardCount} card',
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
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
                  side: BorderSide(color: e.color, width: 5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(e.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(e.cardCount > 1
                          ? '${e.cardCount} cards'
                          : '${e.cardCount} card'),
                    ],
                  ),
                ),
              ),
            ),
          ))
      .toList());
  }
}
