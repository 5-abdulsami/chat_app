import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:linkup/api/notification_access_token.dart';
import 'package:linkup/helper/dialogs.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/model/message.dart';

class API {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static FirebaseAuth auth = FirebaseAuth.instance;

  static User get user => auth.currentUser!;

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // get firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();

    await firebaseMessaging.getToken().then((token) {
      if (token != null) {
        currentUser.pushToken = token;
        log("Firebase Messaging Token: $token");
      }
    });
  }

  // me
  static late ChatUser currentUser;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log("data: ${data.docs}");

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // user exists

      log("user exists: ${data.docs.first.id}");
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      return false;
    }
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
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
        await getFirebaseMessagingToken();
        // setting user initial status to active
        API.updateActiveStatus(isOnline: true);
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
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // for unique doc id (message sending time)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> upateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent) // as we stored the unique id as current time in sent
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send image as message
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child(
        "images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log("Data transferred : ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online status of user
  static Future<void> updateActiveStatus({required bool isOnline}) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastOnline ': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': currentUser.pushToken
    });
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    NotificationAccessToken accessToken = NotificationAccessToken();
    String? bearerToken = await accessToken.getToken;
    log("Bearer Token: $bearerToken");
    final body = {
      "message": {
        "token": chatUser.pushToken,
        "notification": {"title": currentUser.name, "body": msg},
      }
    };
    try {
      if (bearerToken != null) {
        var response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/tiers-22911/messages:send'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $bearerToken'
          },
          body: jsonEncode(body),
        );
        log("Response statusCode: ${response.statusCode}");
        log("Response body: ${response.body}");
      }
    } catch (e) {
      log("\nsendPushNotification: $e");
    }
  }

  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<void> saveImage(BuildContext context, String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var imageBytes = response.bodyBytes;

        final result = await ImageGallerySaver.saveImage(imageBytes);
        log("Image saved! Result: $result");
        Dialogs.showSnackbar(context, "Image Saved successfully!");
      } else {
        log("Failed to load image. Status code: ${response.statusCode}");
        Dialogs.showSnackbar(context, "Error while saving image.");
      }
    } catch (e) {
      log("Error saving image: $e");
      Dialogs.showSnackbar(context, "Error while saving image.");
    }
  }
}
