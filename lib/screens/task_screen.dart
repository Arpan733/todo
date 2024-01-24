import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo/services/todo_storage.dart';
import 'package:todo/utils.dart';

import '../services/notification.dart';

class TaskScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const TaskScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  ToDoStorage storage = ToDoStorage();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime dateTime = DateTime.now();

  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    titleController.text = widget.data['title'];
    descriptionController.text = widget.data['description'];
    dateTime = DateTime.parse(widget.data['taskTime']);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: TextField(
          controller: titleController,
          cursorColor: Colors.white,
          cursorWidth: 3,
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Title',
            hintStyle: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              int nid = DateTime.now().millisecondsSinceEpoch ~/ 1000;

              storage.editTask(
                title: titleController.text,
                description: descriptionController.text,
                tid: widget.data['id'],
                nid: nid,
                uid: user.uid,
                dateTime: dateTime.toString(),
                context: context,
              );

              FlutterLocalNotificationsPlugin().cancel(nid);
              LocalNotification.scheduleNotification(
                id: nid,
                title: titleController.text,
                body: descriptionController.text,
                dateTime: dateTime.toString(),
              );

              Utils.showToast('Task edited');
            },
            icon: const Icon(
              Icons.save_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: TextField(
          controller: descriptionController,
          maxLines: 27,
          cursorColor: Colors.blueAccent,
          cursorWidth: 3,
          style: GoogleFonts.robotoMono(
            color: Colors.blueAccent,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'description',
            hintStyle: GoogleFonts.robotoMono(
              color: Colors.blueAccent,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blueAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
                          textTheme: GoogleFonts.robotoMonoTextTheme().copyWith(
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
                  DateTime newDateTime = dateTime;
                  newDateTime = newDateTime.copyWith(
                    day: pickedDate.day,
                    month: pickedDate.month,
                    year: pickedDate.year,
                  );
                  dateTime = newDateTime;

                  setState(() {});
                }
              },
              child: Container(
                height: 50,
                width: 150,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: Text(
                  DateFormat('dd/MM/yyyy').format(dateTime),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              width: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
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
                        textTheme: GoogleFonts.robotoMonoTextTheme().copyWith(
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
                  DateTime newDateTime = dateTime;
                  newDateTime = newDateTime.copyWith(
                    hour: time.hour,
                    minute: time.minute,
                  );
                  dateTime = newDateTime;

                  setState(() {});
                }
              },
              child: Container(
                height: 50,
                width: 150,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: Text(
                  DateFormat('HH:mm a').format(dateTime),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
