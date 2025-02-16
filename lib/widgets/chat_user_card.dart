import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/helper/date_util.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/model/message.dart';
import 'package:linkup/utils/colors.dart';
import 'package:linkup/view/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // to get last message info
  Message? _message;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mediaQuery.width * 0.02, vertical: 4),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            user: widget.user,
                          )));
            },
            child: StreamBuilder(
                stream: API.getLastMessage(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => Message.fromJson(e.data())).toList() ??
                          [];
                  if (list.isNotEmpty) _message = list[0];

                  return ListTile(
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(mediaQuery.height * 0.03),
                        child: CachedNetworkImage(
                          height: mediaQuery.height * 0.06,
                          width: mediaQuery.height * 0.06,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      title:
                          Text(widget.user.name, style: GoogleFonts.poppins()),
                      subtitle: Text(
                        _message != null ? _message!.msg : widget.user.about,
                        style: GoogleFonts.poppins(),
                        maxLines: 1,
                      ),
                      trailing: _message == null
                          ? null
                          : _message!.read.isEmpty &&
                                  _message!.fromId != API.user.uid
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: greenColor,
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              : Text(
                                  DateUtil.getLastMessageTime(
                                    context: context,
                                    time: _message!.sent,
                                  ),
                                  style: GoogleFonts.poppins(color: greyColor),
                                ));
                })),
      ),
    );
  }
}
