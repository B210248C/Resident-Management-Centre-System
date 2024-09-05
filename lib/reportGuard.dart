import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1001/scannerSecurity.dart';
import 'package:test1001/securityHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/visitorDetails.dart';
import 'SOSdetail.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:dcdg/dcdg.dart';
import 'package:badges/badges.dart' as badges;

class ReportSecurity extends StatelessWidget {
  static String id = 'ReportSecurity_screen';

  const ReportSecurity({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: reportSecurity(),
        );
      },
    );
  }
}

class reportSecurity extends StatefulWidget {
  const reportSecurity({super.key});

  @override
  State<reportSecurity> createState() => _reportSecurityState();
}

class _reportSecurityState extends State<reportSecurity> {
  int _page = 0;
  // GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  TextEditingController timePicker = TextEditingController();
  TextEditingController datePicker = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();
  final TextEditingController _controllerC = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final int maxWords = 30;
  final Color buttonTextColor = const Color.fromRGBO(28, 16, 74, 1);
  final double buttonFontSize = 10.sp;
  final double borderRadius = 10.r;
  List<File> _selectedImages = [];
  get path => null;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int _unreadSOSCount = 0;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchUnreadSOSCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try{
      QuerySnapshot Snapshot = await FirebaseFirestore.instance
          .collection('SOSdata')
          .where('checked', isEqualTo: false)
          .get();

      int countReport = Snapshot.docs.length;

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

  Future<void> selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker
        .pickMultiImage(); // Use pickMultiImage for selecting multiple images

    if (pickedFiles != null) {
      // Check if the total number of selected images plus the newly picked images is less than or equal to 2
      if (_selectedImages.length + pickedFiles.length <= 2) {
        setState(() {
          // Add the newly picked images to the list of selected images
          _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      } else {
        // If the total exceeds 2, show a message indicating the limit has been reached
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select up to 2 images')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadSOSCount();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchUnreadSOSCount();
    });
  }

  Future<void> saveData() async {
    // Show loading dialog
    showLoadingDialog(context);

    List<String> imageUrls = [];
    for (File image in _selectedImages) {
      String imageName = path.basename(image.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('reports/$imageName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    await FirebaseFirestore.instance.collection('report').add({
      'name': _controller.text,
      'email': _controllerA.text,
      'subject': _controllerB.text,
      'message': _controllerC.text,
      'images': imageUrls,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });

    // Clear the form fields and selected images
    setState(() {
      _controller.clear();
      _controllerA.clear();
      _controllerB.clear();
      _controllerC.clear();
      _selectedImages.clear();
    });

    // Close loading dialog
    Navigator.of(context, rootNavigator: true).pop();
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report submitted successfully')),
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
                MaterialPageRoute(builder: (context) => const SecurityHome()),
              );
            },
          ),
          title: AutoSizeText(
            'Report',
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
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            index: 4,
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
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(0, 0, 0, 0.6),
                BlendMode.hardLight,
              ),
              image: AssetImage('images/GUARDREPORT.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight.h+15.h),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        TextFormField(
                          controller: _controller,
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
                                Icons.people,
                                color: const Color.fromRGBO(81, 99, 110, 1),
                                size: 25.r,
                              ),
                            ),
                            hintText: 'Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(174, 179, 182, 1),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(174, 179, 182, 1),
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
                            if (value == null ||
                                value.isEmpty ||
                                !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                              return 'Enter correct name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        TextFormField(
                          controller: _controllerA,
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
                                Icons.email,
                                color: const Color.fromRGBO(81, 99, 110, 1),
                                size: 25.r,
                              ),
                            ),
                            hintText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(174, 179, 182, 1),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(174, 179, 182, 1),
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
                            if (value == null ||
                                value.isEmpty ||
                                !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]@[a-zA-Z]{5,7}\.[a-zA-Z]{3,5}$')
                                    .hasMatch(value)) {
                              return 'Enter correct email format';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        TextFormField(
                          controller: _controllerB,
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
                                color: const Color.fromRGBO(81, 99, 110, 1),
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
                                  color: Color.fromRGBO(174, 179, 182, 1),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(174, 179, 182, 1),
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
                        SizedBox(
                          height: 15.h,
                        ),
                        SizedBox(
                          child: Scrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: TextFormField(
                                controller: _controllerA,
                                maxLines: 5,
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
                                      color: Color.fromRGBO(147, 255, 144, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(174, 179, 182, 1),
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
                                      color:
                                          const Color.fromRGBO(174, 179, 182, 1),
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
                                inputFormatters: [
                                  WordLimitFormatter(
                                      maxWords), // Ensure maxWords is defined and imported
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter the message';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                'MEDIA',
                                textScaleFactor: 1.2.sp,
                                style: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600, // Semibold
                                  ),
                                ),
                              ),
                            ),
                            buildCustomButton(
                              icon: Icons.photo_library,
                              label: 'Select from Gallery',
                              onPressed: selectFromGallery,
                            ),
                            SizedBox(height: 2.h),
                            _selectedImages.isNotEmpty
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 4.0.w,
                                      mainAxisSpacing: 4.0.h,
                                    ),
                                    itemCount: _selectedImages.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
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
                                  const Color.fromRGBO(81, 99, 110, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15.r),
                              ),
                              shadowColor: Colors.black, // Remove default shadow
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (_selectedImages.isNotEmpty) {
                                  await saveData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please select at least one image')),
                                  );
                                }
                              }
                            },
                            child: AutoSizeText(
                              'SUBMIT',
                              textScaleFactor: 1.2.sp,
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
    );
  }

  Widget buildCustomButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 193, 207, 1),
        foregroundColor: Colors.black,
        shadowColor: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        // fixedSize: Size(240.w, 20.h),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.black,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              overflow: TextOverflow.visible,
              style: GoogleFonts.milonga(
                color: buttonTextColor,
                fontSize: buttonFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordLimitFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitFormatter(this.maxWords);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final words = newValue.text.split(RegExp(r'\s+'));
    if (words.length > maxWords) {
      return oldValue;
    }
    return newValue;
  }
}
