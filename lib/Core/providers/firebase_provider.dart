import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = Provider((ref)=>FirebaseAuth.instance);
final googleSignInProvider = Provider((ref)=>GoogleSignIn.instance);
final storageProvider = Provider((ref)=>FirebaseFirestore.instance);
final fireStoreProvider = Provider((ref)=>FirebaseFirestore.instance);