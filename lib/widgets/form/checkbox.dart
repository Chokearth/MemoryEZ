import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    Key? key,
    required String label,
    required bool initialValue,
    required FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool>? validator,
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
            );
          },
        );
}