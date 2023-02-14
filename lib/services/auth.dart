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
    final UserCredential userCredential = await auth.signInWithCredential(credential);

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