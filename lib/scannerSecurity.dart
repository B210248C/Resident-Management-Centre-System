import 'dart:async';
import 'package:dcdg/dcdg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:test1001/reportGuard.dart';
import 'package:test1001/securityHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/visitorDetails.dart';
import 'SOSdetail.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

class ScannerSecurity extends StatelessWidget {
  static String id = 'ScannerSecurity_screen';

  const ScannerSecurity({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: scannerSecurity(),
        );
      },
    );
  }
}

class scannerSecurity extends StatefulWidget {
  const scannerSecurity({super.key});

  @override
  State<scannerSecurity> createState() => _scannerSecurityState();
}

class _scannerSecurityState extends State<scannerSecurity> {
  int _page = 0;

  // GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  TextEditingController timePicker = TextEditingController();
  TextEditingController datePicker = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerA = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int maxWords = 30;
  final Color buttonTextColor = const Color.fromRGBO(28, 16, 74, 1);
  final double buttonFontSize = 10.sp;
  final double borderRadius = 10.r;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isScanningPaused = false;
  Barcode? result;
  QRViewController? controllerQR;
  int _unreadSOSCount = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      const maxCharacters = 30;
      if (_controller.text.length > maxCharacters) {
        _controller.text = _controller.text.substring(0, maxCharacters);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });

    _fetchUnreadSOSCount();
  }

  Future<void> _fetchUnreadSOSCount() async {

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
        print("Finished fetching number of account");
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controllerQR = controller;
    });
    print("QRViewController created");
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanningPaused) {
        setState(() {
          result = scanData;
          print("Scanned data: $result");
          if (result != null) {
            _isScanningPaused = true;
            controller.pauseCamera();
            _fetchVisitorDetails(result!.code);
          }
        });
      }
    });
  }

  Future<void> _fetchVisitorDetails(String? qrCode) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('visitor')
          .where('qrcode', isEqualTo: qrCode)
          .get();

      for (var doc in querySnapshot.docs) {
        DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
        if (timestamp.add(Duration(days: 30)).isBefore(DateTime.now())) {
          await FirebaseFirestore.instance
              .collection('visitor')
              .doc(doc.id)
              .delete();
        }
      }

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _showVisitorDetailsDialog(data);
      } else if (querySnapshot.docs.isEmpty) {
        _showExpiredDialog();
      }
    } catch (e) {
      print('Error fetching visitor details: $e');
      _showErrorDialog();
    }
  }

  void _showVisitorDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data.containsKey('identity_card')
              ? 'Visitor Details'
              : 'Contractor Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Name: ${data['name']}'),
              Text('Car Plate: ${data['car_plate']}'),
              if (data.containsKey('identity_card'))
                Text('Identity Card: ${data['identity_card']}')
              else
                Text('Purpose: ${data['purpose']}'),
              Text('Phone Number: ${data['phone_number']}'),
              Text('Arrival DateTime: ${data['date']} ${data['time']}'),
              Text('Leave DateTime: ${data['enddate']} ${data['endtime']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
            ),
          ],
        );
      },
    );
  }

  void _resumeScanning() {
    setState(() {
      _isScanningPaused = false;
      controllerQR?.resumeCamera();
    });
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'ERROR',
            textScaleFactor: 1.3.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp
              ),
            ),
          ),
          content: AutoSizeText(
            'QR code has already expired.',
            textScaleFactor: 1.3.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Could not fetch visitor details.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
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
        backgroundColor: const Color.fromRGBO(130, 130, 130, 1),
        // backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25.r),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityHome()),
              );
            },
          ),
          title: AutoSizeText(
            'Scanner',
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: const Color.fromRGBO(35, 73, 108, 1),
                fontSize: 15.sp,
                shadows: const [
                  Shadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    // Black color with 30% opacity
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
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            index: 1,
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
        body: Padding(
          padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(children: [
                AutoSizeText(
                  'Place the QR code in the area provided.',
                  textScaleFactor: 1.1.sp,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.literata(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 10.sp
                  ),
                ),
              ]),
              SizedBox(
                height: 15.h,
              ),
              SizedBox(
                height: screenHeight * 0.4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: screenWidth,
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
