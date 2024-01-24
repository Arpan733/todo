import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/services/todo_storage.dart';
import 'package:todo/utils.dart';

import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ToDoStorage storage = ToDoStorage();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late User user;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  bool editUsername = false;
  bool editEmail = false;
  bool editMobileNo = false;

  bool isMale = true;

  @override
  void initState() {
    getUserData();

    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();

    super.dispose();
  }

  Future<void> getUserData() async {
    user = firebaseAuth.currentUser!;
    usernameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';

    String mobile = await storage.getUserField('phone', user.uid, context);

    if (mobile != 'phone') {
      mobileController.text = mobile;
    }

    String gender = await storage.getUserField('gender', user.uid, context);

    if (gender != 'gender') {
      if (gender == 'Male') {
        isMale = true;
      } else {
        isMale = false;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(
          'Profile',
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: ClipOval(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset('assets/user.png');
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles();

                          if (result != null) {
                            PlatformFile pickedFile = result.files.first;

                            final ref = FirebaseStorage.instance
                                .ref()
                                .child('${user.uid}/${pickedFile.name}');
                            UploadTask upload =
                                ref.putFile(File(pickedFile.path!));
                            final snapshot = await upload.whenComplete(() {});
                            final url = await snapshot.ref.getDownloadURL();
                            user.updatePhotoURL(url.toString());

                            if (!mounted) return;

                            await storage.editField(
                                'url', url.toString(), user.uid, context);

                            setState(() {
                              photoUrl = url;
                            });
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.photo_camera_back_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 65,
                width: 350,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
                child: TextFormField(
                  readOnly: !editUsername,
                  controller: usernameController,
                  cursorColor: Colors.blueAccent,
                  cursorWidth: 3,
                  style: GoogleFonts.robotoMono(
                    color: Colors.blueAccent,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Username',
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                    ),
                    hintText: 'Username',
                    hintStyle: GoogleFonts.robotoMono(
                      color: Colors.blueAccent,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          editUsername = !editUsername;
                        });
                      },
                      icon: Icon(
                        editUsername
                            ? Icons.edit_off_outlined
                            : Icons.edit_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    editUsername = true;
                  },
                  onFieldSubmitted: (value) {
                    if (usernameController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                          'Please enter username.', context, Colors.red);
                    } else {
                      user.updateDisplayName(
                          usernameController.text.toString());
                      storage.editField(
                          'username',
                          usernameController.text.toString(),
                          user.uid,
                          context);

                      setState(() {
                        editUsername = false;
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 65,
                width: 350,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
                child: TextFormField(
                  readOnly: !editEmail,
                  controller: emailController,
                  cursorColor: Colors.blueAccent,
                  cursorWidth: 3,
                  style: GoogleFonts.robotoMono(
                    color: Colors.blueAccent,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Email',
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                    ),
                    hintText: 'Email',
                    hintStyle: GoogleFonts.robotoMono(
                      color: Colors.blueAccent,
                    ),
                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                height: 65,
                width: 350,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
                child: TextFormField(
                  readOnly: !editMobileNo,
                  controller: mobileController,
                  cursorColor: Colors.blueAccent,
                  cursorWidth: 3,
                  style: GoogleFonts.robotoMono(
                    color: Colors.blueAccent,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.call,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Mobile No.',
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                    ),
                    hintText: 'Mobile No.',
                    hintStyle: GoogleFonts.robotoMono(
                      color: Colors.blueAccent,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          editMobileNo = !editMobileNo;
                        });
                      },
                      icon: Icon(
                        editMobileNo
                            ? Icons.edit_off_outlined
                            : Icons.edit_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    setState(() {
                      editMobileNo = true;
                    });
                  },
                  onFieldSubmitted: (value) {
                    if (mobileController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                        'Please enter mobile no.',
                        context,
                        Colors.red,
                      );
                    } else if (mobileController.text.length != 10) {
                      Utils.flushBarErrorMessage(
                        'Length of mobile no must be 10.',
                        context,
                        Colors.red,
                      );
                    } else {
                      storage.editField('phone',
                          mobileController.text.toString(), user.uid, context);

                      setState(() {
                        editMobileNo = false;
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 65,
                width: 350,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
                child: DropdownButtonFormField(
                  value: isMale ? 'Male' : 'Female',
                  items: [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text(
                        'Male',
                        style: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text(
                        'Female',
                        style: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    storage.editField('gender', value!, user.uid, context);

                    if (value == 'Male') {
                      isMale = true;
                    } else if (value == 'Female') {
                      isMale = false;
                    }

                    setState(() {});
                  },
                  iconEnabledColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      isMale ? Icons.male_outlined : Icons.female_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    label: Text(
                      'Gender',
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
