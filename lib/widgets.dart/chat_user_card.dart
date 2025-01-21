import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mediaQuery.width * 0.04, vertical: 4),
        child: InkWell(
          onTap: () {},
          child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.check),
              ),
              title: Text("User Name"),
              subtitle: Text(
                " ",
                style: GoogleFonts.poppins(),
                maxLines: 1,
              ),
              trailing: Text(
                " ",
                style: GoogleFonts.poppins(),
              )),
        ),
      ),
    );
  }
}
