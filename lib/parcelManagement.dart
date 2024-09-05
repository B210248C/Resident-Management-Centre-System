import 'dart:async';
import 'package:dcdg/dcdg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:test1001/reportDetails.dart';
import 'package:test1001/startRMS.dart';
import 'adminHome.dart';
import 'approvalAccount.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'feedbackDetails.dart';
import 'makeAnnouncement.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:mailer/mailer.dart';

class ParcelManagement extends StatelessWidget {
  static String id = 'ParcelManagement_screen';

  const ParcelManagement({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ParcelManagementScreeen(),
        );
      },
    );
  }
}

class ParcelManagementScreeen extends StatefulWidget {
  const ParcelManagementScreeen({super.key});

  @override
  _ParcelManagementScreeenState createState() =>
      _ParcelManagementScreeenState();
}

class _ParcelManagementScreeenState extends State<ParcelManagementScreeen> {
  final List<ResidentItem> residentDetails = [];
  int _page = 0;
  late TextEditingController _searchController;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int _unreadAccountCount = 0;
  int _unreadReportCount = 0;
  int _unreadFeedbackCount = 0;
  bool _isFetchingR = false;
  bool _isFetchingF = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchResidents();
    _fetchUnreadAccountCount();
    _fetchUnreadReportCount();
    _fetchUnreadFeedbackCount();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchResidents();
      _fetchUnreadAccountCount();
      _fetchUnreadReportCount();
      _fetchUnreadFeedbackCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchUnreadAccountCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rolescollection')
          .where('role', isEqualTo: 'resident')
          .get();

      int count = querySnapshot.docs.where((doc) {
        bool accountstate = doc['accountstate'];
        if (!accountstate) {
          return true;
        }
        return false;
      }).length;

