import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/model/message.dart';
import 'package:linkup/utils/colors.dart';
import 'package:linkup/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  // for storing all messages
  List<Message> _list = [];
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: lightBlueColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
              stream: API.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const SizedBox();

                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    // converting json data from firestore to Message objects
                    // and storing them in _list
                    _list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                          padding:
                              EdgeInsets.only(top: mediaQuery.height * 0.01),
                          itemCount: _list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _list[index],
                            );
                          });
                    } else {
                      return const Center(
                        child:
                            Text("Say Hiii!", style: TextStyle(fontSize: 20)),
                      );
                    }
                }
              }),
        ),
        _chatInput(),
      ]),
    );
  }

  Widget _appBar() {
    var mediaQuery = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mediaQuery.height * 0.03),
            child: CachedNetworkImage(
              height: mediaQuery.height * 0.06,
              width: mediaQuery.height * 0.06,
              imageUrl: widget.user.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(
            width: mediaQuery.width * 0.02,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                widget.user.email,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    var mediaQuery = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.width * 0.02,
          vertical: mediaQuery.height * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: blueColor,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type something...",
                    ),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image,
                        color: blueColor,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera,
                        color: blueColor,
                      )),
                  SizedBox(
                    width: mediaQuery.width * 0.01,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 40,
            padding: EdgeInsets.only(
                left: mediaQuery.width * 0.007,
                top: mediaQuery.width * 0.025,
                bottom: mediaQuery.width * 0.025),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                API.sendMessage(widget.user, _messageController.text);
                _messageController.text = '';
              }
            },
            color: greenColor,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.send,
              color: whiteColor,
            ),
          )
        ],
      ),
    );
  }
}
