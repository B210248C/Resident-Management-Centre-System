import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/visitorRegister.dart';
import 'SOSpage.dart';
import 'announcementResident.dart';
import 'component/appscreen_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';
import 'feedbackResident.dart';
import 'package:badges/badges.dart' as badges;

class UtilityPage extends StatelessWidget {
  static String id = 'UtilityPage_screen';

  const UtilityPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: utilityPage(),
        );
      },
    );
  }
}

class utilityPage extends StatefulWidget {
  const utilityPage({super.key});

  @override
  State<utilityPage> createState() => _utilityPageState();
}

class _utilityPageState extends State<utilityPage> {
  int _page = 0;
  bool _isFetching = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _unreadNotificationsCount = 0;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationsCount();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchUnreadNotificationsCount();
    });
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true; // Only show loading indicator initially
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('announcement').get();

        int count = querySnapshot.docs.where((doc) {
          String type = doc['type'];
          bool isRead = doc['isRead'];
          if (type == 'announcement' && !isRead) {
            return true;
          } else if (type == 'parcel' &&
              doc['email'] == currentUser.email &&
              !isRead) {
            return true;
          }
          return false;
        }).length;

        setState(() {
          _unreadNotificationsCount = count;
        });
      }
    } catch (e) {
      print("Error fetching number of announcement: $e");
    } finally {
      setState(() {
        _isFetching = false;
        print("Finished fetching number of announcement");
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
        backgroundColor: const Color.fromRGBO(216, 232, 186, 1),
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
            'Utility',
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
                      top: -3,
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
        body: StatementScreen(),
      ),
    );
  }
}

class StatementScreen extends StatefulWidget {
  @override
  _StatementScreenState createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  bool isPaid = false;

  final List<Map<String, dynamic>> transactions = [
    {
      'releasedDate': '2024-05-30',
      'amount': 'RM 11.25',
      'docNo': '10162000',
      'dueDate': '2024-06-13',
      'paidDate': '2024-06-12',
    },
    {
      'releasedDate': '2024-05-15',
      'amount': 'RM 12.75',
      'docNo': '10163193',
      'dueDate': '2024-05-29',
      'paidDate': '2024-05-28',
    },
    {
      'releasedDate': '2024-04-30',
      'amount': 'RM 10.50',
      'docNo': '10164561',
      'dueDate': '2024-05-14',
      'paidDate': '2024-05-13',
    },
    {
      'releasedDate': '2024-04-15',
      'amount': 'RM 10.50',
      'docNo': '10167795',
      'dueDate': '2024-04-29',
      'paidDate': '2024-04-28',
    },
    {
      'releasedDate': '2024-03-31',
      'amount': 'RM 9.50',
      'docNo': '10167800',
      'dueDate': '2024-04-14',
      'paidDate': '2024-04-13',
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateTransactions();
  }

  void _generateTransactions() {
    DateTime lastDueDate = DateTime.parse(transactions.first['dueDate']);
    DateTime today = DateTime.now();
    DateTime currentReleasedDate = lastDueDate.add(Duration(days: 1));
    DateTime currentDueDate = currentReleasedDate.add(Duration(days: 14));

    while (currentDueDate.isBefore(today) ||
        currentDueDate.isAtSameMomentAs(today)) {
      transactions.insert(0, {
        'releasedDate': DateFormat('yyyy-MM-dd').format(currentReleasedDate),
        'amount': 'RM 10.50',
        'docNo': 'GeneratedDocNo${transactions.length + 1}',
        'dueDate': DateFormat('yyyy-MM-dd').format(currentDueDate),
        'paidDate': DateFormat('yyyy-MM-dd')
            .format(currentDueDate), // Assuming payment is done on due date
      });

      currentReleasedDate = currentDueDate.add(Duration(days: 1));
      currentDueDate = currentReleasedDate.add(Duration(days: 14));
    }

    setState(() {});
  }

  void _makePayment() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => PaymentDialog(),
    );

