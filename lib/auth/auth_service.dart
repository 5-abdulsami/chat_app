// auth_service.dart

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // check for internet
      InternetAddress.lookup("google.com");

      // trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // obtain auth details from request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      log('Credential: $credential');

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // once signed in, returned the user credential
      log('User Data: ${userCredential.user}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('-----FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      log('-----Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
