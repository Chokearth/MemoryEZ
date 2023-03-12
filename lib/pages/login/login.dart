import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/services/auth.dart';
import 'package:memory_ez/widgets/app_container.dart';
import 'package:validators/validators.dart' as validator;

class LoginModel {
  String email = '';
  String password = '';

  LoginModel({
    required this.email,
    required this.password,
  });
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  'Sign In',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 20),
                LoginForm(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSignupSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account ?'),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              'Sign Up',
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

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _model = LoginModel(email: '', password: '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: max(300, MediaQuery.of(context).size.width * 0.8),
        child: Column(
          children: [
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
                _model.email = value!;
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
                if (value!.isEmpty) {
                  return 'Please enter a password';
                }
                _formKey.currentState!.save();
                return null;
              },
              onSaved: (value) {
                _model.password = value!;
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password ?',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            _buildLoginsButtons(context)
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    signIn(_model.email, _model.password).then((value) {
      Navigator.pushNamed(context, '/');
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
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

  Widget _buildLoginsButtons(BuildContext context) {
    ButtonStyle style = OutlinedButton.styleFrom(
      side: const BorderSide(
        color: Colors.white,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );

    return Column(
      children: [
        SizedBox(
          width: max(300, MediaQuery.of(context).size.width * 0.8),
          height: 50,
          child: OutlinedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _login(context);
                }
              },
              style: style,
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )),
        ),
        const SizedBox(height: 10),
        const Text(
          'Or',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: max(300, MediaQuery.of(context).size.width * 0.8),
          height: 50,
          child: OutlinedButton(
            onPressed: null,
            style: style,
            child: ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: Image.asset(
                'assets/images/google_icon.png',
                height: 20,
              ),
              label: const Text(
                'Login with Google',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
