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
import 'package:badges/badges.dart' as badges;
import 'SOSdetail.dart';

class Visitordetails extends StatelessWidget {
  static String id = 'Visitordetails_screen';

  const Visitordetails({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: VisitordetailsScreeen(),
        );
      },
    );
  }
}

class VisitordetailsScreeen extends StatefulWidget {
  const VisitordetailsScreeen({super.key});

  @override
  _VisitordetailsScreeenState createState() => _VisitordetailsScreeenState();
}

class _VisitordetailsScreeenState extends State<VisitordetailsScreeen> {
  List<VisitorItem> visitorDetails = [];
  int _page = 0;
  late TextEditingController _searchController;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isFetchingF = false; // Add this flag
  String _filter = 'all';
  int _unreadSOSCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchVisitors();
    _fetchUnreadSOSCount();
    // Set up a periodic timer that calls fetchVisitors every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchVisitors();
      _fetchUnreadSOSCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchUnreadSOSCount() async {
    if (_isFetchingF) return;

    setState(() {
      _isFetchingF = true; // Only show loading indicator initially
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
        _isFetchingF = false;
        print("Finished fetching number of account");
      });
    }
  }

  void fetchVisitors() async {
    if (_isFetching) return; // If a fetch operation is already in progress, return

    setState(() {
      _isFetching = true;
      if (visitorDetails.isEmpty) _isLoading = true; // Only show loading indicator initially
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('visitor').get();
      setState(() {
        visitorDetails = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return VisitorItem(
            id: doc.id,
            name: data["name"],
            identitycard: data.containsKey('identity_card') ? data['identity_card'] : '', // Default to an empty string if not present
            phonenumber: data['phone_number'],
            carplate: data['car_plate'],
            date: data['date'],
            time: data['time'],
            enddate: data['enddate'],
            endtime: data['endtime'],
            type: data['type'],
            purpose: data.containsKey('purpose') ? data['purpose'] : '', // Default to an empty string if not present
            unit: data.containsKey('unit') ? data['unit'] : '', // Default to an empty string if not present
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching visitor details: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isFetching = false;
        print("Finished fetching visitor details");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<VisitorItem> filteredVisitors = visitorDetails;
    if (_searchController.text.isNotEmpty) {
      final String searchTerm = _searchController.text.toLowerCase();
      filteredVisitors = visitorDetails.where((visitor) {
        return visitor.name.toLowerCase().contains(searchTerm);
      }).toList();
    }

    if (_filter != 'all') {
      filteredVisitors = filteredVisitors.where((visitor) {
        return visitor.type.toLowerCase() == _filter;
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityHome()),
              );
            },
          ),
          title: AutoSizeText(
            'Visitor Details',
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
            index: 2,
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/VIEWGUARD.png'),
              opacity: 0.4,
              // colorFilter: ColorFilter.mode(Colors.white, BlendMode.screen),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight.h),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 50.h,
                    ),
                    child: TextField(
                      style: GoogleFonts.literata(
                        fontSize: 12.sp,
                        color: Colors.black,
                      ),
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search by name',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30.r,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild on text change
                      },
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,    // specify the color you want here
                  thickness: 1,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(171, 193, 207, 1),
                        borderRadius: BorderRadius.circular(8.r),
                        // border: Border.all(color: Colors.grey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filter,
                          onChanged: (String? newValue) {
                            setState(() {
                              _filter = newValue!;
                            });
                          },
                          items: <String>['all', 'contractor', 'visitor']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(
                                value,
                                textScaleFactor: 1.2.sp,
                                style: GoogleFonts.literata(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp
                                ),
                              ),
                            );
                          }).toList(),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                          dropdownColor: Color.fromRGBO(171, 193, 207, 1),
                          // isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredVisitors.isEmpty
                    ? Center(
                  child: AutoSizeText(
                    'No visitors or contractors registered.',
                    textScaleFactor: 1.1.sp,
                    style: GoogleFonts.literata(
                        fontWeight: FontWeight.w500,
                      fontSize: 15.sp// Change font color for the selected item
                    ),
                  ),
                ) :Expanded(
                  child: ListView.builder(
                    itemCount: filteredVisitors.length,
                    itemBuilder: (context, index) {
                      final visitor = filteredVisitors[index];
                      return VisitorCard(
                        visitor: visitor,
                        onTap: () {
                          // Navigate to visitor details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisitorDetailsScreen(
                                visitor: visitor,
                                unreadSOSCount: _unreadSOSCount,
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

class VisitorItem {
  final String id;
  final String name;
  final String phonenumber;
  final String identitycard;
  final String carplate;
  final String date;
  final String time;
  final String enddate;
  final String endtime;
  final String type;
  final String purpose;
  final String unit;

  VisitorItem({
    required this.id,
    required this.name,
    required this.phonenumber,
    required this.identitycard,
    required this.carplate,
    required this.date,
    required this.time,
    required this.enddate,
    required this.endtime,
    required this.type,
    required this.purpose,
    required this.unit,
  });
}

class VisitorCard extends StatelessWidget {
  final VisitorItem visitor;
  final VoidCallback onTap;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Card(
        color: const Color.fromRGBO(171, 193, 207, 1),
        child: Padding(
          padding:  EdgeInsets.all(8.w),
          child: ListTile(
            onTap: onTap,
            title: AutoSizeText(
              'Name: ${visitor.name}',
              textScaleFactor: 1.1.sp,
              style: GoogleFonts.literata(
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontSize: 12.sp
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Car Plate: ${visitor.carplate}',
                  textScaleFactor: 1.1.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 12.sp
                  ),
                ),
                AutoSizeText(
                  'Type: ${visitor.type}',
                  textScaleFactor: 1.1.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 12.sp
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

class VisitorDetailsScreen extends StatefulWidget {
  final VisitorItem visitor;
  final int unreadSOSCount;

  const VisitorDetailsScreen({super.key, required this.visitor, required this.unreadSOSCount});

  @override
  _VisitorDetailsScreenState createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  int _page = 0;

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
          'Visitor Details',
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
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: CurvedNavigationBar(
          index: 2,
          height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
          items: <Widget>[
            Icon(Icons.home_filled, size: 30.r),
            Icon(Icons.qr_code_scanner, size: 30.r),
            Icon(FontAwesomeIcons.idBadge, size: 30.r),
            Stack(
              children: [
                Icon(Icons.contact_phone, size: 30.r),
                if (widget.unreadSOSCount > 0)
                  Positioned(
                    top:-3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadSOSCount}',
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
        color: const Color.fromRGBO(244, 244, 244, 1),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDetailContainer('NAME', widget.visitor.name),
            const SizedBox(height: 8),
            _buildDetailContainer('PHONE NUMBER:', widget.visitor.phonenumber),
            const SizedBox(height: 8),
            if (widget.visitor.type == 'contractor')
              _buildDetailContainer('PURPOSE', widget.visitor.purpose),
            if (widget.visitor.type == 'visitor') ...[
              _buildDetailContainer('IDENTITY CARD:', widget.visitor.identitycard),
              const SizedBox(height: 8),
              _buildDetailContainer('UNIT:', widget.visitor.unit),
            ],
            const SizedBox(height: 8),
            _buildDetailContainer(
              'CAR PLATE',
              widget.visitor.carplate,
            ),
            const SizedBox(height: 8),
            _buildDetailContainer(
              'ARRIVAL DATETIME',
              "${widget.visitor.date} ${widget.visitor.time}",
            ),
            const SizedBox(height: 8),
            _buildDetailContainer(
              'LEAVE DATETIME',
              "${widget.visitor.enddate} ${widget.visitor.endtime}",
            ),
            const SizedBox(height: 8),
            _buildDetailContainer('TYPE', widget.visitor.type),
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
}
