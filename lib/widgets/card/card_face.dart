import 'package:flutter/material.dart';

class CardFace extends StatelessWidget {
  final CardFaceContentParameters faceParameter;
  final Color borderColor;
  final VoidCallback? onTap;

  const CardFace({
    Key? key,
    required this.faceParameter,
    this.borderColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: _shape(),
      child: InkWell(
        onTap: onTap,
        child: CardFaceContent(
          parameter: faceParameter,
        ),
      ),
    );
  }

  ShapeBorder _shape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(
        color: borderColor,
        width: 4,
      ),
    );
  }
}

class CardFaceContentParameters {
  String text;

  CardFaceContentParameters({this.text = ''});
}

class CardFaceContent extends StatelessWidget {
  final CardFaceContentParameters parameter;

  const CardFaceContent({Key? key, required this.parameter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        parameter.text,
        style: const TextStyle(
          fontSize: 30,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
