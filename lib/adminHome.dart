import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/approvalAccount.dart';
import 'package:test1001/feedbackDetails.dart';
import 'package:test1001/makeAnnouncement.dart';
import 'package:test1001/parcelManagement.dart';
import 'package:test1001/reportDetails.dart';
import 'package:test1001/startRMS.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'component/functionColumnAdmin.dart';

class AdminHome extends StatelessWidget {
  static String id = 'AdminHome_screen';

  const AdminHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AdminHomePage(),
        );
      },
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _page = 0;
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
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
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
      if (kDebugMode) {
        print("Error fetching number of account: $e");
      }
    } finally {
      setState(() {
        _isFetching = false;
        if (kDebugMode) {
          print("Finished fetching number of account");
        }
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
      if (kDebugMode) {
        print("Error fetching number of report: $e");
      }
    } finally {
      setState(() {
        _isFetchingR = false;
        if (kDebugMode) {
          print("Finished fetching number of report");
        }
      });
    }
  }

  Future<void> _fetchUnreadFeedbackCount() async {
    if (_isFetchingF) return;

    setState(() {
      _isFetchingF = true; // Only show loading indicator initially
    });

    try{
      QuerySnapshot qsnapshot = await FirebaseFirestore.instance
          .collection('feedbackresident')
          .where('isRead', isEqualTo: false)
          .get();

      int countFeedback = qsnapshot.docs.length;

      setState(() {
        _unreadFeedbackCount = countFeedback;
      });
    }catch (e) {
      if (kDebugMode) {
        print("Error fetching number of feedback: $e");
      }
    } finally {
      setState(() {
        _isFetchingF = false;
        if (kDebugMode) {
          print("Finished fetching number of feedback");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // // Get screen size
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: Theme(
          data: Theme.of(context)
              .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
          child: CurvedNavigationBar(
            // key: _bottomNavigationKey,
            index: 0,
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
                        badgeAnimation: const badges.BadgeAnimation.slide(),
                        badgeStyle: const badges.BadgeStyle(
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
                        badgeAnimation: const badges.BadgeAnimation.slide(),
                        badgeStyle: const badges.BadgeStyle(
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
                        badgeAnimation: const badges.BadgeAnimation.slide(),
                        badgeStyle: const badges.BadgeStyle(
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ParcelManagement()));
              }
              if (_page == 5) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MakeAnnouncement()));
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
              image: AssetImage('images/AdminBG.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                height: screenHeight * 0.25,
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.w),
                          child: Container(
                            width: 350.w,
                            height: 170.h,
                            decoration: BoxDecoration(
                              backgroundBlendMode: BlendMode.lighten,
                              color: const Color.fromRGBO(255, 255, 255, 0.9),
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
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                                bottomLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0.h,
                                            horizontal: 10.w),
                                        child: SizedBox(
                                          width: 100.w,
                                          height: 120.h,
                                          child: Image(
                                            image: const AssetImage(
                                                'images/Adminicon.png'),
                                            fit: BoxFit.contain,
                                            matchTextDirection: true,
                                            height: (170*0.5).h,
                                            width: (350*0.25).h,
                                          ), // replace with actual image
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  runSpacing: 5.0.h,
                                  children: [
                                    AutoSizeText(
                                      'Hello,',
                                      textScaleFactor: 1.5.sp,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                      style: GoogleFonts.milonga(
                                        textStyle: TextStyle(
                                          color: const Color.fromRGBO(0, 59, 102, 1),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600, // Semibold
                                        ),
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Welcome Back!',
                                      textScaleFactor: 1.5.sp,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                      style: GoogleFonts.milonga(
                                        textStyle: TextStyle(
                                          color: const Color.fromRGBO(0, 59, 102, 1),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w400, // Semibold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 360.w,
                        height: 200.h,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 8.w),
                            child: PopupMenuButton<int>(
                              icon: Icon(
                                Icons.settings,
                                // color: Colors.grey[900],
                                color: const Color.fromRGBO(255, 143, 121, 1),
                                size: 35.r,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.logout,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 10.h,
                                      ),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              offset: const Offset(0, 56),
                              elevation: 2,
                              onSelected: (int menu) {
                                if (menu == 1) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: AutoSizeText('Confirm Logout', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 30.sp)),
                                        content: AutoSizeText('Are you sure you want to logout?', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 10.sp)),
                                        actions: [
                                          TextButton(
                                            child: AutoSizeText('Cancel', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 10.sp)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: AutoSizeText('Yes', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 10.sp)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const StartRMS(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0.w),
                child: AutoSizeText(
                  'MANAGE ALL RESIDENTIAL STUFF IN ONE!',
                  textScaleFactor: 1.3.sp,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: GoogleFonts.mateSc(
                    textStyle: TextStyle(
                      color: const Color.fromRGBO(255, 0, 67, 1),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Color.fromRGBO(
                              0, 0, 0, 0.5), // Black color with 50% opacity
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ], // Semibold
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Expanded(
                child: Container(
                  width: 360.w,
                  decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.lighten,
                    color: const Color.fromRGBO(255, 255, 255, 0.9),
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
                      topLeft: Radius.circular(25.r),
                      topRight: Radius.circular(25.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h, bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight.h+3.h),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing:15.0.w,
                              runSpacing: 35.0.h,
                              children: [
                                CustomColumn(
                                  title: 'Account Approval',
                                  imagePath: 'images/accountIcon.png',
                                  unreadCount: _unreadAccountCount,
                                  destination: const AccountApproval(),
                                  showBadge: true,
                                  overflowEllipsis: false,
                                  singleLine: false,
                                ),
                                CustomColumn(
                                  title: 'Report Details',
                                  imagePath: 'images/ViewReportIcon(1)(1).png',
                                  unreadCount: _unreadReportCount,
                                  destination: const ReportDetails(),
                                  showBadge: true,
                                  overflowEllipsis: false,
                                  singleLine: false,
                                ),
                                CustomColumn(
                                  title: 'Feedback Details',
                                  imagePath: 'images/feedbackphoto.png',
                                  unreadCount: _unreadFeedbackCount,
                                  destination: const FeedbackDetails(),
                                  showBadge: true,
                                  overflowEllipsis: false,
                                  singleLine: false,
                                ),
                                const CustomColumn(
                                  title: 'Parcel Management',
                                  imagePath: 'images/parcelphoto.png',
                                  unreadCount: 0,
                                  destination: ParcelManagement(),
                                  showBadge: false,
                                  overflowEllipsis: true,
                                  singleLine: false,
                                ),
                                const CustomColumn(
                                  title: 'Announcement',
                                  imagePath: 'images/NotificationIcon.png',
                                  unreadCount: 0,
                                  destination: MakeAnnouncement(),
                                  showBadge: false,
                                  overflowEllipsis: true,
                                  singleLine: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
