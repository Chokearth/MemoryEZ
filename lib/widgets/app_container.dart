import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final BottomNavigationBar? bottomNavigationBar;

  const AppContainer({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C5364),
              Color(0xFF203A43),
              Color(0xFF0F2027),
            ],
          ),
        ),
        child: SafeArea(
            child: Column(
          children: [
            Expanded(child: SizedBox(width: double.infinity, child: body)),
          ],
        )),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
