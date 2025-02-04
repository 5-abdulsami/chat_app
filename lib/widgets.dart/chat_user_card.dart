import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mediaQuery.width * 0.04, vertical: 4),
        child: InkWell(
          onTap: () {},
          child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mediaQuery.height * 0.03),
                child: CachedNetworkImage(
                  height: mediaQuery.height * 0.06,
                  width: mediaQuery.height * 0.06,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              title: Text(widget.user.name, style: GoogleFonts.poppins()),
              subtitle: Text(
                widget.user.about,
                style: GoogleFonts.poppins(),
                maxLines: 1,
              ),
              trailing: Text(
                "12PM",
                style: GoogleFonts.poppins(),
              )),
        ),
      ),
    );
  }
}
