import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/screens/profile_screen.dart';
import 'package:todo/services/todo_storage.dart';
import 'package:todo/utils.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String photoUrl = '';

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  ToDoStorage storage = ToDoStorage();
  late User user;
  String username = 'user';

  bool isByCreate = true;

  @override
  void initState() {
    getUser();
    print(tz.TZDateTime.now(tz.local));
    print(tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)));

    FlutterLocalNotificationsPlugin()
        .pendingNotificationRequests()
        .then((value) {
      print(value.length);
    });

    super.initState();
  }

  getUser() async {
    user = FirebaseAuth.instance.currentUser!;
    username = user.displayName.toString();
    photoUrl = await storage.getUrl(user.uid);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(
          'Hello, ${FirebaseAuth.instance.currentUser!.displayName.toString()}',
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu_outlined,
              color: Colors.white,
              size: 30,
            ),
          );
        }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'createTime') {
                setState(() {
                  isByCreate = true;
                });
              } else if (value == 'taskTime') {
                setState(() {
                  isByCreate = false;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'taskTime',
                  child: Text(
                    'Sort by Task Time',
                    style: GoogleFonts.robotoMono(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'createTime',
                  child: Text(
                    'Sort by Create Time',
                    style: GoogleFonts.robotoMono(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ];
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: StreamBuilder(
          stream: firestore
              .collection('tododata')
              .doc(user.uid)
              .collection('todo')
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.active) {
              if (snapshots.hasData && snapshots.data != null) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisExtent: 210,
                  ),
                  itemCount: snapshots.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    List<DocumentSnapshot>? dataList =
                        snapshots.data?.docs.toList();

                    if (isByCreate) {
                      dataList?.sort((a, b) {
                        DateTime aDate = DateTime.parse(a['createdTime']);
                        DateTime bDate = DateTime.parse(b['createdTime']);
                        return bDate.compareTo(aDate);
                      });
                    } else if (!isByCreate) {
                      dataList?.sort((a, b) {
                        DateTime aDate = DateTime.parse(a['taskTime']);
                        DateTime bDate = DateTime.parse(b['taskTime']);
                        return aDate.compareTo(bDate);
                      });
                    }

                    Map<String, dynamic>? data =
                        dataList?[index].data() as Map<String, dynamic>?;

                    bool isDone = DateTime.now()
                        .isAfter(DateTime.parse(data?['taskTime']));

                    return Utils.listTile(
                        isDone: isDone, data: data!, context: context);
                  },
                );
              } else {
                return const Center(
                  child: Text('No Data!'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  value: 20,
                  color: Colors.blueAccent,
                ),
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () async {
            Utils.bottomSheet(context: context);
          },
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      drawer: drawer(),
    );
  }

  Drawer drawer() {
    String photo = photoUrl;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
            currentAccountPicture: Container(
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              child: ClipOval(
                child: Image.network(
                  photo,
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset('assets/user.png');
                  },
                ),
              ),
            ),
            accountName: Text(
              FirebaseAuth.instance.currentUser!.displayName.toString(),
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser!.email.toString(),
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: Colors.blueAccent,
              size: 25,
            ),
            title: Text(
              'Profile',
              style: GoogleFonts.robotoMono(
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          const Divider(
            thickness: 2,
            color: Colors.blueAccent,
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.blueAccent,
              size: 25,
            ),
            title: Text(
              'Logout',
              style: GoogleFonts.robotoMono(
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
            onTap: () {
              firebaseAuth.signOut();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const Divider(
            thickness: 2,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
