import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/parcelManagement.dart';
import 'package:test1001/reportDetails.dart';
import 'package:test1001/startRMS.dart';
import 'adminHome.dart';
import 'approvalAccount.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dcdg/dcdg.dart';
import 'feedbackDetails.dart';

class MakeAnnouncement extends StatelessWidget {
  static String id = 'MakeAnnouncement_screen';

  const MakeAnnouncement({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: makeAnnouncement(),
        );
      },
    );
  }
}

class makeAnnouncement extends StatefulWidget {
  const makeAnnouncement({super.key});

  @override
  State<makeAnnouncement> createState() => _makeAnnouncementState();
}

class _makeAnnouncementState extends State<makeAnnouncement> {
  int _page = 0;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _unreadAccountCount = 0;
  int _unreadReportCount = 0;
  int _unreadFeedbackCount = 0;
  Timer? _timer;
  bool _isFetching = false;
  bool _isFetchingR = false;
  bool _isFetchingF = false;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadAccountCount();
    _fetchUnreadReportCount();
    _fetchUnreadFeedbackCount();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchUnreadAccountCount();
      _fetchUnreadReportCount();
      _fetchUnreadFeedbackCount();
    });
  }

  Future<void> _fetchUnreadAccountCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try{
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
    }catch (e) {
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

    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('report')
          .where('isRead', isEqualTo: false)
          .get();

      int countReport = snapshot.docs.length;

      setState(() {
        _unreadReportCount = countReport;
      });
    }catch (e) {
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

    try{
      QuerySnapshot Qsnapshot = await FirebaseFirestore.instance
          .collection('feedbackresident')
          .where('isRead', isEqualTo: false)
          .get();

      int countFeedback = Qsnapshot.docs.length;

      setState(() {
        _unreadFeedbackCount = countFeedback;
      });
    }catch (e) {
      print("Error fetching number of feedback: $e");
    } finally {
      setState(() {
        _isFetchingF = false;
        print("Finished fetching number of feedback");
      });
    }
  }

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState?.validate() ?? false) {

        showLoadingDialog(context);

        await FirebaseFirestore.instance.collection('announcement').add({
          'subject': subjectController.text,
          'message': messageController.text,
          'type': 'announcement',
          'sender': 'ADMIN',
          'isRead': false,
          'timestamp': Timestamp.now(),
        });

        Navigator.of(context, rootNavigator: true).pop();
        _clearContent();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Announcement sent successfully!')),
        );

    }
  }

  void _clearContent() {
    setState(() {
      subjectController.clear();
      messageController.clear();
    });
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
              SizedBox(height: 20.0),
              Text('Loading...'),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.literata(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete the content you made?',
            style: GoogleFonts.literata(
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.literata(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _clearContent(); // Perform deletion
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Yes',
                style: GoogleFonts.literata(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // // Get screen size
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

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
            'Make Announcement',
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
            index: 5,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.check_circle, size: 30.r),
                  if (_unreadAccountCount > 0)
                    Positioned(
                      top:-3,
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
                      top:-3,
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
                      top:-3,
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AccountApproval()));
              }
              if (_page == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ReportDetails()));
              }
              if (_page == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const FeedbackDetails()));
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
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/MAKEANN.png'),
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.screen),
              opacity: 0.5,
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 20.h, left: 10.w, right: 10.w, bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight.h+15.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(2, 0),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                  bottomLeft: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 5.h, horizontal: 20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 3.h,
                      ),
                      TextField(
                        readOnly: true,
                        style: GoogleFonts.literata(
                          textStyle: TextStyle(
                            overflow: TextOverflow.visible,
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600, // Semibold
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.white,
                              size: 25.r,
                            ),
                          ),
                          hintText: 'ADMIN',
                          filled: true,
                          fillColor: const Color.fromRGBO(255, 179, 164, 1),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          contentPadding:
                              EdgeInsets.only(bottom: 5.h, right: 15.w),
                          hintStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 12.sp,
                              // fontSize: fontSize/13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600, // Semibold
                              letterSpacing: 0.8.w,
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        style: GoogleFonts.literata(
                          textStyle: TextStyle(
                            overflow: TextOverflow.visible,
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600, // Semibold
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              FontAwesomeIcons.bullhorn,
                              color: Colors.white,
                              size: 25.r,
                            ),
                          ),
                          hintText: 'ANNOUNCEMENT',
                          filled: true,
                          fillColor: const Color.fromRGBO(255, 179, 164, 1),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          contentPadding:
                              EdgeInsets.only(bottom: 5.h, right: 15.w),
                          hintStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600, // Semibold
                              letterSpacing: 0.8.w,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: subjectController,
                        style: GoogleFonts.literata(
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600, // Semibold
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              Icons.library_books,
                              color: const Color.fromRGBO(255, 181, 167, 1),
                              size: 25.r,
                            ),
                          ),
                          hintText: 'Subject',
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(255, 143, 121, 1),
                                width: 2.0),
                          ),
                          contentPadding: EdgeInsets.only(right: 15.w),
                          hintStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 13.sp,
                              // fontSize: fontSize/13,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600, // Semibold
                              letterSpacing: 0.8.w,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the subject';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: messageController,
                        maxLines: 7,
                        style: GoogleFonts.literata(
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600, // Semibold
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your message...',
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(255, 143, 121, 1),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(255, 143, 121, 1),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.only(
                              left: 10.w,
                              bottom: 20.h,
                              top: 20.h,
                              right: 10.w),
                          labelStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 11.sp,
                              color: const Color.fromRGBO(5, 190, 0, 1),
                              fontWeight: FontWeight.w900, // Semibold
                              letterSpacing: 0.8.w,
                            ),
                          ),
                          hintStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600, // Semibold
                              letterSpacing: 0.8.w,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the message';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              onPressed: () => _saveAnnouncement(),
                              child: AutoSizeText(
                                'SEND',
                                textScaleFactor: 1.2.sp,
                                style: GoogleFonts.literata(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          // Cancel Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
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
                                _showConfirmationDialog();
                              },
                              child: AutoSizeText(
                                'CANCEL',
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
                      SizedBox(
                        height: 12.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
