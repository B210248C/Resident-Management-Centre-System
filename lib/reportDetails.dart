import 'dart:async';
import 'package:dcdg/dcdg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test1001/parcelManagement.dart';
import 'package:test1001/startRMS.dart';
import 'package:video_player/video_player.dart';
import 'package:badges/badges.dart' as badges;
import 'adminHome.dart';
import 'approvalAccount.dart';
import 'feedbackDetails.dart';
import 'makeAnnouncement.dart';

class ReportDetails extends StatelessWidget {
  static String id = 'ReportDetails_screen';

  const ReportDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800),
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ReportDetailsScreen(),
        );
      },
    );
  }
}

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key});

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  List<ReportItem> report = [];
  MessageType selectedMessageType = MessageType.newest;
  int _page = 0;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  int _unreadAccountCount = 0;
  int _unreadReportCount = 0;
  int _unreadFeedbackCount = 0;
  bool _isFetchingR = false;
  bool _isFetchingF = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    fetchReports();
    _fetchUnreadAccountCount();
    _fetchUnreadReportCount();
    _fetchUnreadFeedbackCount();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      counter = 1;
      fetchReports();
      _fetchUnreadAccountCount();
      _fetchUnreadReportCount();
      _fetchUnreadFeedbackCount();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _fetchUnreadAccountCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try {
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
    } catch (e) {
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

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('report')
          .where('isRead', isEqualTo: false)
          .get();

      int countReport = snapshot.docs.length;

      setState(() {
        _unreadReportCount = countReport;
      });
    } catch (e) {
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

    try {
      QuerySnapshot Qsnapshot = await FirebaseFirestore.instance
          .collection('feedbackresident')
          .where('isRead', isEqualTo: false)
          .get();

      int countFeedback = Qsnapshot.docs.length;

      setState(() {
        _unreadFeedbackCount = countFeedback;
      });
    } catch (e) {
      print("Error fetching number of feedback: $e");
    } finally {
      setState(() {
        _isFetchingF = false;
        print("Finished fetching number of feedback");
      });
    }
  }

  void fetchReports() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
      if (report.isEmpty && counter == 0) {
        _isLoading = true;
      } else {
        _isLoading = false;
      }
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('report').get();
      setState(() {
        report = snapshot.docs.map((doc) {
          return ReportItem(
            id: doc.id,
            name: doc['name'],
            email: doc['email'],
            subject: doc['subject'],
            message: doc['message'],
            timestamp: (doc['timestamp'] as Timestamp).toDate(),
            isRead: doc["isRead"] ?? false,
            media: List<String>.from(doc['images']),
          );
        }).toList();
      });
    } catch (error) {
      print("Error fetching reports: $error");
    } finally {
      setState(() {
        _isFetching = false;
        _isLoading = false;
        print("Finished fetching reports");
      });
    }
  }

  void _updateIsReadStatus(String id) {
    FirebaseFirestore.instance
        .collection('report')
        .doc(id)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    List<ReportItem> filteredReport = report;

    // Sort based on selected message type
    if (selectedMessageType == MessageType.newest) {
      filteredReport.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (selectedMessageType == MessageType.oldest) {
      filteredReport.sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminHome()));
            },
          ),
          title: AutoSizeText(
            'Report Details',
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
          data: Theme.of(context)
              .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
          child: CurvedNavigationBar(
            // key: _bottomNavigationKey,
            index: 2,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.check_circle, size: 30.r),
                  if (_unreadAccountCount > 0)
                    Positioned(
                      top: -3,
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
              Icon(Icons.feedback, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.chat, size: 30.r),
                  if (_unreadFeedbackCount > 0)
                    Positioned(
                      top: -3,
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountApproval()));
              }
              if (_page == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportDetails()));
              }
              if (_page == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackDetails()));
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/adminFeed.png'),
              opacity: 0.2,
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: 8.h,
                bottom: MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight.h +
                    5.h),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 2.0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 181, 167, 1),
                    ),
                    child: DropdownButton<MessageType>(
                      value: selectedMessageType,
                      onChanged: (value) {
                        setState(() {
                          selectedMessageType = value!;
                        });
                      },
                      items: MessageType.values
                          .where((type) => type != MessageType.all)
                          .map((type) {
                        return DropdownMenuItem<MessageType>(
                          value: type,
                          child: AutoSizeText(
                            _getMessageTypeText(type),
                            textScaleFactor: 1.2.sp,
                            style: GoogleFonts.literata(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      style: GoogleFonts.literata(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                      dropdownColor: const Color.fromRGBO(255, 181, 167, 1),
                      underline: Container(),
                      iconEnabledColor: Colors.black,
                    ),
                  ),
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : filteredReport.isEmpty
                        ? Center(
                            child: AutoSizeText(
                              'No report available.',
                              textScaleFactor: 1.1.sp,
                              style: GoogleFonts.literata(
                                fontWeight: FontWeight.w500,
                                fontSize: 15
                                    .sp, // Change font color for the selected item
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredReport.length,
                              itemBuilder: (context, index) {
                                final report = filteredReport[index];
                                return Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Color.fromRGBO(255, 212, 201, 1),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: report.isRead
                                            ? Colors.green
                                            : Colors.red,
                                        child: Icon(
                                          report.isRead
                                              ? Icons.mark_email_read
                                              : Icons.mark_email_unread,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: AutoSizeText(
                                        report.subject,
                                        textScaleFactor: 1.12.sp,
                                        style: GoogleFonts.literata(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            report.name,
                                            textScaleFactor: 0.95.sp,
                                            style: GoogleFonts.literata(),
                                          ),
                                          AutoSizeText(
                                            report.email,
                                            textScaleFactor: 0.95.sp,
                                            style: GoogleFonts.literata(),
                                          ),
                                          AutoSizeText(
                                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                                .format(report.timestamp),
                                            textScaleFactor: 0.95.sp,
                                            style: GoogleFonts.literata(),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        _updateIsReadStatus(report.id);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReportDetailsScreenDetail(
                                                      report: report,
                                                      unreadAccountCount:
                                                          _unreadAccountCount,
                                                      unreadFeedbackCount:
                                                          _unreadFeedbackCount,
                                                    )));
                                      },
                                    ),
                                  ),
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

  String _getMessageTypeText(MessageType type) {
    switch (type) {
      case MessageType.newest:
        return 'Newest';
      case MessageType.oldest:
        return 'Oldest';
      default:
        return '';
    }
  }
}

enum MessageType {
  all,
  newest,
  oldest,
}

class ReportItem {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final List<String> media; // List of media file paths/URLs

  ReportItem({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.media, // Initialize in the constructor
  });
}

class ReportDetailsScreenDetail extends StatefulWidget {
  final ReportItem report;
  final int unreadAccountCount;
  final int unreadFeedbackCount;

  const ReportDetailsScreenDetail({
    super.key,
    required this.report,
    required this.unreadAccountCount,
    required this.unreadFeedbackCount,
  });

  @override
  _ReportDetailsScreenDetailState createState() =>
      _ReportDetailsScreenDetailState();
}

class _ReportDetailsScreenDetailState extends State<ReportDetailsScreenDetail> {
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
          'Report Details',
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
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
        child: CurvedNavigationBar(
          // key: _bottomNavigationKey,
          index: 2,
          height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
          items: <Widget>[
            Icon(Icons.home_filled, size: 30.r),
            Stack(
              children: [
                Icon(Icons.check_circle, size: 30.r),
                if (widget.unreadAccountCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadAccountCount}',
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
            Stack(
              children: [
                Icon(Icons.chat, size: 30.r),
                if (widget.unreadFeedbackCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadFeedbackCount}',
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountApproval()));
            }
            if (_page == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportDetails()));
            }
            if (_page == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackDetails()));
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
        color: const Color.fromRGBO(255, 237, 234, 1),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDetailContainer('NAME', widget.report.name),
            SizedBox(height: 8.h),
            _buildDetailContainer('EMAIL', widget.report.email),
            SizedBox(height: 8.h),
            _buildDetailContainer('SUBJECT', widget.report.subject),
            SizedBox(height: 8.h),
            _buildDetailContainer(
              'DATETIME',
              _formatTimestamp(widget.report.timestamp),
            ),
            SizedBox(height: 8.h),
            _buildDetailContainer('MESSAGE', widget.report.message),
            SizedBox(height: 16.h),
            AutoSizeText(
              'MEDIA',
              textScaleFactor: 1.2.sp,
              style: GoogleFonts.literata(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            widget.report.media.isNotEmpty
                ? _buildMediaGrid(widget.report.media)
                : AutoSizeText(
                    'No media files available',
                    style: GoogleFonts.literata(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
            SizedBox(height: 60.h),
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

  Widget _buildMediaGrid(List<String> mediaFiles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(imagePath: mediaFile),
              ),
            );
          },
          child: Container(
            height: 150.h, // Fixed height for each image container
            width: double.infinity, // Full width within the grid cell
            child: Image.network(
              mediaFile,
              fit: BoxFit.cover, // Ensure the image covers the container
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // The image is fully loaded
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Error loading image'));
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.network(imagePath),
        ),
      ),
    );
  }
}
