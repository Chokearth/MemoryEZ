import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    Key? key,
    required String label,
    required bool initialValue,
    bool leading = false,
    required FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool>? validator,
    Color color = Colors.green,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (state) {
            return CheckboxListTile(
              value: state.value,
              onChanged: (value) {
                state.didChange(value);
              },
              title: Text(label),
              controlAffinity: leading
                  ? ListTileControlAffinity.leading
                  : ListTileControlAffinity.trailing,
              activeColor: color,
            );
          },
        );
}