      setState(() {
        _unreadAccountCount = count;
      });
    } catch (e) {
      print("Error fetching number of account: $e");
    } finally {
      setState(() {
        _isFetching = false;
        print("Finished fetching number of account");
      });
    }
  }

  Future<void> _fetchUnreadReportCount() async {
    if (_isFetchingR) return;

    setState(() {
      _isFetchingR = true; // Only show loading indicator initially
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('report')
          .where('isRead', isEqualTo: false)
          .get();

      int countReport = snapshot.docs.length;

      setState(() {
        _unreadReportCount = countReport;
      });
    } catch (e) {
      print("Error fetching number of report: $e");
    } finally {
      setState(() {
        _isFetchingR = false;
        print("Finished fetching number of report");
      });
    }
  }

  Future<void> _fetchUnreadFeedbackCount() async {
    if (_isFetchingF) return;

    setState(() {
      _isFetchingF = true; // Only show loading indicator initially
    });

    try {
      QuerySnapshot Qsnapshot = await FirebaseFirestore.instance
          .collection('feedbackresident')
          .where('isRead', isEqualTo: false)
          .get();

      int countFeedback = Qsnapshot.docs.length;

      setState(() {
        _unreadFeedbackCount = countFeedback;
      });
    } catch (e) {
      print("Error fetching number of feedback: $e");
    } finally {
      setState(() {
        _isFetchingF = false;
        print("Finished fetching number of feedback");
      });
    }
  }

  Future<void> fetchResidents() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
      if (residentDetails.isEmpty)
        _isLoading = true; // Only show loading indicator initially
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rolescollection')
          .where('role', isEqualTo: 'resident')
          .where('accountstate', isEqualTo: true)
          .get();

      setState(() {
        residentDetails.clear();
        querySnapshot.docs.forEach((doc) {
          residentDetails.add(ResidentItem(
            name: doc["username"],
            phonenumber: doc["phone"],
            address: doc["address"],
            email: doc["email"],
          ));
        });
      });
    } catch (error) {
      print("Error fetching residents: $error"); // Debug print
    } finally {
      setState(() {
        _isFetching = false;
        _isLoading = false;
        print("Finished fetching residents"); // Debug print
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ResidentItem> filteredResident = residentDetails;
    if (_searchController.text.isNotEmpty) {
      final String searchTerm = _searchController.text.toLowerCase();
      filteredResident = residentDetails.where((resident) {
        return resident.phonenumber.toLowerCase().contains(searchTerm);
      }).toList();
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminHome()));
            },
          ),
          title: AutoSizeText(
            'Parcel Management',
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: const Color.fromRGBO(35, 73, 108, 1),
                fontSize: 14.sp,
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
                        style:
                            TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                      ),
                      content: AutoSizeText(
                        textScaleFactor: 1.3.sp,
                        'Are you sure you want to logout?',
                        style:
                            TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: AutoSizeText(
                            textScaleFactor: 1.2.sp,
                            'Cancel',
                            style: TextStyle(
                                fontFamily: 'Comfortaa', fontSize: 12.sp),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: AutoSizeText(
                            textScaleFactor: 1.2.sp,
                            'Logout',
                            style: TextStyle(
                                fontFamily: 'Comfortaa', fontSize: 12.sp),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StartRMS()),
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
            index: 4,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.check_circle, size: 30.r),
                  if (_unreadAccountCount > 0)
                    Positioned(
                      top: -3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadAccountCount',
                          textScaleFactor: 0.6.sp,
                          style: TextStyle(color: Colors.white, fontSize: 3.sp),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  Icon(Icons.feedback, size: 30.r),
                  if (_unreadReportCount > 0)
                    Positioned(
                      top: -3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadReportCount',
                          textScaleFactor: 0.6.sp,
                          style: TextStyle(color: Colors.white, fontSize: 3.sp),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  Icon(Icons.chat, size: 30.r),
                  if (_unreadFeedbackCount > 0)
                    Positioned(
                      top: -3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadFeedbackCount',
                          textScaleFactor: 0.6.sp,
                          style: TextStyle(color: Colors.white, fontSize: 3.sp),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              Icon(FontAwesomeIcons.box, size: 30.r),
              Icon(FontAwesomeIcons.bullhorn, size: 30.r),
            ],
            color: const Color.fromRGBO(255, 181, 167, 1),
            buttonBackgroundColor: const Color.fromRGBO(255, 143, 121, 1),
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeIn,
            animationDuration: const Duration(milliseconds: 400),
            onTap: (index) {
              setState(() {
                _page = index;
              });
              if (_page == 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AdminHome()));
              }
              if (_page == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountApproval()));
              }
              if (_page == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportDetails()));
              }
              if (_page == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackDetails()));
              }
              if (_page == 4) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParcelManagement()));
              }
              if (_page == 5) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MakeAnnouncement()));
              }
            },
            letIndexChange: (index) => true,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/parcelbg.png'),
              opacity: 0.2,
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: 8.h,
                bottom: MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight.h +
                    5.h),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: GoogleFonts.literata(
                      fontSize: 12.sp,
                      color: Colors.black,
                    ),
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search by phone',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 30.r,
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(255, 143, 121, 1),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(width: 1.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild on text change
                    },
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredResident.isEmpty
                        ? Center(
                            child: AutoSizeText(
                              'No resident available.',
                              textScaleFactor: 1.1.sp,
                              style: GoogleFonts.literata(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                                      .sp // Change font color for the selected item
                                  ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredResident.length,
                              itemBuilder: (context, index) {
                                final resident = filteredResident[index];
                                return ResidentCard(
                                  resident: resident,
                                  onTap: () {
                                    // Navigate to visitor details screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ResidentDetailsScreen(
                                          resident: resident,
                                          unreadAccountCount:
                                              _unreadAccountCount,
                                          unreadReportCount: _unreadReportCount,
                                          unreadFeedbackCount:
                                              _unreadFeedbackCount,
                                        ),
                                      ),
                                    );
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
}

class ResidentItem {
  final String name;
  final String phonenumber;
  final String address;
  final String email;

  ResidentItem({
    required this.name,
    required this.phonenumber,
    required this.address,
    required this.email,
  });
}

class ResidentCard extends StatelessWidget {
  final ResidentItem resident;
  final VoidCallback onTap;

  const ResidentCard({
    super.key,
    required this.resident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: const Color.fromRGBO(255, 216, 209, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: onTap,
            title: AutoSizeText(
              'Address: ${resident.address}',
              textScaleFactor: 1.2.sp,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.literata(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Name: ${resident.name}',
                  textScaleFactor: 1.2.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight: FontWeight.w400,
                    fontSize: 10.sp,
                    color: Colors.black,
                  ),
                ),
                AutoSizeText(
                  'Phone: ${resident.phonenumber}',
                  textScaleFactor: 1.2.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight: FontWeight.w400,
                    fontSize: 10.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class ResidentDetailsScreen extends StatefulWidget {
  final ResidentItem resident;
  final int unreadAccountCount;
  final int unreadReportCount;
  final int unreadFeedbackCount;

  const ResidentDetailsScreen({
    super.key,
    required this.resident,
    required this.unreadAccountCount,
    required this.unreadReportCount,
    required this.unreadFeedbackCount,
  });

  @override
  _ResidentDetailsScreenState createState() => _ResidentDetailsScreenState();
}

class _ResidentDetailsScreenState extends State<ResidentDetailsScreen> {
  int _page = 0;

  void _sendEmail() async {
    final outlookStmp =
        hotmail(dotenv.env['EMAIL_USERNAME']!, dotenv.env['EMAIL_PASSWORD']!);

    final message = Message()
      ..from = Address(dotenv.env['EMAIL_USERNAME']!, 'Smart Resident')
      ..recipients.add(widget.resident.email)
      ..subject = 'Parcel Notification'
      ..text = '''
Dear ${widget.resident.name},


We would like to inform you that your PARCEL has arrived! Please take your time to receive it in the cabinet: RESIDENT LOBBY BOX 1.


Sincerely,
Tester - Smart Resident Support Bot
''';

    try {
      final sendReport = await send(message, outlookStmp);
      print('Message sent: ${sendReport.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent successfully!')),
      );
    } catch (e) {
      print('Message not sent. $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }

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
          'Parcel Management',
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
                      style:
                          TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                    ),
                    content: AutoSizeText(
                      textScaleFactor: 1.3.sp,
                      'Are you sure you want to logout?',
                      style:
                          TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: AutoSizeText(
                          textScaleFactor: 1.2.sp,
                          'Cancel',
                          style: TextStyle(
                              fontFamily: 'Comfortaa', fontSize: 12.sp),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: AutoSizeText(
                          textScaleFactor: 1.2.sp,
                          'Logout',
                          style: TextStyle(
                              fontFamily: 'Comfortaa', fontSize: 12.sp),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StartRMS()),
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
          index: 4,
          height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
          items: <Widget>[
            Icon(Icons.home_filled, size: 30.r),
            Stack(
              children: [
                Icon(Icons.check_circle, size: 30.r),
                if (widget.unreadAccountCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadAccountCount}',
                        textScaleFactor: 0.6.sp,
                        style: TextStyle(color: Colors.white, fontSize: 3.sp),
                      ),
                      badgeAnimation: badges.BadgeAnimation.slide(),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            Stack(
              children: [
                Icon(Icons.feedback, size: 30.r),
                if (widget.unreadReportCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadReportCount}',
                        textScaleFactor: 0.6.sp,
                        style: TextStyle(color: Colors.white, fontSize: 3.sp),
                      ),
                      badgeAnimation: badges.BadgeAnimation.slide(),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            Stack(
              children: [
                Icon(Icons.chat, size: 30.r),
                if (widget.unreadFeedbackCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadFeedbackCount}',
                        textScaleFactor: 0.6.sp,
                        style: TextStyle(color: Colors.white, fontSize: 3.sp),
                      ),
                      badgeAnimation: badges.BadgeAnimation.slide(),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            Icon(FontAwesomeIcons.box, size: 30.r),
            Icon(FontAwesomeIcons.bullhorn, size: 30.r),
          ],
          color: const Color.fromRGBO(255, 181, 167, 1),
          buttonBackgroundColor: const Color.fromRGBO(255, 143, 121, 1),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeIn,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _page = index;
            });
            if (_page == 0) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminHome()));
            }
            if (_page == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountApproval()));
            }
            if (_page == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportDetails()));
            }
            if (_page == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackDetails()));
            }
            if (_page == 4) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParcelManagement()));
            }
            if (_page == 5) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MakeAnnouncement()));
            }
          },
          letIndexChange: (index) => true,
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(255, 237, 234, 1),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDetailContainer('ADDRESS', widget.resident.address),
            const SizedBox(height: 8),
            _buildDetailContainer('NAME', widget.resident.name),
            const SizedBox(height: 8),
            _buildDetailContainer('PHONE NUMBER', widget.resident.phonenumber),
            const SizedBox(height: 8),
            _buildDetailContainer(
              'EMAIL',
              widget.resident.email,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Send Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.19),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.23),
                        blurRadius: 6,
                        spreadRadius: 0,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      _sendEmail();
                      FirebaseFirestore.instance
                          .collection('announcement')
                          .add({
                        'email': widget.resident.email,
                        'timestamp': FieldValue.serverTimestamp(),
                        'type': 'parcel',
                        'sender': 'ADMIN',
                        'name': widget.resident.name,
                        'isRead': false,
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notification sent!')),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to send notification: $error')),
                        );
                      });
                    },
                    child: AutoSizeText(
                      'INFORM',
                      textScaleFactor: 1.2.sp,
                      style: GoogleFonts.literata(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60.h),
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
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            textScaleFactor: 1.2.sp,
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
