import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/auth/auth_service.dart';
import 'package:linkup/helper/dialogs.dart';
import 'package:linkup/main.dart';
import 'package:linkup/model/chat_user.dart';
import 'package:linkup/utils/colors.dart';
import 'package:linkup/view/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LinkUp",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.05),
        child: Column(
          children: [
            SizedBox(
              height: mediaQuery.height * 0.05,
              width: mediaQuery.width,
            ),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mediaQuery.width * 0.05),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    fit: BoxFit.fill,
                    width: mediaQuery.width * 0.1,
                    height: mediaQuery.height * 0.1,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    elevation: 1,
                    onPressed: () {},
                    shape: CircleBorder(),
                    child: const Icon(
                      Icons.edit,
                      color: blueColor,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: mediaQuery.height * 0.02,
            ),
            Text(
              widget.user.email,
              style: TextStyle(
                  color: greyColor, fontSize: mediaQuery.height * 0.05),
            ),
            SizedBox(
              height: mediaQuery.height * 0.05,
            ),
            TextFormField(
              initialValue: widget.user.name,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: "John Doe",
                  labelText: "Name"),
            ),
            SizedBox(
              height: mediaQuery.height * 0.02,
            ),
            TextFormField(
              initialValue: widget.user.about,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                  hintText: "Feeling Happy",
                  labelText: "About"),
            ),
            SizedBox(
              height: mediaQuery.height * 0.05,
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  shape: const StadiumBorder(),
                  minimumSize:
                      Size(mediaQuery.width * 0.4, mediaQuery.height * 0.055),
                ),
                onPressed: () {},
                icon: const Icon(Icons.update),
                label: const Text("Update")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: redColor,
        onPressed: () async {
          Dialogs.showProgressDialog(context);
          await AuthService().signOut().then((value) {
            // for removing progress dialog
            Navigator.pop(context);
            // for moving to home screen
            Navigator.pop(context);

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          });
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
      ),
    );
  }
}
