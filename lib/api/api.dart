import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/model/chat_user.dart';

class API {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseAuth auth = FirebaseAuth.instance;

  static User get user => auth.currentUser!;

  // me
  static late ChatUser currentUser;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        isOnline: false,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using LinkUp",
        lastOnline: time,
        createdAt: time,
        image: user.photoURL.toString(),
        pushToken: '');
    await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  static Future<void> updateUser() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': currentUser.name,
      'about': currentUser.about,
    });
  }

  static Future<void> getCurrentUserInfo() async {
    firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        currentUser = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getCurrentUserInfo());
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }
}
