import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/auth/auth_service.dart';
import 'package:linkup/helper/dialogs.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "LinkUp",
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mediaQuery.height * 0.05,
                    width: mediaQuery.width,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  mediaQuery.width * 0.05),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.fill,
                                width: mediaQuery.width * 0.4,
                                height: mediaQuery.height * 0.2,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  mediaQuery.width * 0.05),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          color: Colors.white,
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet(context);
                          },
                          shape: const CircleBorder(),
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
                        color: greyColor, fontSize: mediaQuery.height * 0.025),
                  ),
                  SizedBox(
                    height: mediaQuery.height * 0.05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => API.currentUser.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required',
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
                    onSaved: (val) => API.currentUser.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required",
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
                        minimumSize: Size(
                            mediaQuery.width * 0.4, mediaQuery.height * 0.055),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          API.updateUser().then((value) {
                            Dialogs.showSnackbar(
                                context, "Profile Updated Successfully");
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 25,
                        color: whiteColor,
                      ),
                      label: const Text(
                        "Update",
                        style: TextStyle(color: whiteColor, fontSize: 18),
                      )),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: redColor,
          onPressed: () async {
            Dialogs.showProgressDialog(context);
            await API.updateActiveStatus(isOnline: false);
            await AuthService().signOut().then((value) {
              // for removing progress dialog
              Navigator.pop(context);
              // for moving to home screen
              Navigator.pop(context);

              API.auth = FirebaseAuth.instance;

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            });
          },
          icon: const Icon(
            Icons.logout,
            color: whiteColor,
          ),
          label: const Text(
            "Logout",
            style: TextStyle(color: whiteColor),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                top: mediaQuery.height * 0.03,
                bottom: mediaQuery.height * 0.05),
            shrinkWrap: true,
            children: [
              const Center(
                child: Text(
                  "Pick Profile Picture",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: mediaQuery.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: whiteColor,
                              fixedSize: Size(mediaQuery.width * 0.3,
                                  mediaQuery.height * 0.15),
                              shape: const CircleBorder()),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (image != null) {
                              log("image path: ${image.path}, mime type : ${image.mimeType}");
                              Navigator.pop(context);

                              setState(() {
                                _image = image.path;
                              });
                              API.updateProfilePicture(File(_image!));
                            }
                          },
                          child: Image.asset('assets/images/gallery.png')),
                      SizedBox(
                        height: mediaQuery.height * 0.01,
                      ),
                      const Text(
                        "Gallery",
                        style: TextStyle(fontSize: 17),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: whiteColor,
                              fixedSize: Size(mediaQuery.width * 0.3,
                                  mediaQuery.height * 0.15),
                              shape: const CircleBorder()),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);

                            if (image != null) {
                              log("image path: ${image.path}, mime type : ${image.mimeType}");
                              Navigator.pop(context);

                              setState(() {
                                _image = image.path;
                              });

                              API.updateProfilePicture(File(_image!));
                            }
                          },
                          child: Image.asset('assets/images/camera.png')),
                      SizedBox(
                        height: mediaQuery.height * 0.01,
                      ),
                      const Text(
                        "Camera",
                        style: TextStyle(fontSize: 17),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: mediaQuery.height * 0.02,
              ),
            ],
          );
        });
  }
}
