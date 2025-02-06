import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/model/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: _appBar(),
    ));
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
            borderRadius: BorderRadius.circular(mediaQuery.width * 0.05),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              width: mediaQuery.width * 0.4,
              height: mediaQuery.height * 0.2,
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
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mediaQuery.height * 0.01,
              ),
              Text(
                widget.user.name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
              ),
            ],
          )
        ],
      ),
    );
  }
}
