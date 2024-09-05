import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test1001/historyQRcode.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/utility.dart';
import 'SOSpage.dart';
import 'announcementResident.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'feedbackResident.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dcdg/dcdg.dart';
import 'package:badges/badges.dart' as badges;


class VisitorRegister extends StatelessWidget {
  static String id = 'VisitorRegister_screen';

  const VisitorRegister({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: visitorRegister(),
        );
      },
    );
  }
}

class visitorRegister extends StatefulWidget {
  const visitorRegister({super.key});

  @override
  State<visitorRegister> createState() => _visitorRegisterState();
}

class _visitorRegisterState extends State<visitorRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController timePicker = TextEditingController();
  final TextEditingController datePicker = TextEditingController();
  final TextEditingController _timePicker = TextEditingController();
  final TextEditingController _datePicker = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _identityCardController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();
  final TextEditingController _unitNumberController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 1);
  int _page = 0;
  final GlobalKey _qrKey = GlobalKey();
  bool _isFetching = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _unreadNotificationsCount = 0;
  Timer? _timer;

  Future<void> _saveVisitorData() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      // Get the current user's email
      User? user = FirebaseAuth.instance.currentUser;
      String? userEmail = user?.email;

      String qrData =
          '${_namecontroller.text}|${_phoneController.text}|${_unitNumberController.text}|${_identityCardController.text}|${_carPlateController.text}|${timePicker.text}|${datePicker.text}';

      // Prepare the data to save
      Map<String, dynamic> visitorData = {
        'name': _namecontroller.text,
        'phone_number': _phoneController.text,
        'identity_card': _identityCardController.text,
        'car_plate': _carPlateController.text,
        'unit': _unitNumberController.text,
        'time': timePicker.text,
        'date': datePicker.text,
        'endtime': _timePicker.text,
        'enddate': _datePicker.text,
        'user_email': userEmail,
        'qrcode': qrData,
        'timestamp': DateTime.now(),
        'type': 'visitor',
      };

      // Save to Firestore
      try {
        DocumentReference visitorRef = await FirebaseFirestore.instance
            .collection('visitor')
            .add(visitorData);

        // Link to the 'rolescollection' with the account email
        if (userEmail != null) {
          DocumentReference rolesCollectionRef = FirebaseFirestore.instance
              .collection('rolescollection')
              .doc(userEmail);

          await rolesCollectionRef.set({
            'visitor_ref': visitorRef,
          }, SetOptions(merge: true));
        }

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        _showQRCodeDialog(qrData);

        _namecontroller.clear();
        _phoneController.clear();
        _identityCardController.clear();
        _carPlateController.clear();
        _unitNumberController.clear();
        timePicker.clear();
        datePicker.clear();
        _timePicker.clear();
        _datePicker.clear();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Visitor registration successful. You can see QR code in History.')));
      } catch (e) {
        // Handle the error
        print("Error saving visitor data: $e");
      }
    }
  }

  Future<void> _shareQRCodeImage(String qrData) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;

        final painter = QrPainter.withQr(
          qr: qrCode!,
          eyeStyle:
              QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFFFFFFFF)),
          dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFFFFFFFF)),
          gapless: true,
        );

        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/qr_code.png';
        final file = File(imagePath);

        // Generate the QR code image
        final picData =
            await painter.toImageData(2048, format: ImageByteFormat.png);
        await file.writeAsBytes(picData!.buffer.asUint8List());

        // Share the QR code image
        await Share.shareXFiles([XFile(file.path)],
            text: 'Here is the QR code');
      } else {
        print('Invalid QR code data');
      }
    } catch (e) {
      print("Error sharing QR code: $e");
    }
  }

  void _showQRCodeDialog(String qrData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _qrKey,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _shareQRCodeImage(qrData);
                    },
                    child: Text("Share"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
            'Visitor Registration',
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
            index: 1,
            height: 60.0.h > 75 ? 75 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Icon(Icons.badge, size: 30.r),
              Icon(Icons.water_drop, size: 30.r),
              Icon(Icons.call, size: 30.r, color: Colors.red),
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
            ],
            color: const Color.fromRGBO(163, 177, 138, 1),
            buttonBackgroundColor: const Color.fromRGBO(88, 129, 87, 1),
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 100),
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
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(0, 0, 0, 0.6),
                BlendMode.hardLight,
              ),
              image: AssetImage('images/bgCarpark.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 10.h, left: 20.w, right: 20.w, bottom: 5.h),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                tooltip: "History Page for QR code",
                                color: Colors.white,
                                iconSize: 30.r,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HistoryPage()));
                                },
                                icon: Icon(Icons.history)),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 45.r,
                            backgroundImage: const AssetImage(
                                'images/VISITOR.png'), // replace with actual image
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextFormField(
                            controller: _namecontroller,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                overflow: TextOverflow.visible,
                                fontSize: 11.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600, // Semibold
                                letterSpacing: 0.8.w,
                              ),
                            ),
                            decoration: InputDecoration(
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: BorderSide(color: Colors.red)),
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  color: const Color.fromRGBO(5, 190, 0, 1),
                                  size: 20.r,
                                ),
                              ),
                              hintText: 'Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.only(right: 15.w),
                              hintStyle: GoogleFonts.literata(
                                textStyle: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600, // Semibold
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                                return 'Enter correct username';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextFormField(
                            controller: _phoneController,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600, // Semibold
                                letterSpacing: 0.8.w,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Icon(
                                  FontAwesomeIcons.phone,
                                  color: const Color.fromRGBO(5, 190, 0, 1),
                                  size: 20.r,
                                ),
                              ),
                              hintText: 'Phone Number',
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.only(right: 15.w),
                              hintStyle: GoogleFonts.literata(
                                textStyle: TextStyle(
                                  fontSize: 11.sp,
                                  // fontSize: fontSize/13,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600, // Semibold
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                                      .hasMatch(value)) {
                                return 'Enter correct phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextFormField(
                            controller: _identityCardController,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600, // Semibold
                                letterSpacing: 0.8.w,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Icon(
                                  FontAwesomeIcons.addressCard,
                                  color: const Color.fromRGBO(5, 190, 0, 1),
                                  size: 20.r,
                                ),
                              ),
                              hintText: 'Identity Card',
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.only(right: 15.w),
                              hintStyle: GoogleFonts.literata(
                                textStyle: TextStyle(
                                  fontSize: 11.sp,
                                  // fontSize: fontSize/13,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600, // Semibold
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Enter correct identity card';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextFormField(
                            controller: _carPlateController,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600, // Semibold
                                letterSpacing: 0.8.w,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Icon(
                                  FontAwesomeIcons.car,
                                  color: const Color.fromRGBO(5, 190, 0, 1),
                                  size: 20.r,
                                ),
                              ),
                              hintText: 'Car Plate',
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.only(right: 15.w),
                              hintStyle: GoogleFonts.literata(
                                textStyle: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600, // Semibold
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter the car plate';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextFormField(
                            controller: _unitNumberController,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600, // Semibold
                                letterSpacing: 0.8.w,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Icon(
                                  FontAwesomeIcons.building,
                                  color: const Color.fromRGBO(5, 190, 0, 1),
                                  size: 20.r,
                                ),
                              ),
                              hintText: 'Unit',
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(147, 255, 144, 1),
                                    width: 1.0),
                              ),
                              contentPadding: EdgeInsets.only(right: 15.w),
                              hintStyle: GoogleFonts.literata(
                                textStyle: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600, // Semibold
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter the unit number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.5,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: datePicker,
                                  style: GoogleFonts.literata(
                                    textStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600, // Semibold
                                      letterSpacing: 0.8.w,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: Icon(
                                        Icons.date_range,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        size: 20.r,
                                      ),
                                    ),
                                    hintText: 'ARRIVAL DATE',
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(right: 15.w),
                                    hintStyle: GoogleFonts.literata(
                                      textStyle: TextStyle(
                                        fontSize: 10.sp,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        fontWeight: FontWeight.w600, // Semibold
                                        letterSpacing: 0.8.w,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime? datetime = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2024),
                                        lastDate: DateTime(2100));

                                    if (datetime != null) {
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(datetime);

                                      setState(() {
                                        datePicker.text = formattedDate;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (datePicker.text.isEmpty) {
                                      return 'Please choose a date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.35,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: timePicker,
                                  style: GoogleFonts.literata(
                                    textStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600, // Semibold
                                      letterSpacing: 0.8.w,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: Icon(
                                        FontAwesomeIcons.clock,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        size: 20.r,
                                      ),
                                    ),
                                    hintText: 'TIME',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(right: 15.w),
                                    hintStyle: GoogleFonts.literata(
                                      textStyle: TextStyle(
                                        fontSize: 11.sp,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        fontWeight: FontWeight.w600, // Semibold
                                        letterSpacing: 0.8.w,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    var time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now());

                                    if (time != null) {
                                      setState(() {
                                        timePicker.text = time.format(context);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (timePicker.text.isEmpty) {
                                      return 'Please choose a time';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.5,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _datePicker,
                                  style: GoogleFonts.literata(
                                    textStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600, // Semibold
                                      letterSpacing: 1.5.w,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: Icon(
                                        Icons.date_range,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        size: 20.r,
                                      ),
                                    ),
                                    hintText: 'LEAVE DATE',
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(right: 15.w),
                                    hintStyle: GoogleFonts.literata(
                                      textStyle: TextStyle(
                                        fontSize: 10.sp,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        fontWeight: FontWeight.w600, // Semibold
                                        letterSpacing: 0.8.w,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime? _datetime = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2024),
                                        lastDate: DateTime(2100));

                                    if (_datetime != null) {
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(_datetime);

                                      setState(() {
                                        _datePicker.text = formattedDate;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (_datePicker.text.isEmpty) {
                                      return 'Please choose a date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.35,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _timePicker,
                                  style: GoogleFonts.literata(
                                    textStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600, // Semibold
                                      letterSpacing: 1.5.w,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: Icon(
                                        FontAwesomeIcons.clock,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        size: 20.r,
                                      ),
                                    ),
                                    hintText: 'TIME',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(147, 255, 144, 1),
                                          width: 1.0),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(right: 15.w),
                                    hintStyle: GoogleFonts.literata(
                                      textStyle: TextStyle(
                                        fontSize: 11.sp,
                                        color:
                                            const Color.fromRGBO(5, 190, 0, 1),
                                        fontWeight: FontWeight.w600, // Semibold
                                        letterSpacing: 0.8.w,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    var _time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now());

                                    if (_time != null) {
                                      setState(() {
                                        _timePicker.text =
                                            _time.format(context);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (_timePicker.text.isEmpty) {
                                      return 'Please choose a time';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 18.h,
                          ),
                          Container(
                            width: screenWidth * 0.5,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(60.r), // Border radius
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
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromRGBO(144, 169, 85, 1),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.r), // Border radius
                                  // side: BorderSide(
                                  //   color: Colors.black, // Stroke color
                                  //   width: 5, // Stroke width
                                  // ),
                                ),
                                shadowColor:
                                    Colors.black, // Remove default shadow
                              ),
                              onPressed: _saveVisitorData,
                              child: AutoSizeText(
                                'Generate QR',
                                textScaleFactor: 1.3.sp,
                                style: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600, // Semibold
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
