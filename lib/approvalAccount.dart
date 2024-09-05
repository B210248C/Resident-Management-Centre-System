import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:test1001/adminHome.dart';
import 'package:test1001/parcelManagement.dart';
import 'package:test1001/reportDetails.dart';
import 'package:test1001/startRMS.dart';
import 'feedbackDetails.dart';
import 'makeAnnouncement.dart';
import 'package:dcdg/dcdg.dart';

class AccountApproval extends StatelessWidget {
  static String id = 'AccountApproval_screen';

  const AccountApproval({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800),
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AccountApprovalScreen(),
        );
      },
    );
  }
}

class AccountApprovalScreen extends StatefulWidget {
  const AccountApprovalScreen({super.key});

  @override
  _AccountApprovalScreenState createState() => _AccountApprovalScreenState();
}

class _AccountApprovalScreenState extends State<AccountApprovalScreen> {
  List<AccountItem> account = [];
  MessageType selectedMessageType = MessageType.newest;
  int _page = 0;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isFetchingR = false;
  bool _isFetchingF = false;
  int _unreadAccountCount = 0;
  int _unreadReportCount = 0;
  int _unreadFeedbackCount = 0;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
    _fetchUnreadAccountCount();
    _fetchUnreadReportCount();
    _fetchUnreadFeedbackCount();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      counter = 1;
      fetchAccounts();
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

  Future<void> fetchAccounts() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
      if (account.isEmpty && counter == 0) {
        _isLoading = true;
      } else {
        _isLoading = false;
      }
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rolescollection')
          .where('role', isEqualTo: 'resident')
          .get();

