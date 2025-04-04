import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/helper/dialogs.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/view/profile_screen.dart';
import 'package:linkup/widgets/chat_user_card.dart';

import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    API.getCurrentUserInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      // setting user active status based on the app lifecycle events
      if (API.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          API.updateActiveStatus(isOnline: false);
        }

        if (message.toString().contains('resume')) {
          API.updateActiveStatus(isOnline: true);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchList.clear();
            });
            return false; // Prevent app from closing
          }
          return true; // Allow default back button behavior
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Name, Email..."),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();

                      for (var user in _list) {
                        if (user.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            user.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(user);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text(
                    "LinkUp",
                  ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  user: API.currentUser,
                                )));
                  },
                  icon: const Icon(Icons.person)),
              SizedBox(width: mediaQuery.width * 0.02),
            ],
          ),
          // get id of only known users
          body: StreamBuilder(
              stream: API.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: API.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        // getting only those users whose ids are provided
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return const Center(
                            //   child: CircularProgressIndicator(),
                            // );

                            case ConnectionState.active:
                            case ConnectionState.done:
                              // fetching chat user (map) data from firestore and populating
                              // the list with chat user objects
                              final data = snapshot.data?.docs;

                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    padding: EdgeInsets.only(
                                        top: mediaQuery.height * 0.01),
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                    });
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_off_outlined,
                                        size: 50,
                                      ),
                                      Text("No connections found!",
                                          style: GoogleFonts.poppins()),
                                    ],
                                  ),
                                );
                              }
                          }
                        });
                }
              }),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () async {
                _addChatUserDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = "";
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              title: const Row(
                children: [
                  Icon(Icons.person, color: blueColor, size: 28),
                  Text("  Add User")
                ],
              ),
              content: TextFormField(
                autofocus: true,
                maxLines: null,
                decoration: InputDecoration(
                    hintText: 'Enter Email',
                    prefixIcon: const Icon(
                      Icons.mail,
                      color: blueColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
                onChanged: (value) => email = value,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      if (email.isNotEmpty) {
                        await API.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, "User does not Exist!");
                          }
                        });
                      }

                      Navigator.pop(context); // Close edit message dialog
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: blueColor),
                    ))
              ],
            ));
  }
}
