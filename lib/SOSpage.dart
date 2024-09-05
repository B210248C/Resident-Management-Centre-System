import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/announcementResident.dart';
import 'package:test1001/feedbackResident.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/utility.dart';
import 'package:test1001/visitorRegister.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';
import 'package:badges/badges.dart' as badges;

class SOSpage extends StatelessWidget {
  static String id = 'SOS_screen';

  const SOSpage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: soscall(),
        );
      },
    );
  }
}

class soscall extends StatefulWidget {
  const soscall({super.key});

  @override
  State<soscall> createState() => _soscallState();
}

class _soscallState extends State<soscall> {
  int _page = 0;
  bool _isFetching = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _unreadNotificationsCount = 0;
  Timer? _timer;

  Future<bool> showSOSDialog(BuildContext context) async {
    bool success = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AutoSizeText(
            'ALERT! Would you like to trigger the SOS?',
            textScaleFactor: 1.1.sp,
            textAlign: TextAlign.center,
            softWrap: true,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                  fontSize: 10.sp// Semibold
              ),
            ),
          ),
          content: AutoSizeText(
            'Press \'Yes\' to activate now.',
            textScaleFactor: 1.3.sp,
            textAlign: TextAlign.center,
            softWrap: true,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                  fontSize: 10.sp// Semibold
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {

                showLoadingDialog(context);

                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  String email = user.email ?? 'No Email';

                  // Fetch the username from rolescollection based on email
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('rolescollection')
                      .where('email', isEqualTo: email)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    String username =
                        querySnapshot.docs.first.get('username') ?? 'No Name';
                    String address =
                        querySnapshot.docs.first.get('address') ?? 'No Address';
                    String phone =
                        querySnapshot.docs.first.get('phone') ?? 'No Phone';

                    // Store user data in SOSdata collection
                    await FirebaseFirestore.instance.collection('SOSdata').add({
                      'email': email,
                      'name': username,
                      'address': address,
                      'phone': phone,
                      'timestamp': FieldValue.serverTimestamp(),
                      'checked': false,
                    });

                    success = true;

                    Navigator.of(context, rootNavigator: true)
                        .pop();
                    Navigator.of(context).pop();

                  }
                }
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return success;
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

  Future<void> _fetchUnreadNotificationsCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try{
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('announcement').get();

        int count = querySnapshot.docs.where((doc) {
          String type = doc['type'];
          bool isRead = doc['isRead'];
          if (type == 'announcement' && !isRead) {
            return true;
          } else if (type == 'parcel' && doc['email'] == currentUser.email && !isRead) {
            return true;
          }
          return false;
        }).length;

        setState(() {
          _unreadNotificationsCount = count;
        });
      }
    }catch (e) {
      print("Error fetching number of announcement: $e");
    } finally {
      setState(() {
        _isFetching = false;
        print("Finished fetching number of announcement");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationsCount();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchUnreadNotificationsCount();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // // Get screen size
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

    return SafeArea(
      child: Scaffold(
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
            'SOS',
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
            index: 3,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Icon(Icons.badge, size: 30.r),
              Icon(Icons.water_drop, size: 30.r),
              Icon(Icons.call, size: 30.r),
              Icon(Icons.feedback, size: 30.r),
              Icon(Icons.comment, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.notifications, size: 30.r),
                  if (_unreadNotificationsCount > 0)
                    Positioned(
                      top:-3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadNotificationsCount',
                          textScaleFactor: 0.6.sp,
                          style: TextStyle(color: Colors.white, fontSize: 5.sp),
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
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, -0.8),
              end: Alignment(-0, 0.5),
              colors: [
                Color.fromRGBO(233, 237, 201, 1),
                Color.fromRGBO(204, 213, 174, 1),
              ],
              stops: <double>[0.2, 1],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('images/guardBackground.png'),
                  fit: BoxFit.contain,
                  // matchTextDirection: true,
                  height: 170.h,
                  width: 350.h,
                ),
                SizedBox(
                  height: 80.h,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    minimumSize: Size(screenWidth * 0.6, 50.h),
                    backgroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    // shadowColor: Colors.blueAccent, // Remove default shadow
                  ),
                  onPressed: () async {
                    bool success = await showSOSDialog(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'You triggered the SOS. Alert is sent to the security.'),
                        ));
                      }
                  },
                  child: AutoSizeText(
                    'Trigger SOS Alert',
                    textScaleFactor: 1.3.sp,
                    style: GoogleFonts.literata(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                          fontSize: 14.sp// Semibold
                      ),
                    ),
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