      List<AccountItem> fetchedAccounts = querySnapshot.docs.map((doc) {
        return AccountItem(
          id: doc.id, // Add the document ID
          name: doc['username'],
          email: doc['email'],
          phonenumber: doc['phone'],
          gender: doc['gender'],
          address: doc['address'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          isRead: doc['isRead'] ?? false, // Get the isRead status from Firebase
          accountState: doc['accountstate'] ??
              false, // Get the accountState status from Firebase
        );
      }).toList();

      setState(() {
        account = fetchedAccounts;
      });
    } catch (e) {
      print("Error fetching accounts: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isFetching = false;
        print("Finished fetching accounts");
      });
    }
  }

  void removeAccount(AccountItem account) {
    setState(() {
      this.account.remove(account);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<AccountItem> filteredAccount = account;

    // Sort based on selected message type
    if (selectedMessageType == MessageType.newest) {
      filteredAccount.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (selectedMessageType == MessageType.oldest) {
      filteredAccount.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminHome()));
            },
          ),
          title: AutoSizeText(
            'Account Approval',
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
            index: 1,
            height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
            items: <Widget>[
              Icon(Icons.home_filled, size: 30.r),
              Icon(Icons.check_circle, size: 30.r),
              Stack(
                children: [
                  Icon(Icons.feedback, size: 30.r),
                  if (_unreadReportCount > 0)
                    Positioned(
                      top: -3,
                      right: 0,
                      child: badges.Badge(
                        badgeContent: AutoSizeText(
                          '$_unreadReportCount',
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
                  padding: EdgeInsets.only(bottom: 15.h),
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
                            style: GoogleFonts.literata(
                              fontSize: 16.sp,
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
                    ? Center(child: CircularProgressIndicator())
                    : filteredAccount.isEmpty
                        ? Center(
                            child: AutoSizeText(
                              'No account need for approval.',
                              textScaleFactor: 1.1.sp,
                              style: GoogleFonts.literata(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                                      .sp // Change font color for the selected item
                                  ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredAccount.length,
                              itemBuilder: (context, index) {
                                final account = filteredAccount[index];
                                return AccountCard(
                                  account: account,
                                  onTap: () {
                                    setState(() {
                                      account.isRead = true;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccountDetailsScreenDetail(
                                          account: account,
                                          onDecline: (declinedAccount) {
                                            setState(() {
                                              removeAccount(declinedAccount);
                                            });
                                          },
                                          removeAccount: removeAccount,
                                          unreadReportCount: _unreadReportCount,
                                          unreadFeedbackCount:
                                              _unreadFeedbackCount,
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

class AccountItem {
  final String id;
  final String name;
  final String email;
  final String phonenumber;
  final String gender;
  final String address;
  final DateTime timestamp;
  bool isRead;
  bool accountState;

  AccountItem({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.phonenumber,
    required this.address,
    required this.timestamp,
    required this.isRead,
    required this.accountState,
  });
}

class AccountCard extends StatelessWidget {
  final AccountItem account;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTimestamp =
        DateFormat('dd/MM/yyyy HH:mm').format(account.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: account.accountState
            ? Colors.grey
            : const Color.fromRGBO(255, 216, 209, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: account.accountState // Disable tap if account is approved
                ? null
                : () async {
                    await FirebaseFirestore.instance
                        .collection('rolescollection')
                        .doc(account.id)
                        .update({'isRead': true});
                    account.isRead = true; // Update the local state as well
                    onTap();
                  },
            title: AutoSizeText(
              formattedTimestamp,
              textScaleFactor: 1.2.sp,
              style: GoogleFonts.literata(
                fontWeight:
                    account.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 11,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Name: ${account.name}',
                  textScaleFactor: 1.2.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight:
                        account.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                AutoSizeText(
                  'Address: ${account.address}',
                  textScaleFactor: 1.2.sp,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontWeight:
                        account.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
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

class AccountDetailsScreenDetail extends StatefulWidget {
  final AccountItem account;
  final Function(AccountItem) onDecline;
  final Function(AccountItem) removeAccount;
  final int unreadReportCount;
  final int unreadFeedbackCount;

  const AccountDetailsScreenDetail({
    super.key,
    required this.account,
    required this.onDecline,
    required this.removeAccount,
    required this.unreadReportCount,
    required this.unreadFeedbackCount,
  });

  @override
  _AccountDetailsScreenDetailState createState() =>
      _AccountDetailsScreenDetailState();
}

class _AccountDetailsScreenDetailState
    extends State<AccountDetailsScreenDetail> {
  int _page = 0;
  bool showMessageOptions = false;

  void deleteAccount(AccountItem account) async {
    try {
      // Delete the user from Firestore
      await FirebaseFirestore.instance
          .collection('rolescollection')
          .doc(account.id)
          .delete();

      // Delete the user from Firebase Authentication
      User? user = (await FirebaseAuth.instance
                  .fetchSignInMethodsForEmail(account.email))
              .isNotEmpty
          ? FirebaseAuth.instance.currentUser
          : null;
      if (user != null) {
        await user.delete();
      }

      widget.removeAccount(account);

      // Show success message or perform any other actions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      print("Error deleting account: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting account')),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Decline',
            style: GoogleFonts.literata(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to decline this approval?',
            style: GoogleFonts.literata(
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.literata(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.removeAccount(widget.account);
                Navigator.of(context).pop(); // Close the dialog
                deleteAccount(widget.account); // Close the details screen
              },
              child: Text(
                'Yes',
                style: GoogleFonts.literata(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void approveAccount(AccountItem account) async {
    try {
      // Update the account state to true in Firestore
      await FirebaseFirestore.instance
          .collection('rolescollection')
          .doc(account.id)
          .update({'accountstate': true});

      // Retrieve the document to get the phone number
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('rolescollection')
          .doc(account.id)
          .get();

      String residentName = doc["username"];
      String residentEmail = doc["email"];

      final outlookStmp =
          hotmail(dotenv.env['EMAIL_USERNAME']!, dotenv.env['EMAIL_PASSWORD']!);

      final message = Message()
        ..from = Address(dotenv.env['EMAIL_USERNAME']!, 'Smart Resident')
        ..recipients.add(residentEmail)
        ..subject = 'Account Activation'
        ..text = '''
Dear ${residentName},


We would like to inform you that your account has been approved. Feel free to use your account. Have a nice day.


Sincerely,
Tester - Smart Resident Support Bot
''';

      try {
        final sendReport = await send(message, outlookStmp);
        print('Message sent: ${sendReport.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent successfully!')),
        );
      } catch (e) {
        print('Message not sent. $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: $e')),
        );
      }

      // Update the local state
      setState(() {
        account.accountState = true;
      });

      Navigator.pop(context);
      // Show success message or perform any other actions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account approved successfully')),
      );
    } catch (e) {
      print("Error approving account: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error approving account')),
      );
    }
  }

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
          'Account Approval',
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
          index: 1,
          height: 60.0.h > 75.0 ? 75.0 : (60.0.h),
          items: <Widget>[
            Icon(Icons.home_filled, size: 30.r),
            Icon(Icons.check_circle, size: 30.r),
            Stack(
              children: [
                Icon(Icons.feedback, size: 30.r),
                if (widget.unreadReportCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: badges.Badge(
                      badgeContent: AutoSizeText(
                        '${widget.unreadReportCount}',
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
            _buildDetailContainer('NAME', widget.account.name),
            SizedBox(height: 8.h),
            _buildDetailContainer('EMAIL', widget.account.email),
            SizedBox(height: 8.h),
            _buildDetailContainer('PHONE NUMBER', widget.account.phonenumber),
            SizedBox(height: 8.h),
            _buildDetailContainer('GENDER', widget.account.gender),
            SizedBox(height: 8.h),
            _buildDetailContainer('ADDRESS', widget.account.address),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Send Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.r),
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: widget.account.accountState
                        ? null
                        : () {
                            approveAccount(widget.account);
                          },
                    child: AutoSizeText(
                      'APPROVE',
                      textScaleFactor: 1.2.sp,
                      style: GoogleFonts.literata(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Cancel Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.r),
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    child: AutoSizeText(
                      'DECLINE',
                      textScaleFactor: 1.2.sp,
                      style: GoogleFonts.literata(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}
