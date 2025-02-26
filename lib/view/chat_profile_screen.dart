import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/helper/date_util.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/utils/colors.dart';

class ChatProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ChatProfileScreen({super.key, required this.user});

  @override
  State<ChatProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ChatProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user.name,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mediaQuery.height * 0.05,
                  width: mediaQuery.width,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mediaQuery.width * 0.05),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    width: mediaQuery.width * 0.4,
                    height: mediaQuery.height * 0.2,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  height: mediaQuery.height * 0.02,
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(
                      color: blackColor, fontSize: mediaQuery.height * 0.025),
                ),
                SizedBox(
                  height: mediaQuery.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "About: ",
                      style: TextStyle(
                          color: blackColor,
                          fontSize: mediaQuery.height * 0.025),
                    ),
                    Text(
                      widget.user.about,
                      style: TextStyle(
                          color: greyColor,
                          fontSize: mediaQuery.height * 0.025),
                    ),
                  ],
                ),
                SizedBox(
                  height: mediaQuery.height * 0.05,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Joined On: ",
              style: TextStyle(
                  color: blackColor, fontSize: mediaQuery.height * 0.025),
            ),
            Text(
              DateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: TextStyle(
                  color: greyColor, fontSize: mediaQuery.height * 0.025),
            ),
          ],
        ),
      ),
    );
  }
}
