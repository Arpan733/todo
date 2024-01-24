import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:todo/screens/task_screen.dart';
import 'package:todo/services/notification.dart';
import 'package:todo/services/todo_storage.dart';
import 'package:uuid/uuid.dart';

class Utils {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Uuid uuid = Uuid();

  static flushBarErrorMessage(
      String message, BuildContext context, Color color) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        message:
            message.length > 50 ? '${message.substring(0, 50)}...' : message,
        duration: const Duration(seconds: 2),
        backgroundColor: color,
      )..show(context),
    );
  }

  static showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static bool isValidEmail(String email) {
    RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    return emailRegExp.hasMatch(email);
  }

  static Widget label(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          label,
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static listTile({
    required bool isDone,
    required Map<String, dynamic> data,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TaskScreen(
              data: data,
            ),
          ),
        );
      },
      child: Container(
        height: 500,
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDone ? Colors.blueGrey : Colors.blueAccent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDone ? Colors.blueGrey : Colors.blueAccent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                      child: TextScroll(
                        data['title'],
                        mode: TextScrollMode.endless,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(50, 0)),
                        delayBefore: const Duration(milliseconds: 1000),
                        pauseBetween: const Duration(milliseconds: 500),
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        firestore
                            .collection('tododata')
                            .doc(firebaseAuth.currentUser!.uid.toString())
                            .collection('todo')
                            .doc(data['id'])
                            .delete();

                        showToast('Task deleted');
                      } else if (value == 'edit') {
                        bottomSheet(
                          context: context,
                          isEdit: true,
                          title: data['title'],
                          description: data['description'],
                          tid: data['id'],
                          dt: data['taskTime'] ?? DateTime.now().toString(),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: GoogleFonts.robotoMono(
                              color:
                                  isDone ? Colors.blueGrey : Colors.blueAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: GoogleFonts.robotoMono(
                              color:
                                  isDone ? Colors.blueGrey : Colors.blueAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ];
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                child: Text(
                  data['description'],
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.robotoMono(
                    color: isDone ? Colors.blueGrey : Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                DateFormat('dd/MM/yyyy HH:mm a')
                    .format(DateTime.parse(data['taskTime'].toString())),
                style: GoogleFonts.robotoMono(
                  color: isDone ? Colors.blueGrey : Colors.blueAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bottomSheet({
    bool isEdit = false,
    String title = '',
    String description = '',
    String tid = '',
    String dt = '',
    required BuildContext context,
  }) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime dateTime = DateTime.now();

    if (title != '' && description != '' && tid != '' && dt != '') {
      titleController.text = title;
      descriptionController.text = description;
      dateTime = DateTime.parse(dt);
    }

    showModalBottomSheet(
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, set) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 480,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: titleController,
                      cursorColor: Colors.blueAccent,
                      cursorWidth: 3,
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.title_outlined,
                          color: Colors.blueAccent,
                        ),
                        label: Text(
                          'Title',
                          style: GoogleFonts.robotoMono(
                            color: Colors.blueAccent,
                          ),
                        ),
                        hintText: 'Title',
                        hintStyle: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: descriptionController,
                      cursorColor: Colors.blueAccent,
                      cursorWidth: 3,
                      maxLines: 5,
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          color: Colors.blueAccent,
                        ),
                        label: Text(
                          'Description',
                          style: GoogleFonts.robotoMono(
                            color: Colors.blueAccent,
                          ),
                        ),
                        hintText: 'Description',
                        hintStyle: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.center,
                        child: Text(
                          'Date: ',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dateTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            helpText: 'Select the date: ',
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme(
                                      brightness: Brightness.light,
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white,
                                      secondary: Colors.blueAccent,
                                      onSecondary: Colors.white,
                                      error: Colors.blueAccent,
                                      onError: Colors.white,
                                      background: Colors.white,
                                      onBackground: Colors.blueAccent,
                                      surface: Colors.white,
                                      onSurface: Colors.blueAccent,
                                    ),
                                    textTheme: GoogleFonts.robotoMonoTextTheme()
                                        .copyWith(
                                      bodyMedium: GoogleFonts.robotoMono(
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            set(() {
                              dateTime = dateTime.copyWith(
                                day: pickedDate.day,
                                month: pickedDate.month,
                                year: pickedDate.year,
                              );
                            });
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(dateTime),
                            style: GoogleFonts.robotoMono(
                              color: Colors.blueAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.center,
                        child: Text(
                          'Time: ',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(dateTime),
                            helpText: 'Select the time: ',
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme(
                                    brightness: Brightness.light,
                                    primary: Colors.blueAccent,
                                    onPrimary: Colors.white,
                                    secondary: Colors.blueAccent,
                                    onSecondary: Colors.white,
                                    error: Colors.blueAccent,
                                    onError: Colors.white,
                                    background: Colors.white,
                                    onBackground: Colors.blueAccent,
                                    surface: Colors.white,
                                    onSurface: Colors.blueAccent,
                                  ),
                                  textTheme: GoogleFonts.robotoMonoTextTheme()
                                      .copyWith(
                                    bodyMedium: GoogleFonts.robotoMono(
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (time != null) {
                            set(() {
                              dateTime = dateTime.copyWith(
                                hour: time.hour,
                                minute: time.minute,
                              );
                            });
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateFormat('HH:mm a').format(dateTime),
                            style: GoogleFonts.robotoMono(
                              color: Colors.blueAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          margin: const EdgeInsets.only(top: 30),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          String newTid = uuid.v4();
                          int nid =
                              DateTime.now().millisecondsSinceEpoch ~/ 1000;

                          if (titleController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                              'Please enter title.',
                              context,
                              Colors.red,
                            );
                          } else if (descriptionController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                              'Please enter description.',
                              context,
                              Colors.red,
                            );
                          } else {
                            if (isEdit) {
                              await ToDoStorage().editTask(
                                title: titleController.text,
                                description: descriptionController.text,
                                tid: tid,
                                nid: nid,
                                uid: FirebaseAuth.instance.currentUser!.uid
                                    .toString(),
                                dateTime: dateTime.toString(),
                                context: context,
                              );

                              FlutterLocalNotificationsPlugin().cancel(nid);

                              showToast('Task edited');
                            } else {
                              await ToDoStorage().addTask(
                                tid: newTid,
                                title: titleController.text,
                                description: descriptionController.text,
                                nid: nid,
                                uid: FirebaseAuth.instance.currentUser!.uid
                                    .toString(),
                                dateTime: dateTime.toString(),
                                context: context,
                              );

                              showToast('Task saved');
                            }

                            LocalNotification.scheduleNotification(
                              id: nid,
                              title: titleController.text,
                              body: descriptionController.text,
                              dateTime: dateTime.toString(),
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          margin: const EdgeInsets.only(top: 30),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isEdit ? 'Edit' : 'Save',
                            style: GoogleFonts.robotoMono(
                              color: Colors.blueAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
