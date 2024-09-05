import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/reportGuard.dart';
import 'package:test1001/scannerSecurity.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/visitorDetails.dart';
import 'SOSdetail.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dcdg/dcdg.dart';
import 'package:badges/badges.dart' as badges;

class SecurityHome extends StatelessWidget {
  static String id = 'SecurityHome_screen';

  const SecurityHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: securityHome(),
        );
      },
    );
  }
}

class securityHome extends StatefulWidget {
  const securityHome({super.key});

  @override
  State<securityHome> createState() => _securityHomeState();
}

class _securityHomeState extends State<securityHome> {
  int _page = 0;
  int _unreadSOSCount = 0;
  Timer? _timer;
  bool _isFetching = false;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadSOSCount();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchUnreadSOSCount();
    });
  }

  Future<void> _fetchUnreadSOSCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('SOSdata')
          .where('checked', isEqualTo: false)
          .get();

      int countReport = querySnapshot.docs.length;

      setState(() {
        _unreadSOSCount = countReport;
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

  @override
  Widget build(BuildContext context) {
    // // Get screen size
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            index: 0,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Icon(Icons.qr_code_scanner, size: 30.r),
              Icon(FontAwesomeIcons.idBadge, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.contact_phone, size: 30.r),
                  if (_unreadSOSCount > 0)
                    Positioned(
                      top:-3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadSOSCount',
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
              Icon(Icons.feedback, size: 30.r),
            ],
            color: const Color.fromRGBO(93, 96, 97, 1),
            buttonBackgroundColor: const Color.fromRGBO(93, 98, 100, 1),
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
                        builder: (context) => const SecurityHome()));
              }
              if (_page == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScannerSecurity()));
              }
              if (_page == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Visitordetails()));
              }
              if (_page == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SOSdetails()));
              }
              if (_page == 4) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportSecurity()));
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
              image: AssetImage('images/guardBackground1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.only(top:5.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                                backgroundBlendMode: BlendMode.screen,
                                color: const Color.fromRGBO(238, 241, 243, 0.9),
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
                              child: Container(
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
                                                    'images/guardBackground.png'),
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
                                  color: Colors.grey[900],
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
                                          title: AutoSizeText('Confirm Logout', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 10.sp)),
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
                AutoSizeText(
                  'MANAGE RESIDENT SECURITY',
                  textScaleFactor: 1.3.sp,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: GoogleFonts.mateSc(
                    textStyle: TextStyle(
                      color: const Color.fromRGBO(0, 59, 102, 1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Color.fromRGBO(
                              0, 0, 0, 0.5), // Black color with 50% opacity
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ], // Semibold
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
                      backgroundBlendMode: BlendMode.screen,
                      color: const Color.fromRGBO(238, 241, 243, 0.9),
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
                                verticalDirection: VerticalDirection.up,
                                alignment: WrapAlignment.center,
                              spacing:25.0.w,
                              runSpacing: 15.0.h,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const SOSdetails()),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 120.w,
                                            height: 120.h,
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(163, 198, 193, 1),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.5),
                                                  blurRadius: 7,
                                                  spreadRadius: 0,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.r),
                                                topRight: Radius.circular(10.r),
                                                bottomLeft: Radius.circular(10.r),
                                                bottomRight: Radius.circular(10.r),
                                              ),
                                            ),
                                            child: Image.asset(
                                              'images/SOS.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0.h,
                                            right: 10.w,
                                            child: badges.Badge(
                                              badgeContent: Text(
                                                '$_unreadSOSCount',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              position: badges.BadgePosition.topEnd(top: 0, end: 0),
                                              badgeAnimation: badges.BadgeAnimation.slide(),
                                              badgeStyle: badges.BadgeStyle(
                                                shape: badges.BadgeShape.circle,
                                                badgeColor: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                      width: 120.w,
                                      child: AutoSizeText(
                                        'SOS Details',
                                        textScaleFactor: 1.2.sp,
                                        maxLines: 1,
                                        // textWidthBasis:
                                        //     TextWidthBasis.parent,
                                        textAlign:
                                        TextAlign.center,
                                        overflow:
                                        TextOverflow.visible,
                                        softWrap: true,
                                        style:
                                        GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            13.sp,
                                            fontWeight: FontWeight
                                                .w400, // Semibold
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const ReportSecurity()),
                                        );
                                      },
                                      child: Container(
                                        width: 120.w,
                                        height: 120.h,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(163, 198, 193, 1),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.5),
                                              blurRadius: 7,
                                              spreadRadius: 0,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.r),
                                            topRight: Radius.circular(10.r),
                                            bottomLeft: Radius.circular(10.r),
                                            bottomRight: Radius.circular(10.r),
                                          ),
                                        ),
                                        child: Image.asset(
                                          'images/reportIcon.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                      width: 120.w,
                                      child: AutoSizeText(
                                        'Report',
                                        textScaleFactor: 1.2.sp,
                                        maxLines: 1,
                                        // textWidthBasis:
                                        //     TextWidthBasis.parent,
                                        textAlign:
                                        TextAlign.center,
                                        overflow:
                                        TextOverflow.visible,
                                        softWrap: true,
                                        style:
                                        GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            13.sp,
                                            fontWeight: FontWeight
                                                .w400, // Semibold
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const ScannerSecurity()),
                                        );
                                      },
                                      child: Container(
                                        width: 120.w,
                                        height: 120.h,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(163, 198, 193, 1),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.5),
                                              blurRadius: 7,
                                              spreadRadius: 0,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.r),
                                            topRight: Radius.circular(10.r),
                                            bottomLeft: Radius.circular(10.r),
                                            bottomRight: Radius.circular(10.r),
                                          ),
                                        ),
                                        child: Image.asset(
                                          'images/scanME.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                      width: 120.w,
                                      child: AutoSizeText(
                                        'Scanner',
                                        textScaleFactor: 1.2.sp,
                                        maxLines: 1,
                                        // textWidthBasis:
                                        //     TextWidthBasis.parent,
                                        textAlign:
                                        TextAlign.center,
                                        overflow:
                                        TextOverflow.visible,
                                        softWrap: true,
                                        style:
                                        GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            13.sp,
                                            fontWeight: FontWeight
                                                .w400, // Semibold
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const Visitordetails()),
                                        );
                                      },
                                      child: Container(
                                        width: 120.w,
                                        height: 120.h,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(163, 198, 193, 1),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.5),
                                              blurRadius: 7,
                                              spreadRadius: 0,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.r),
                                            topRight: Radius.circular(10.r),
                                            bottomLeft: Radius.circular(10.r),
                                            bottomRight: Radius.circular(10.r),
                                          ),
                                        ),
                                        child: Image.asset(
                                          'images/VisitorView.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                      width: 120.w,
                                      child: AutoSizeText(
                                        'Visitor Details',
                                        textScaleFactor: 1.2.sp,
                                        maxLines: 2,
                                        // textWidthBasis:
                                        //     TextWidthBasis.parent,
                                        textAlign:
                                        TextAlign.center,
                                        overflow:
                                        TextOverflow.visible,
                                        softWrap: true,
                                        style:
                                        GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            13.sp,
                                            fontWeight: FontWeight
                                                .w400, // Semibold
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}
