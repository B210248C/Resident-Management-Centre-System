import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test1001/SOSdetail.dart';
import 'package:test1001/startRMS.dart';
import 'package:test1001/roleChoose.dart';
import 'package:test1001/registerSecurityAdmin.dart';
import 'package:test1001/registerResident.dart';
import 'package:test1001/successfulregistered.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/securityHome.dart';
import 'package:test1001/adminHome.dart';
import 'package:test1001/visitorRegister.dart';
import 'package:test1001/utility.dart';
import 'package:test1001/reportResident.dart';
import 'package:test1001/feedbackResident.dart';
import 'package:test1001/announcementResident.dart';
import 'package:test1001/reportGuard.dart';
import 'package:test1001/scannerSecurity.dart';
import 'package:test1001/visitorDetails.dart';
import 'package:test1001/reportDetails.dart';
import 'package:test1001/makeAnnouncement.dart';
import 'package:test1001/feedbackDetails.dart';
import 'package:test1001/approvalAccount.dart';
import 'package:test1001/parcelManagement.dart';
import 'package:test1001/roleChooseRegister.dart';
import 'package:test1001/SOSpage.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SuccessAdminGuard.dart';
import 'constructorRegister.dart';
import 'historyQRcode.dart';
import 'loginPage.dart';
import 'package:dcdg/dcdg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode('en');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: StartRMS.id,
      routes: {
        StartRMS.id: (context) => const StartRMS(),
        RoleChoose.id: (context) => const RoleChoose(),
        AdminHome.id: (context) => const AdminHome(),
        NotificationApp.id: (context) => const NotificationApp(),
        AccountApproval.id: (context) => const AccountApproval(),
        FeedbackDetails.id: (context) => const FeedbackDetails(),
        FeedbackResident.id: (context) => const FeedbackResident(),
        RoleChoose.id: (context) => const RoleChoose(),
        LoginPage.id: (context) => const LoginPage(role: '',),
        MakeAnnouncement.id: (context) => const MakeAnnouncement(),
        ParcelManagement.id: (context) => const ParcelManagement(),
        RegisterResident.id: (context) => const RegisterResident(role: ''),
        RegisterSecurityAdmin.id: (context) => const RegisterSecurityAdmin(role:''),
        ReportDetails.id: (context) => const ReportDetails(),
        ReportSecurity.id: (context) => const ReportSecurity(),
        ReportResident.id: (context) => const ReportResident(),
        ResidentHome.id: (context) => const ResidentHome(),
        RoleChooseRegister.id: (context) => const RoleChooseRegister(),
        ScannerSecurity.id: (context) => const ScannerSecurity(),
        SecurityHome.id: (context) => const SecurityHome(),
        SuccessPage.id: (context) => const SuccessPage(),
        SuccessAdminGuard.id: (context) => const SuccessAdminGuard(),
        UtilityPage.id: (context) => const UtilityPage(),
        Visitordetails.id: (context) => const Visitordetails(),
        VisitorRegister.id: (context) => const VisitorRegister(),
        SOSpage.id: (context) => const SOSpage(),
        HistoryPage.id: (context) => const HistoryPage(),
        SOSdetails.id: (context) => const SOSdetails(),
        ContractorRegister.id: (context) => const ContractorRegister(),
      },
    );
  }
}

