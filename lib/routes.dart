import 'package:memory_ez/pages/login/login.dart';
import 'package:memory_ez/pages/register/register.dart';
import 'package:memory_ez/widgets/auth_gates/auth_gates.dart';

var appRoutes = {
  '/': (context) => const AuthGates(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),

};