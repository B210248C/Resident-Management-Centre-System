import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dcdg/dcdg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test1001/visitorDetails.dart';
import 'package:test1001/visitorRegister.dart';

class HistoryPage extends StatefulWidget {
  static String id = 'HistoryPage_screen';
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getVisitorData() async {
    User? user = _auth.currentUser;
    String? userEmail = user?.email;

    if (userEmail != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('visitor')
          .where('user_email', isEqualTo: userEmail)
          .get();

      List<Map<String, dynamic>> visitorData = snapshot.docs.map((doc) {
        return {
          'data': doc.data(),
          'id': doc.id,
        };
      }).toList();

      return visitorData;
    }
    return [];
  }

  void _shareQRCode(String qrData) async {
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

        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        final file = await File('$tempPath/qr_code.png').create();
        final picData =
            await painter.toImageData(2048, format: ImageByteFormat.png);
        await file.writeAsBytes(picData!.buffer.asUint8List());

        Share.shareXFiles([XFile(file.path)], text: 'Here is the QR code');
      }
    } catch (e) {
      print('Error generating or sharing QR code: $e');
    }
  }

  // void _deleteExpiredQRCode() async {
  //   User? user = _auth.currentUser;
  //   String? userEmail = user?.email;
  //
  //   if (userEmail != null) {
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('visitor')
  //         .where('user_email', isEqualTo: userEmail)
  //         .get();
  //
  //     snapshot.docs.forEach((doc) {
  //       DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
  //       if (timestamp.add(Duration(minutes: 1)).isBefore(DateTime.now())) {
  //         _firestore.collection('visitor').doc(doc.id).delete();
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // _deleteExpiredQRCode();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25.r),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VisitorRegister()));
            },
          ),
          title: AutoSizeText(
            'QR Code History',
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
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getVisitorData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No QR codes found"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = snapshot.data![index]['data'] ?? {};
                String qrData = data['qrcode'] ?? 'No QR code is generated';
                Timestamp? timestampField = data['timestamp'];
                DateTime timestamp = timestampField != null
                    ? timestampField.toDate()
                    : DateTime.now();
                String id = snapshot.data![index]['id'];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                  child: Card(
                    color: const Color.fromRGBO(205, 214, 175, 1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: AutoSizeText(
                          "QR Code ${index + 1}",
                          textScaleFactor: 1.3.sp,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.literata(
                            fontWeight: FontWeight.w500,
                            fontSize: 17.sp,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: AutoSizeText(
                          "Created on: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}",
                          textScaleFactor: 1.3.sp,
                          style: GoogleFonts.literata(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.share),
                          onPressed: qrData != 'No QR code is generated'
                              ? () => _shareQRCode(qrData)
                              : null,
                        ),
                        onTap: qrData != 'No QR code is generated'
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          QrImageView(
                                            data: qrData,
                                            version: QrVersions.auto,
                                            size: 200.0,
                                          ),
                                          AutoSizeText(
                                            "The code will be automatically expired after a month.",
                                            textAlign: TextAlign.center,
                                            textScaleFactor: 1.3.sp,
                                            style: GoogleFonts.literata(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
