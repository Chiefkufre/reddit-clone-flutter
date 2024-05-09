import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constant.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/common/failure.dart';
import 'package:reddit/core/providers/firebase_provider.dart';
import 'package:reddit/core/common/type_defs.dart';
import 'package:reddit/models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      firestore: ref.read(firebaseFirestoreProvider),
      auth: ref.read(firebaseAuthProvider),
      googleSignIn: ref.read(googleSignInProvider),
    ));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      final signInUser = userCredential.user;

      UserModel user = UserModel(
        uid: signInUser!.uid,
        name: signInUser.displayName ?? "No name",
        profilePic: signInUser.photoURL ?? Constants.avatarDefault,
        banner: Constants.bannerDefault,
        karma: 0,
        awards: [
          'til',
          'awesomeAns',
          'gold',
          'platinum',
          'plusone',
          'helpful',
          'thankyou',
          'rocket',
        ],
        isAuthenticated: true,
      );

      if (userCredential.additionalUserInfo!.isNewUser) {
        await _users.doc(user.uid).set(
              user.toMap(),
            );
      } else {
        user = await getUserData(signInUser.uid).first;
      }
      return right(user);
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(Failure(
        message: e.toString(),
      ));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      final signInUser = userCredential.user;

      UserModel user = UserModel(
        uid: signInUser!.uid,
        name: "Guest",
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        karma: 0,
        awards: [],
        isAuthenticated: false,
      );

      await _users.doc(user.uid).set(
            user.toMap(),
          );

      return right(user);
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(Failure(
        message: e.toString(),
      ));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
