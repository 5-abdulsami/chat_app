import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/helper/date_util.dart';
import 'package:linkup/helper/dialogs.dart';
import 'package:linkup/model/message.dart';
import 'package:linkup/utils/colors.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = API.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(context, isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender (other user) message
  Widget _blueMessage() {
    // update last read message if sender and reciever are different
    if (widget.message.read.isEmpty) {
      API.upateMessageReadStatus(widget.message);
    }
    var mediaQuery = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mediaQuery.width * 0.8,
        ),
        child: IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mediaQuery.width * 0.03
                : mediaQuery.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mediaQuery.width * 0.04,
                vertical: mediaQuery.width * 0.01),
            decoration: BoxDecoration(
                color: blueColor.withValues(alpha: 0.15),
                border: Border.all(color: blueColor.withValues(alpha: 0.6)),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: widget.message.type == Type.text
                      ? Text(
                          widget.message.msg,
                          style:
                              const TextStyle(fontSize: 15, color: blackColor),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateUtil.getFormattedTime(
                        context: context, time: widget.message.sent),
                    style: const TextStyle(fontSize: 11, color: greyColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // our own message
  Widget _greenMessage() {
    var mediaQuery = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mediaQuery.width * 0.8),
        child: IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mediaQuery.width * 0.03
                : mediaQuery.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mediaQuery.width * 0.04,
                vertical: mediaQuery.width * 0.01),
            decoration: BoxDecoration(
                color: greenColor.withValues(alpha: 0.2),
                border: Border.all(color: greenColor.withValues(alpha: 0.75)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: widget.message.type == Type.text
                      ? Text(
                          widget.message.msg,
                          style:
                              const TextStyle(fontSize: 15, color: blackColor),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateUtil.getFormattedTime(
                              context: context, time: widget.message.sent),
                          style:
                              const TextStyle(fontSize: 11, color: greyColor),
                        ),
                        if (widget.message.read.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.done_all,
                              size: 17,
                              color: blueColor,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, bool isMe) {
    final mediaQuery = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    horizontal: mediaQuery.width * 0.4,
                    vertical: mediaQuery.height * 0.015),
                decoration: BoxDecoration(
                    color: greyColor, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? OptionItem(
                      icon: const Icon(
                        Icons.copy,
                        color: blueColor,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, "Text Copied");
                        });
                      },
                    )
                  : OptionItem(
                      icon: const Icon(
                        Icons.download,
                        color: blueColor,
                        size: 26,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        await API.saveImage(context, widget.message.msg);

                        Navigator.pop(context);
                      },
                    ),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mediaQuery.width * 0.04,
                  indent: mediaQuery.width * 0.04,
                ),
              if (widget.message.type == Type.text && isMe)
                OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: blueColor,
                    size: 26,
                  ),
                  name: "Edit Message",
                  onTap: () {},
                ),
              if (isMe)
                OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: blueColor,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () {
                    API.deleteMessage(widget.message);
                  },
                ),
              Divider(
                color: Colors.black54,
                endIndent: mediaQuery.width * 0.04,
                indent: mediaQuery.width * 0.04,
              ),
              OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: blueColor,
                ),
                name:
                    "Sent At : ${DateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {},
              ),
              OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: greenColor,
                ),
                name: widget.message.read.isEmpty
                    ? "Read At: Not seen yet"
                    : "Read At : ${DateUtil.getMessageTime(context: context, time: widget.message.read)}",
                onTap: () {},
              ),
            ],
          );
        });
  }
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mediaQuery.width * 0.05,
            top: mediaQuery.height * 0.015,
            bottom: mediaQuery.height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "     $name",
              style: const TextStyle(
                  fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
            )),
          ],
        ),
      ),
    );
  }
}
