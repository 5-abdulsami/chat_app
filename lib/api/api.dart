import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/model/message.dart';

class API {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

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

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child("profile_pictures/${user.uid}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log("Data transferred : ${p0.bytesTransferred / 1000} kb");
    });

    currentUser.image = await ref.getDownloadURL();
    await firestore.collection("users").doc(user.uid).update({
      'image': currentUser.image,
    });
  }

  // for getting conversation id of 2 users
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    // for unique doc id (message sending time)
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: "",
        type: Type.text,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson());
  }

  static Future<void> upateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
