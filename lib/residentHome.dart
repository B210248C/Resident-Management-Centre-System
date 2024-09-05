import 'dart:async';
import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1001/SOSpage.dart';
import 'package:test1001/announcementResident.dart';
import 'package:test1001/feedbackResident.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/utility.dart';
import 'package:test1001/visitorRegister.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResidentHome extends StatelessWidget {
  static String id = 'ResidentHome_screen';

  const ResidentHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: residentHome(),
        );
      },
    );
  }
}

class residentHome extends StatefulWidget {
  const residentHome({super.key});

  @override
  State<residentHome> createState() => _residentHomeState();
}

class _residentHomeState extends State<residentHome> {
  int _page = 0;
  String userName = 'Loading...';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _unreadNotificationsCount = 0;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int _unreadParcelCount = 0;
  int _unreadAnnouncementCount = 0;
  int _unreadParcelCountToday = 0;
  int _unreadAnnouncementCountToday = 0;
  bool _shouldShowDialog = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _loadProfileImage();
    _fetchUnreadNotificationsCount();
    _fetchAndShowDialogUnreadNotificationsCount();
    _checkDialogPreference();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchUnreadNotificationsCount();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchAndShowDialogUnreadNotificationsCount() async {

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('announcement').get();
        DateTime today = DateTime.now();
        DateTime startOfDay = DateTime(today.year, today.month, today.day);

        int parcelCount = 0;
        int announcementCount = 0;
        int parcelCountToday = 0;
        int announcementCountToday = 0;

        querySnapshot.docs.forEach((doc) {
          String type = doc['type'];
          bool isRead = doc['isRead'];
          Timestamp timestamp = doc['timestamp'];
          DateTime docDate = timestamp.toDate();

          if (type == 'parcel' && doc['email'] == currentUser.email && !isRead) {
            parcelCount++;
            if (docDate.isAfter(startOfDay)) {
              parcelCountToday++;
            }
          } else if (type == 'announcement' && !isRead) {
            announcementCount++;
            if (docDate.isAfter(startOfDay)) {
              announcementCountToday++;
            }
          }
        });

        setState(() {
          _unreadNotificationsCount = parcelCount + announcementCount;
          _unreadParcelCount = parcelCount;
          _unreadAnnouncementCount = announcementCount;
          _unreadParcelCountToday = parcelCountToday;
          _unreadAnnouncementCountToday = announcementCountToday;
        });

        if (_shouldShowDialog) {
          _showNotificationDialog();
        }
      }
    } catch (e) {
      print("Error fetching number of announcement: $e");
    } finally {
      setState(() {
        print("Finished fetching number of announcement");
      });
    }
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

  Future<void> _showNotificationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText('Unread Notifications', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 30.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText('Unread parcel messages: $_unreadParcelCount ($_unreadParcelCountToday today)', textScaleFactor: 1.2.sp,style: TextStyle(fontSize: 20.sp)),
              AutoSizeText('Unread residential news: $_unreadAnnouncementCount ($_unreadAnnouncementCountToday today)',  textScaleFactor: 1.2.sp,style: TextStyle(fontSize: 20.sp)),
            ],
          ),
          actions: [
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await prefs.setString(
                        'lastDialogShown_${user.uid}', DateTime.now().toIso8601String());
                  }
                  setState(() {
                    _shouldShowDialog = false;
                  });
                },
                child: AutoSizeText('Don\'t show again today', textScaleFactor: 1.2.sp, style: TextStyle(fontSize: 12.sp),),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: AutoSizeText('Close', textScaleFactor: 1.2.sp,style: TextStyle(fontSize: 16.sp)),
              ),
            ),

          ],
        );
      },
    );
  }

  Future<void> _checkDialogPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = _auth.currentUser;
    if (user != null) {
      String? lastDialogShown = prefs.getString('lastDialogShown_${user.uid}');
      if (lastDialogShown != null) {
        DateTime lastShownDate = DateTime.parse(lastDialogShown);
        DateTime today = DateTime.now();
        if (lastShownDate.year == today.year &&
            lastShownDate.month == today.month &&
            lastShownDate.day == today.day) {
          setState(() {
            _shouldShowDialog = false;
          });
        } else {
          setState(() {
            _shouldShowDialog = true;
          });
        }
      } else {
        setState(() {
          _shouldShowDialog = true;
        });
      }
    }
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('rolescollection')
          .doc(user.uid) // Assuming the document ID is the user UID
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['username'] ??
              'User'; // Update the userName with the fetched value
        });
      }
    }
  }

  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('rolescollection')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'resident')
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        setState(() {
          _profileImageUrl = userDoc['profileImageUrl'];
        });
      }
    }

    setState(() {
      _isLoading = false; // End loading
    });
  }

  Future<void> _pickAndUploadImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isLoading = true; // Start loading
      });

      User? user = _auth.currentUser;
      if (user != null) {
        Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images').child(user.uid);
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot storageSnapshot = await uploadTask;
        String downloadUrl = await storageSnapshot.ref.getDownloadURL();

        QuerySnapshot userDocs = await FirebaseFirestore.instance
            .collection('rolescollection')
            .where('email', isEqualTo: user.email)
            .where('role', isEqualTo: 'resident')
            .get();

        if (userDocs.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userDocs.docs.first;
          await FirebaseFirestore.instance
              .collection('rolescollection')
              .doc(userDoc.id)
              .update({'profileImageUrl': downloadUrl});

          setState(() {
            _profileImageUrl = downloadUrl;
          });
        }
      }

      setState(() {
        _isLoading = false; // End loading
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
          child: Column(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 360.w,
                          height: 200.h,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image:
                                  AssetImage('images/backgroundprofile.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(0, 3),
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(5, 0),
                              ),
                            ],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                            color: const Color.fromRGBO(160, 172, 189, 1),
                          ),
                        )),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                    child: Container(
                                      width: 110.w, // Width including border
                                      height: 110.h, // Height including border
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 5),
                                      ),
                                      child: Stack(
                                        children: [
                                          // CircleAvatar showing either the network image or the initial asset image
                                          CircleAvatar(
                                            backgroundColor: Colors.white70,
                                            radius: 50.0,
                                            backgroundImage: _profileImageUrl != null
                                                ? NetworkImage(_profileImageUrl!)
                                                : const AssetImage('images/PEOPLE.png') as ImageProvider,
                                            onBackgroundImageError: (_, __) {
                                              // Optional: Handle image load error if needed
                                            },
                                          ),
                                          // Show loading indicator only when loading a new image
                                          if (_isLoading && _profileImageUrl != null)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.black54,
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      color: Colors.black,
                                      onPressed: _pickAndUploadImage,
                                      icon: const Icon(Icons.add_a_photo),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 360.w,
                        height: 200.h,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
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
                                          fontSize: 16.sp,
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
                    ), //setting
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Container(
                  // color: Colors.black,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 35.h, left: 17.w, bottom: 20.h),
                          child: Column(
                            children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: SizedBox(
                                  width: screenWidth,
                                  child: AutoSizeText(
                                    'Welcome Back!',
                                    textScaleFactor: 1.3.sp,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                    style: GoogleFonts.milonga(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight:
                                            FontWeight.w600, // Semibold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5.w),
                                  child: SizedBox(
                                    width: screenWidth,
                                    child: AutoSizeText(
                                      userName,
                                      textScaleFactor: 1.3.sp,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.clip,
                                      softWrap: true,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight:
                                              FontWeight.w400, // Semibold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12.0.w,right: 12.0.w,bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight.h+5.h),
                          child: SingleChildScrollView(
                            child: Container(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 15.0.w,
                                runSpacing: 15.0.h,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const VisitorRegister()));
                                        },
                                        child: Container(
                                          width: 90.w,
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                250, 237, 205, 1),
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
                                              bottomRight:
                                                  Radius.circular(10.r),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'images/viditorIcon2.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      SizedBox(
                                        height: 60.h,
                                        width: 90.w,
                                        child: AutoSizeText(
                                          'Visitor Registration',
                                          textScaleFactor: 1.2.sp,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8.sp,
                                              fontWeight:
                                                  FontWeight.w400, // Semibold
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
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UtilityPage()));
                                        },
                                        child: Container(
                                          width: 90.w,
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                250, 237, 205, 1),
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
                                              bottomRight:
                                                  Radius.circular(10.r),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'images/moreIcon.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      SizedBox(
                                        height: 60.h,
                                        width: 90.w,
                                        child: AutoSizeText(
                                          'Utility',
                                          textScaleFactor: 1.2.sp,
                                          maxLines: 2,
                                          // textWidthBasis:
                                          //     TextWidthBasis.parent,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8.sp,
                                              fontWeight:
                                                  FontWeight.w400, // Semibold
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
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ReportResident()));
                                        },
                                        child: Container(
                                          width: 90.w,
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                250, 237, 205, 1),
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
                                              bottomRight:
                                                  Radius.circular(10.r),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'images/Icons3.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      SizedBox(
                                        height: 60.h,
                                        width: 90.w,
                                        child: AutoSizeText(
                                          'Report',
                                          textScaleFactor: 1.2.sp,
                                          maxLines: 2,
                                          // textWidthBasis:
                                          //     TextWidthBasis.parent,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8.sp,
                                              fontWeight:
                                                  FontWeight.w400, // Semibold
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
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const FeedbackResident()));
                                        },
                                        child: Container(
                                          width: 90.w,
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                250, 237, 205, 1),
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
                                              bottomRight:
                                                  Radius.circular(10.r),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'images/Icons(1)(1).png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      SizedBox(
                                        height: 60.h,
                                        width: 90.w,
                                        child: AutoSizeText(
                                          'Feedback',
                                          textScaleFactor: 1.2.sp,
                                          maxLines: 2,
                                          // textWidthBasis:
                                          //     TextWidthBasis.parent,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8.sp,
                                              fontWeight:
                                                  FontWeight.w400, // Semibold
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
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const NotificationApp()));
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 90.w,
                                              height: 90.h,
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    250, 237, 205, 1),
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
                                                  bottomRight:
                                                      Radius.circular(10.r),
                                                ),
                                              ),
                                              child: Image.asset(
                                                'images/annn.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Positioned(
                                              top: 5.h,
                                              right: 20.w,
                                              child: badges.Badge(
                                                badgeContent: Text(
                                                  '$_unreadNotificationsCount',
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
                                        height: 60.h,
                                        width: 100.w,
                                        child: AutoSizeText(
                                          'Announcement',
                                          textScaleFactor: 1.2.sp,
                                          maxLines: 1,
                                          // textWidthBasis:
                                          //     TextWidthBasis.parent,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8.sp,
                                              fontWeight:
                                                  FontWeight.w400, // Semibold
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }
}
