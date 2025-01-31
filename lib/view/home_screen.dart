import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/auth/auth_service.dart';
import 'package:linkup/main.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/widgets.dart/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LinkUp",
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: StreamBuilder(
          stream: API.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.active:
              case ConnectionState.done:
                var list = [];
                final data = snapshot.data?.docs;
                list = data!.map((e) => ChatUser.fromJson(e.data())).toList();

                if (list.isNotEmpty) {
                  return ListView.builder(
                      padding: EdgeInsets.only(top: mediaQuery.height * 0.01),
                      itemCount: list.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: list[index]);
                      });
                } else {
                  return Text("No connections found!",
                      style: GoogleFonts.poppins());
                }
            }
          }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton(
          onPressed: () async {
            await AuthService().signOut();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
    );
  }
}
