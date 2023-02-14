// Button that display color and open color picker dialog
// Compatible with Form
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  final Color color;
  final String label;
  final void Function(Color) onColorChanged;

  const ColorPickerButton({
    Key? key,
    required this.color,
    required this.label,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  Color _color = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final color = await showDialog<Color>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _color,
                onColorChanged: (color) {
                  setState(() {
                    _color = color;
                  });
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, _color);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (color != null) {
          widget.onColorChanged(color);
        }
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(widget.label),
        ],
      ),
    );
  }
}

class ColorFormField extends FormField<Color> {
  ColorFormField({
    Key? key,
    required String label,
    required Color initialValue,
    required FormFieldSetter<Color> onSaved,
    FormFieldValidator<Color>? validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (state) {
            return ColorPickerButton(
              color: state.value!,
              label: label,
              onColorChanged: (color) {
                state.didChange(color);
              },
            );
          },
        );
}