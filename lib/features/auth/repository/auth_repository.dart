import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:threadup/Core/constants/constants.dart';
import 'package:threadup/Core/constants/firebase_Constants.dart';
import 'package:threadup/Core/failure.dart';
import 'package:threadup/Core/providers/firebase_provider.dart';
import 'package:threadup/Core/type_def.dart';
import 'package:threadup/features/models/user_model.dart';

final authRepositoryProvider = Provider((ref)=>AuthRepository(auth: ref.read(authProvider), firestore: ref.read(fireStoreProvider), googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;


  bool _initialized = false;
  CollectionReference get _user =>  _firestore.collection(FirebaseConstants.usersCollection);


  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

    Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId:
      "153738262076-aehl0i2mb1k2klik2ij7vav7ra4ue7vu.apps.googleusercontent.com",
    );
    _initialized = true;
  }

  /// Google Sign-in (with token + Firestore save)
  FutureEither<UserModel> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // 1. Interactive login (new API v7)
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // 2. Get ID token
      final idToken = (account.authentication).idToken;

      // 3. Get access token from authorization client
      final authorizationClient = account.authorizationClient;
      GoogleSignInClientAuthorization? authorization =
      await authorizationClient.authorizationForScopes(['email', 'profile']);

      // String? accessToken = authorization?.accessToken;
      //
      //
      // if (accessToken == null) {
      //   authorization = await authorizationClient.authorizationForScopes(
      //     ['email', 'profile'],
      //   );
      //   accessToken = authorization?.accessToken;
      // }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        // accessToken: accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
       UserModel userModel;
      if(userCredential.additionalUserInfo!.isNewUser){
        userModel = UserModel(name: userCredential.user!.displayName!,
            profilePic: userCredential.user!.photoURL?? Constants.avatarDefault,
            banner: userCredential.user!.photoURL??Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);
        await _user.doc(userCredential.user!.uid).set(userModel.toMap());
      }else{
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);

    }on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel>getUserData(String uid){
    return _user.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }



}
