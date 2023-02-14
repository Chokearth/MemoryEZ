import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/theme.dart';

Future<List<FlashTheme>> getPersonalThemes() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference themes = FirebaseFirestore.instance.collection('themes');
  QuerySnapshot snapshot = await themes.where('ownerId', isEqualTo: userId).get();
  return snapshot.docs.map(FlashTheme.fromSnapshot).toList();
}

Future<List<FlashTheme>> getPublicThemes() async {
  CollectionReference themes = FirebaseFirestore.instance.collection('themes');
  QuerySnapshot snapshot = await themes.where('public', isEqualTo: true).get();
  return snapshot.docs.map(FlashTheme.fromSnapshot).toList();
}