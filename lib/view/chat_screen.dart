import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/helper/date_util.dart';
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

  bool _showEmojis = false;
  // to check if image is being uploaded or not
  bool _isUploading = false;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (_showEmojis) {
            setState(() {
              // if emojis being shown and back button pressed
              // then hide emojis
              _showEmojis = !_showEmojis;
            });
          }
        },
        child: Scaffold(
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
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.only(
                                  top: mediaQuery.height * 0.01),
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return const Center(
                            child: Text("Say Hiii!",
                                style: TextStyle(fontSize: 20)),
                          );
                        }
                    }
                  }),
            ),
            if (_isUploading)
              const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            _chatInput(),
            _showEmojis
                ? SizedBox(
                    height: mediaQuery.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _messageController,
                      config: Config(
                        emojiViewConfig: EmojiViewConfig(
                          backgroundColor: lightBlueColor,
                          columns: 8,
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ]),
        ),
      ),
    );
  }

  Widget _appBar() {
    var mediaQuery = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
          stream: API.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            var list = data?.map((e) => ChatUser.fromJson(e.data())).toList();
            return Row(
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
                    imageUrl:
                        list!.isNotEmpty ? list[0].image : widget.user.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
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
                      list.isNotEmpty ? list[0].image : widget.user.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : DateUtil.getLastActiveTime(
                                  context: context, time: list[0].lastOnline)
                          : DateUtil.getLastActiveTime(
                              context: context, time: widget.user.lastOnline),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ],
                )
              ],
            );
          }),
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmojis = !_showEmojis;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: blueColor,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmojis) {
                        setState(() {
                          _showEmojis = !_showEmojis;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type something...",
                    ),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final List<XFile?> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for (var img in images) {
                          setState(() => _isUploading = true);
                          API.sendChatImage(widget.user, File(img!.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: blueColor,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);

                        if (image != null) {
                          setState(() => _isUploading = true);
                          log("image path: ${image.path}, mime type : ${image.mimeType}");
                          Navigator.pop(context);

                          API.sendChatImage(widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
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
                API.sendMessage(
                    widget.user, _messageController.text, Type.text);
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
