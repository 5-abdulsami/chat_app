import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/utils/colors.dart';
import 'package:linkup/view/chat_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: whiteColor.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.35,
        child: Stack(
          children: [
            Positioned(
              top: size.height * 0.075,
              left: size.width * 0.1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * 0.05),
                child: CachedNetworkImage(
                  scale: 0.3,
                  imageUrl: user.image,
                  width: size.width * 0.47,
                  height: size.height * 0.2,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              left: size.width * 0.04,
              top: size.height * 0.02,
              width: size.width * 0.45,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Positioned(
              right: size.width * 0.02,
              top: size.height * 0.01,
              child: MaterialButton(
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatProfileScreen(user: user),
                    ),
                  );
                },
                child: const Icon(
                  Icons.info_outline,
                  color: blueColor,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
