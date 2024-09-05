import 'dart:async';
import 'package:dcdg/dcdg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:test1001/reportGuard.dart';
import 'package:test1001/scannerSecurity.dart';
import 'package:test1001/securityHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test1001/visitorDetails.dart';

class SOSdetails extends StatelessWidget {
  static String id = 'SOSdetails_screen';

  const SOSdetails({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SOSdetailsScreeen(),
        );
      },
    );
  }
}

class SOSdetailsScreeen extends StatefulWidget {
  const SOSdetailsScreeen({super.key});

  @override
  _SOSdetailsScreeenState createState() => _SOSdetailsScreeenState();
}

class _SOSdetailsScreeenState extends State<SOSdetailsScreeen> {
  List<SOSItem> SOSDetails = [];
  int _page = 0;
  late TextEditingController _searchController;
  DateTime? _selectedDate;
  bool _isNewestFirst = true; // Sorting order flag
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchSOS();
    // Set up a periodic timer that calls setState every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      counter = 1;
      fetchSOS();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  void fetchSOS() async {
    if (_isFetching)
      return; // If a fetch operation is already in progress, return

    setState(() {
      _isFetching = true;
      if (SOSDetails.isEmpty && counter == 0) {
        _isLoading = true;
      } else {
        _isLoading = false;
      } // Only show loading indicator initially
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('SOSdata').get();
      setState(() {
        SOSDetails = snapshot.docs.map((doc) {
          return SOSItem(
            id: doc.id,
            name: doc["name"],
            email: doc['email'],
            address: doc['address'],
            phone: doc['phone'],
            timestamp: (doc["timestamp"] as Timestamp).toDate(),
            checked: doc['checked'] ?? false,
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching sos details: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isFetching = false;
        print("Finished fetching sos details");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<SOSItem> filteredSOS = SOSDetails;

    // Apply date filter
    if (_selectedDate != null) {
      filteredSOS = filteredSOS.where((sos) {
        return sos.timestamp.year == _selectedDate!.year &&
            sos.timestamp.month == _selectedDate!.month &&
            sos.timestamp.day == _selectedDate!.day;
      }).toList();
    }

    // Apply sorting order
    filteredSOS.sort((a, b) {
      return _isNewestFirst
          ? b.timestamp.compareTo(a.timestamp)
          : a.timestamp.compareTo(b.timestamp);
    });

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
            'SOS Details',
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
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            index: 3,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 25.r),
              Icon(Icons.qr_code_scanner, size: 25.r),
              Icon(FontAwesomeIcons.idBadge, size: 25.r),
              Icon(Icons.contact_phone, size: 25.r),
              Icon(Icons.feedback, size: 25.r),
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/VIEWGUARD.png'),
              opacity: 0.4,
              // colorFilter: ColorFilter.mode(Colors.white, BlendMode.screen),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight.h),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade700, // Background color
                          borderRadius:
                              BorderRadius.circular(50.r), // Rounded corners
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                // Set the text color
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal:
                                        16.w), // Adjust padding as needed
                              ),
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: AutoSizeText(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate!),
                                textScaleFactor: 1.2.sp,
                                style: GoogleFonts.literata(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 25.r,
                                  color: Colors.white, // Set icon color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isNewestFirst
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 25.r,
                          color: const Color.fromRGBO(
                              35, 73, 108, 1), // Set icon color
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewestFirst = !_isNewestFirst;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Divider(
                    color: Colors.grey, // specify the color you want here
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          'Info',
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.4.sp,
                          style: GoogleFonts.literata(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: AutoSizeText(
                          'Action',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.4.sp,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.literata(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Divider(
                    color: Colors.grey, // specify the color you want here
                    thickness: 1,
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SOSDetails.isEmpty
                    ? Center(
                  child: AutoSizeText(
                    'No one trigger SOS.',
                    textScaleFactor: 1.1.sp,
                    style: GoogleFonts.literata(
                        fontWeight: FontWeight.w500,
                      fontSize: 15.sp// Change font color for the selected item
                    ),
                  ),
                ) : Expanded(
                        child: ListView.builder(
                          itemCount: filteredSOS.length,
                          itemBuilder: (context, index) {
                            final SOS = filteredSOS[index];
                            return SOSCard(
                              SOS: SOS,
                              onChanged: (newValue) {
                                setState(() {
                                  SOS.checked = newValue ?? false;
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
}

class SOSItem {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  final DateTime timestamp;
  bool checked;

  SOSItem({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.timestamp,
    this.checked = false,
  });

  Future<void> updateCheckedStatus(bool newStatus) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('SOSdata')
        .doc(id)
        .update({'checked': newStatus});
    checked = newStatus;
  }
}

class SOSCard extends StatelessWidget {
  final SOSItem SOS;
  final ValueChanged<bool?> onChanged; // Add this callback

  const SOSCard({
    super.key,
    required this.SOS,
    required this.onChanged, // Initialize in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  color: const Color.fromRGBO(171, 193, 207, 1),
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: ListTile(
                      title: AutoSizeText(
                        'Name: ${SOS.name}',
                        textScaleFactor: 1.2.sp,
                        style: GoogleFonts.literata(
                          fontWeight: SOS.checked
                              ? FontWeight.normal
                              : FontWeight
                                  .bold, // Update the text style based on the checked state
                          color: Colors.black,
                          fontSize: 12.sp
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            'Phone: ${SOS.phone}',
                            textScaleFactor: 1.2.sp,
                            style: GoogleFonts.literata(
                              fontWeight: SOS.checked
                                  ? FontWeight.normal
                                  : FontWeight
                                      .bold, // Update the text style based on the checked state
                              color: Colors.black,
                              fontSize: 12.sp
                            ),
                          ),
                          AutoSizeText(
                            'Address: ${SOS.address}',
                            textScaleFactor: 1.2.sp,
                            style: GoogleFonts.literata(
                              fontWeight: SOS.checked
                                  ? FontWeight.normal
                                  : FontWeight
                                      .bold, // Update the text style based on the checked state
                              color: Colors.black,
                              fontSize: 12.sp
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          AutoSizeText(
                            '${SOS.name} has triggered the SOS on ${_formatTimestamp(SOS.timestamp)}',
                            textScaleFactor: 1.2.sp,
                            style: GoogleFonts.literata(
                              fontWeight: SOS.checked
                                  ? FontWeight.normal
                                  : FontWeight
                                      .bold, // Update the text style based on the checked state
                              color: Colors.black,
                              fontSize: 12.sp
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Checkbox(
                  value: SOS.checked,
                  onChanged: (newValue) async {
                    if (!SOS.checked) {
                      // Only allow checking, not unchecking
                      await SOS.updateCheckedStatus(newValue ?? false);
                      onChanged(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          Divider(
            color: Colors.grey, // specify the color you want here
            thickness: 1,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}