    if (result == true) {
      setState(() {
        isPaid = true;

        // Find the due date of the last transaction
        DateTime lastDueDate = DateTime.parse(transactions.first['dueDate']);

        // Set new released date to the next day after the last due date
        DateTime newReleasedDate = lastDueDate.add(Duration(days: 1));

        // Set new due date to two weeks after the new released date
        DateTime newDueDate = newReleasedDate.add(Duration(days: 14));

        // Set paid date to today
        DateTime paidDate = DateTime.now();

        transactions.insert(0, {
          'releasedDate': DateFormat('yyyy-MM-dd').format(newReleasedDate),
          'amount': 'RM 10.50',
          'docNo': '${10162000 + transactions.length + 1}',
          'dueDate': DateFormat('yyyy-MM-dd').format(newDueDate),
          'paidDate': DateFormat('yyyy-MM-dd').format(paidDate),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successful payment'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: MediaQuery.of(context).padding.bottom +
              kBottomNavigationBarHeight.h -
              45.h),
      child: Column(
        children: [
          TotalDueSection(
            isPaid: isPaid,
            onPayPressed: _makePayment,
            transactions: transactions,
          ),
          SizedBox(height: 5.h),
          Divider(
            color: Colors.grey,
          ),
          Expanded(
              child:
                  TransactionsList(showAll: false, transactions: transactions)),
          SizedBox(height: 8.h),
          Divider(
            color: Colors.grey,
          ),
          ViewAllTransactionsButton(transactions: transactions),
        ],
      ),
    );
  }
}

class TotalDueSection extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onPayPressed;
  final List<Map<String, dynamic>> transactions;

  TotalDueSection(
      {required this.isPaid,
      required this.onPayPressed,
      required this.transactions});

  @override
  Widget build(BuildContext context) {
    final DateTime newestDueDate = transactions
        .map((transaction) => DateTime.parse(transaction['dueDate']))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final DateTime dueDatePlus15Days = newestDueDate.add(Duration(days: 15));
    final String formattedDueDatePlus15Days =
        DateFormat('yMMMMd').format(dueDatePlus15Days);

    return Container(
      constraints: BoxConstraints(minWidth: 360.w),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPaid) ...[
            AutoSizeText(
              'Total Due',
              textScaleFactor: 1.4.sp,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: GoogleFonts.literata(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp
                    ),
              ),
            ),
            SizedBox(height: 4),
            AutoSizeText(
              'As of $formattedDueDatePlus15Days',
              textScaleFactor: 1.4.sp,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: GoogleFonts.literata(
                textStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText(
                  'RM 10.50',
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,// Semibold
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onPayPressed,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.blue),
                  ),
                  child: AutoSizeText(
                    'Pay Now',
                    textScaleFactor: 1.4.sp,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.literata(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,// Semibold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            AutoSizeText(
              'No transaction',
              textScaleFactor: 1.4.sp,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: GoogleFonts.literata(
                textStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.sp,// Semibold
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  final bool showAll;
  final List<Map<String, dynamic>> transactions;

  TransactionsList({required this.showAll, required this.transactions});

  List<Map<String, dynamic>> get displayedTransactions {
    final sortedTransactions = List<Map<String, dynamic>>.from(transactions);
    sortedTransactions.sort((a, b) => DateTime.parse(b['releasedDate'])
        .compareTo(DateTime.parse(a['releasedDate'])));
    if (showAll) {
      return sortedTransactions;
    } else {
      return sortedTransactions.take(3).toList();
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByMonth() {
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    for (var transaction in displayedTransactions) {
      final date = DateTime.parse(transaction['releasedDate']);
      final month = DateFormat.yMMMM().format(date);

      if (!groupedTransactions.containsKey(month)) {
        groupedTransactions[month] = [];
      }
      groupedTransactions[month]!.add(transaction);
    }

    return groupedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupTransactionsByMonth();
    return ListView.builder(
      itemCount: groupedTransactions.keys.length,
      itemBuilder: (context, index) {
        final month = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              month,
              textScaleFactor: 1.4.sp,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: GoogleFonts.literata(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,// Semibold
                ),
              ),
            ),
            Column(
              children: transactions.map((transaction) {
                return TransactionItem(
                  transaction: transaction,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionItem({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final formattedReleasedDate =
        DateFormat.yMd().format(DateTime.parse(transaction['releasedDate']));
    final formattedDueDate =
        DateFormat.yMd().format(DateTime.parse(transaction['dueDate']));
    final formattedPaidDate =
        DateFormat.yMd().format(DateTime.parse(transaction['paidDate']));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                formattedReleasedDate,
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,// Semibold
                  ),
                ),
              ),
              AutoSizeText(
                '${transaction['amount']}',
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,// Semibold
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.vertical,
            children: [
              AutoSizeText(
                'Doc No: ${transaction['docNo']}',
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,// Semibold
                  ),
                ),
              ),
              AutoSizeText(
                'Due Date: ${formattedDueDate}',
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,// Semibold
                  ),
                ),
              ),
              // Text(formattedPaidDate, style: TextStyle(color: Colors.green)),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionDetailScreen(transaction: transaction),
                  ),
                );
              },
              child: AutoSizeText(
                'View Invoice',
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,// Semibold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewAllTransactionsButton extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  ViewAllTransactionsButton({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(Color.fromRGBO(88, 129, 87, 1)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AllTransactionsScreen(transactions: transactions),
          ),
        );
      },
      child: AutoSizeText(
        'View All Transactions',
        textScaleFactor: 1.4.sp,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: GoogleFonts.literata(
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize:16.sp,// Semibold
          ),
        ),
      ),
    );
  }
}

class AllTransactionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  AllTransactionsScreen({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(216, 232, 186, 1),
        appBar: AppBar(
          title: AutoSizeText(
            'All Transactions',
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: const Color.fromRGBO(35, 73, 108, 1),
                fontSize: 16.sp,
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransactionsList(showAll: true, transactions: transactions),
        ),
      ),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AutoSizeText(
        'Select Payment Method',
        textAlign: TextAlign.center,
        textScaleFactor: 1.4.sp,
        overflow: TextOverflow.visible,
        softWrap: true,
        style: GoogleFonts.literata(
          textStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 22.sp,// Semibold
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreditCardFormDialog();
                },
              );
            },
            child: Container(
              constraints: BoxConstraints(
                minWidth: 250.w,
              ),
              child: AutoSizeText(
                'Pay with Credit Card',
                textAlign: TextAlign.center,
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,// Semibold
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            constraints: BoxConstraints(
              minWidth: 250.w,
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FPXPaymentDialog();
                  },
                );
              },
              child: AutoSizeText(
                'Pay with FPX',
                textAlign: TextAlign.center,
                textScaleFactor: 1.4.sp,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: GoogleFonts.literata(
                  textStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp// Semibold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // Cancel payment
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

class FPXPaymentDialog extends StatefulWidget {
  @override
  _FPXPaymentDialogState createState() => _FPXPaymentDialogState();
}

class _FPXPaymentDialogState extends State<FPXPaymentDialog> {
  String? selectedBank;
  bool agreeToTerms = false;

  final List<String> banks = [
    'Maybank2u',
    'CIMB Clicks',
    'RHB Now',
    'PBe',
    'HLB Connect',
    'affinOnline',
    'AGRONet',
    'allianceonline',
    'AmOnline',
    'Bank Islam Internet Banking',
    'i-Muamalat',
    'i-Rakyat',
    'myBSN',
    'HSBC Online Banking',
    'KFH Online',
    'OCBC Online Banking',
    'SC Online Banking',
    'UOB Internet Banking'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AutoSizeText(
        'Select Bank',
        textAlign: TextAlign.center,
        textScaleFactor: 1.4.sp,
        overflow: TextOverflow.visible,
        softWrap: true,
        style: GoogleFonts.literata(
          textStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 22.sp// Semibold
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: DropdownButton<String>(
                value: selectedBank,
                isExpanded: true,
                hint: AutoSizeText(
                  'Select Bank',
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp// Semibold
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBank = newValue;
                  });
                },
                items: banks.map<DropdownMenuItem<String>>((String bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: AutoSizeText(
                      bank,
                      textScaleFactor: 1.4.sp,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      style: GoogleFonts.literata(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,// Semibold
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreeToTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: AutoSizeText(
                      'I understand and accept the terms and conditions.',
                      textAlign: TextAlign.start,
                      textScaleFactor: 1.02.sp,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      style: GoogleFonts.literata(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 5.sp// Semibold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cancel payment
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (selectedBank == null || !agreeToTerms)
              ? null
              : () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // Simulate successful payment
                },
          child: Text('Pay'),
        ),
      ],
    );
  }
}

class CreditCardFormDialog extends StatefulWidget {
  @override
  _CreditCardFormDialogState createState() => _CreditCardFormDialogState();
}

class _CreditCardFormDialogState extends State<CreditCardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AutoSizeText(
        'Enter Credit Card Information',
        textAlign: TextAlign.center,
        textScaleFactor: 1.4.sp,
        overflow: TextOverflow.visible,
        softWrap: true,
        style: GoogleFonts.literata(
          textStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20.sp// Semibold
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "This field is required"),
                    PatternValidator(r'^[0-9]{16}$',
                        errorText: "Enter a valid 16-digit card number"),
                  ]),
                ),
                TextFormField(
                  controller: _expiryDateController,
                  decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                  keyboardType: TextInputType.datetime,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "This field is required"),
                    PatternValidator(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$',
                        errorText: "Enter a valid expiry date"),
                  ]),
                ),
                TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "This field is required"),
                    PatternValidator(r'^[0-9]{3}$',
                        errorText: "Enter a valid 3-digit CVV"),
                  ]),
                ),
                TextFormField(
                  controller: _cardHolderNameController,
                  decoration: InputDecoration(labelText: 'Card Holder Name'),
                  validator:
                      RequiredValidator(errorText: "This field is required"),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              Navigator.pop(context,
                  true); // Pop twice to return to the main context with success
            }
          },
          child: Text('Pay'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }
}

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionDetailScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formattedReleasedDate =
        DateFormat.yMd().format(DateTime.parse(transaction['releasedDate']));
    final formattedDueDate =
        DateFormat.yMd().format(DateTime.parse(transaction['dueDate']));
    final formattedPaidDate = transaction['paidDate'] != null
        ? DateFormat.yMd().format(DateTime.parse(transaction['paidDate']))
        : 'Not Paid';

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(216, 232, 186, 1),
        appBar: AppBar(
          title: AutoSizeText(
            'Transaction Details',
            textScaleFactor: 1.2.sp,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: const Color.fromRGBO(35, 73, 108, 1),
                fontSize: 16.sp,
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 400.h,
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AutoSizeText(
                  'Released Date: $formattedReleasedDate',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp// Semibold
                    ),
                  ),
                ),
                SizedBox(height: 8),
                AutoSizeText(
                  'Document Number: ${transaction['docNo']}',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp// Semibold
                    ),
                  ),
                ),
                SizedBox(height: 8),
                AutoSizeText(
                  'Amount: ${transaction['amount']}',
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp// Semibold
                    ),
                  ),
                ),
                SizedBox(height: 8),
                AutoSizeText(
                  'Due Date: $formattedDueDate',
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp// Semibold
                    ),
                  ),
                ),
                SizedBox(height: 8),
                AutoSizeText(
                  'Paid Date: $formattedPaidDate',
                  textScaleFactor: 1.4.sp,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.literata(
                    textStyle: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                        fontSize: 18.sp// Semibold
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
