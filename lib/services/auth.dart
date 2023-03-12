import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  FirebaseAuth auth = FirebaseAuth.instance;

  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    return Future.error('Google Sign In failed');
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  try {
    final UserCredential userCredential =
        await auth.signInWithCredential(credential);

    return userCredential;
  } catch (e) {
    return Future.error('Google Sign In failed2');
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

String getUsername() {
  return FirebaseAuth.instance.currentUser?.displayName ?? '';
}

Future<UserCredential> createAccount(String email, String password) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }

  return Future.error('Account creation failed');
}

Future<UserCredential> signIn(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
  return Future.error('Sign in failed');
}

Future<bool> emailIsVerified({bool reload = false}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return false;
  }

  if (reload) {
    await user.reload();
  }

  return user.emailVerified;
}

Future<void> sendEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  await user.sendEmailVerification();
}

Future<void> sendPasswordResetEmail(String email) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}

Future<bool> registerUser(String email, String password) async {
  try {
    final credential = await createAccount(email, password);
    await sendEmailVerification();
    return credential.user != null;
  } catch (e) {
    print(e);
    return false;
  }
}

bool isSignedIn() {
  return FirebaseAuth.instance.currentUser != null;
}