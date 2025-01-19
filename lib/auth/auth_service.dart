// auth_service.dart

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
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

    // once signed in, returned the user credential
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
