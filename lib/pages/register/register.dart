import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/services/auth.dart';
import 'package:memory_ez/widgets/app_container.dart';
import 'package:validators/validators.dart' as validator;

class RegisterModel {
  String email = '';
  String password = '';

  RegisterModel({
    required this.email,
    required this.password,
  });
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign Up',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 20),
                RegisterForm(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLoginSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account ?'),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )),
      ],
    );
  }
}

class RegisterForm extends StatelessWidget {
  RegisterForm({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final RegisterModel _registerModel = RegisterModel(
    email: '',
    password: '',
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: max(300, MediaQuery.of(context).size.width * 0.8),
        child: Column(children: [
          _buildField(
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email,
            obscureText: false,
            context: context,
            validator: (value) {
              if (!validator.isEmail(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) {
              _registerModel.email = value!;
            },
          ),
          const SizedBox(height: 10),
          _buildField(
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock,
            obscureText: true,
            context: context,
            validator: (value) {
              if (value!.length < 7) {
                return 'Password must be at least 7 characters';
              }
              _formKey.currentState!.save();
              return null;
            },
            onSaved: (value) {
              _registerModel.password = value!;
            },
          ),
          const SizedBox(height: 10),
          _buildField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock,
            obscureText: true,
            context: context,
            validator: (value) {
              if (value!.length < 7) {
                return 'Password must be at least 7 characters';
              } else if (value != _registerModel.password) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: max(300, MediaQuery.of(context).size.width * 0.8),
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required bool obscureText,
    required BuildContext context,
    required String? Function(String?) validator,
    Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            focusColor: Colors.white,
          ),
          cursorColor: Colors.white,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  void _register(BuildContext context) {
    registerUser(_registerModel.email, _registerModel.password)
        .then((result) => {
              if (result)
                {
                  Navigator.pushNamed(context, '/'),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Something went wrong'),
                    ),
                  ),
                }
            });
  }
}
