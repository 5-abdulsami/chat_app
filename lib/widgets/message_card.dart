import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/helper/date_util.dart';
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
}
