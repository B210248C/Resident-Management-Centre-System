import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/utility.dart';
import 'package:test1001/visitorRegister.dart';
import 'SOSpage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';
import 'feedbackResident.dart';

class NotificationApp extends StatelessWidget {
  static String id = 'NotificationApp_screen';

  const NotificationApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: NotificationScreen(),
        );
      },
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];
  MessageType selectedMessageType = MessageType.all;
  int _page = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      counter = 1;
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchNotifications() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
      if (notifications.isEmpty && counter == 0) {
        _isLoading = true;
      } else {
        _isLoading = false;
      }
    });

    try {
      // Get the currently authenticated user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fetch announcements from Firestore
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('announcement').get();

        List<NotificationItem> fetchedNotifications =
            querySnapshot.docs.where((doc) {
          String type = doc['type'];
          if (type == 'announcement') {
            return true;
          } else if (type == 'parcel') {
            return doc['email'] == currentUser.email;
          }
          return false;
        }).map<NotificationItem>((doc) {
          String type = doc['type'];
          if (type == 'announcement') {
            return NotificationItem(
              id: doc.id,
              sender: doc['sender'],
              subject: doc['subject'],
              message: doc['message'],
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
              isRead: doc['isRead'] ?? false,
              type: MessageType.values.firstWhere(
                  (e) => e.toString() == 'MessageType.${doc['type']}'),
            );
          }
          if (type == 'parcel') {
            return NotificationItem(
              id: doc.id,
              sender: doc['sender'],
              subject: 'Parcel',
              message:
                  'Hi, ${doc['name']}, your PARCEL has arrived! Please take your time to get your parcel. Your PARCEL is in the cabinet at: RESIDENT LOBBY BOX 1. Have a nice day :)',
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
              isRead: doc['isRead'] ?? false,
              type: MessageType.values.firstWhere(
                  (e) => e.toString() == 'MessageType.${doc['type']}'),
            );
          }
          // If the document type is neither 'announcement' nor 'parcel', return a null value.
          throw Exception('Unexpected document type');
        }).toList();

        // Sort notifications by timestamp in descending order
        fetchedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          notifications = fetchedNotifications;
        });
      } else {
        // Handle the case where there is no authenticated user
        print('No user is currently signed in.');
      }
    } catch (e) {
      print("Error fetching announcement: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isFetching = false;
        print("Finished fetching announcement");
      });
    }
  }

  void _updateIsReadStatus(String id) {
    FirebaseFirestore.instance
        .collection('announcement')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcement')
          .doc(id)
          .delete();
      print("Notification $id deleted successfully.");
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<NotificationItem> filteredNotifications = notifications;
    if (selectedMessageType != MessageType.all) {
      filteredNotifications = notifications
          .where((notification) => notification.type == selectedMessageType)
          .toList();
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25.r),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResidentHome()));
            },
          ),
          title: AutoSizeText(
            'Announcement',
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: const Color.fromRGBO(35, 73, 108, 1),
                fontSize: 15.sp,
                shadows: const [
                  Shadow(
                    color: Color.fromRGBO(
                        0, 0, 0, 0.3), // Black color with 30% opacity
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: AutoSizeText(
                        textScaleFactor: 1.4.sp,
                        'Logout',
                        style: TextStyle(
                            fontFamily: 'Comfortaa', fontSize: 12.sp),
                      ),
                      content: AutoSizeText(
                        textScaleFactor: 1.3.sp,
                        'Are you sure you want to logout?',
                        style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: AutoSizeText(
                            textScaleFactor: 1.2.sp,
                            'Cancel',
                            style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: AutoSizeText(
                            textScaleFactor: 1.2.sp,
                            'Logout',
                            style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const StartRMS()),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.logout, color: Colors.black),
            ),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: Theme(
          data: Theme.of(context)
              .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
          child: CurvedNavigationBar(
            // key: _bottomNavigationKey,
            index: 6,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 25.r),
              Icon(Icons.badge, size: 25.r),
              Icon(Icons.water_drop, size: 25.r),
              Icon(Icons.call, size: 30.r, color: Colors.red),
              Icon(Icons.feedback, size: 25.r),
              Icon(Icons.comment, size: 25.r),
              Icon(Icons.notifications, size: 25.r),
            ],
            color: const Color.fromRGBO(163, 177, 138, 1),
            buttonBackgroundColor: const Color.fromRGBO(88, 129, 87, 1),
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeIn,
            animationDuration: const Duration(milliseconds: 400),
            onTap: (index) {
              setState(() {
                _page = index;
              });
              if (_page == 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResidentHome()));
              }
              if (_page == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VisitorRegister()));
              }
              if (_page == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UtilityPage()));
              }
              if (_page == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SOSpage()));
              }
              if (_page == 4) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportResident()));
              }
              if (_page == 5) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackResident()));
              }
              if (_page == 6) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationApp()));
              }
            },
            letIndexChange: (index) => true,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/BGannounce.png'),
              opacity: 0.2,
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight.h +
                    5.h),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 2.0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(
                          190, 208, 194, 1), // Change container color
                      // borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<MessageType>(
                      value: selectedMessageType,
                      onChanged: (value) {
                        setState(() {
                          selectedMessageType = value!;
                        });
                      },
                      items: MessageType.values.map((type) {
                        return DropdownMenuItem<MessageType>(
                          value: type,
                          child: AutoSizeText(
                            _getMessageTypeText(type),
                            textScaleFactor: 1.3.sp,
                            style: GoogleFonts.literata(
                              fontSize: 16.sp, // Change font size
                              color: Colors.black, // Change font color
                            ),
                          ),
                        );
                      }).toList(),
                      style: GoogleFonts.literata(
                        fontSize:
                            16.0, // Change font size for the selected item
                        color: Colors
                            .white, // Change font color for the selected item
                      ),
                      dropdownColor: const Color.fromRGBO(190, 208, 194,
                          1), // Change the background color of the dropdown menu
                      underline: Container(),
                      iconEnabledColor: Colors.black,
                    ),
                  ),
                ),
                _isLoading? CircularProgressIndicator(): filteredNotifications.isEmpty
                    ? Center(
                  child: AutoSizeText(
                    'No announcements available.',
                    textScaleFactor: 1.1.sp,
                    style: GoogleFonts.literata(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp// Change font color for the selected item
                    ),
                  ),
                ) :  Expanded(
                        child: ListView.builder(
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return NotificationCard(
                              notification: notification,
                              onTap: () {
                                setState(() {
                                  notification.isRead = true;
                                });
                                _updateIsReadStatus(notification.id);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationDetailsScreen(
                                                notification: notification)));
                              },
                              onMarkAsRead: () {
                                setState(() {
                                  // Mark the notification as read
                                  notification.isRead = true;
                                });
                                _updateIsReadStatus(notification.id);
                              },
                              onDelete: () {
                                setState(() {
                                  // Remove the notification from the list
                                  filteredNotifications.remove(notification);
                                  // Delete the notification from Firestore
                                  _deleteNotification(notification.id);
                                });
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMessageTypeText(MessageType type) {
    switch (type) {
      case MessageType.all:
        return 'All Messages';
      case MessageType.announcement:
        return 'Announcement';
      case MessageType.parcel:
        return 'Parcel';
      default:
        return '';
    }
  }
}

enum MessageType {
  all,
  announcement,
  parcel,
}

class NotificationItem {
  final String id;
  final String sender;
  final String subject;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final MessageType type;

  NotificationItem({
    required this.id,
    required this.sender,
    required this.subject,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: const Color.fromRGBO(205, 214, 175, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: onTap,
            title: AutoSizeText(
              notification.sender,
              textScaleFactor: 1.3.sp,
              style: GoogleFonts.literata(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(right: 5.w),
              child: CircleAvatar(
                backgroundColor:
                    notification.isRead ? Colors.green : Colors.red,
                child: notification.type == MessageType.parcel
                    ? Center(
                        child: Icon(
                          FontAwesomeIcons.box,
                          size: 18.r,
                          color: Colors.white,
                        ),
                      )
                    : Center(
                        child: Icon(
                          FontAwesomeIcons.building,
                          size: 18.r,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    notification.subject,
                    textScaleFactor: 1.3.sp,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.literata(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    _formatTimestamp(notification.timestamp),
                    textScaleFactor: 1.2.sp,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                          fontSize: 12.sp
                      ),
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Mark as read',
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: onMarkAsRead,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Show an alert dialog to confirm deletion
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Confirm Deletion',
                          style: GoogleFonts.literata(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600, // Set cancel color to red
                          ),
                        ),
                        content: Text(
                            'Are you sure you want to delete this notification?',
                            style: GoogleFonts.literata(
                              fontSize: 12, // Set cancel color to red
                            )),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.literata(
                                color: Colors.red, // Set cancel color to red
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              onDelete(); // Perform deletion
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text(
                              'Yes',
                              style: GoogleFonts.literata(
                                color: Colors.black, // Set Yes color to black
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationDetailsScreen extends StatefulWidget {
  final NotificationItem notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  _NotificationDetailsScreenState createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25.r),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: AutoSizeText(
          'Announcement',
          textScaleFactor: 1.2.sp,
          style: GoogleFonts.literata(
            textStyle: TextStyle(
              color: const Color.fromRGBO(35, 73, 108, 1),
              fontSize: 15.sp,
              shadows: const [
                Shadow(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: AutoSizeText(
                      textScaleFactor: 1.4.sp,
                      'Logout',
                      style: TextStyle(
                          fontFamily: 'Comfortaa', fontSize: 12.sp),
                    ),
                    content: AutoSizeText(
                      textScaleFactor: 1.3.sp,
                      'Are you sure you want to logout?',
                      style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: AutoSizeText(
                          textScaleFactor: 1.2.sp,
                          'Cancel',
                          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: AutoSizeText(
                          textScaleFactor: 1.2.sp,
                          'Logout',
                          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const StartRMS()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
        child: CurvedNavigationBar(
          // key: _bottomNavigationKey,
          index: 6,
          height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
          items: <Widget>[
            Icon(Icons.home_filled, size: 25.r),
            Icon(Icons.badge, size: 25.r),
            Icon(Icons.water_drop, size: 25.r),
            Icon(Icons.call, size: 30.r, color: Colors.red),
            Icon(Icons.feedback, size: 25.r),
            Icon(Icons.comment, size: 25.r),
            Icon(Icons.notifications, size: 25.r),
          ],
          color: const Color.fromRGBO(163, 177, 138, 1),
          buttonBackgroundColor: const Color.fromRGBO(88, 129, 87, 1),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeIn,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _page = index;
            });
            if (_page == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResidentHome()));
            }
            if (_page == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VisitorRegister()));
            }
            if (_page == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UtilityPage()));
            }
            if (_page == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SOSpage()));
            }
            if (_page == 4) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportResident()));
            }
            if (_page == 5) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackResident()));
            }
            if (_page == 6) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationApp()));
            }
          },
          letIndexChange: (index) => true,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/BGannounce.png'),
            opacity: 0.4,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.screen),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDetailContainer('Sender:', widget.notification.sender),
            const SizedBox(height: 8),
            _buildDetailContainer(
              'Timestamp:',
              _formatTimestamp(widget.notification.timestamp),
            ),
            const SizedBox(height: 8),
            _buildDetailContainer('Subject:', widget.notification.subject),
            const SizedBox(height: 8),
            _buildDetailContainer('Message:', widget.notification.message),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContainer(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            label,
            textScaleFactor: 1.5.sp,
            style: GoogleFonts.literata(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            textScaleFactor: 1.5.sp,
            style: GoogleFonts.literata(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}
