import 'package:flutter/material.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/model/message.dart';
import 'package:linkup/utils/colors.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return API.user.uid == widget.message.fromId
        ? _greenMessage() // our own message
        : _blueMessage(); // sender (other user) message
  }

  // sender (other user) message
  Widget _blueMessage() {
    var mediaQuery = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mediaQuery.width * 0.8,
        ),
        child: IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.all(mediaQuery.width * 0.025),
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
                  child: Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: blackColor),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    widget.message.sent,
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
            padding: EdgeInsets.all(mediaQuery.width * 0.025),
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
                  child: Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: blackColor),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message.sent,
                        style: const TextStyle(fontSize: 11, color: greyColor),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
