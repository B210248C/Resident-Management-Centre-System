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
import 'package:test1001/roleChooseRegister.dart';
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

class ContractorRegister extends StatelessWidget {
  static String id = 'ContractorRegister_screen';

  const ContractorRegister({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: contractorRegister(),
        );
      },
    );
  }
}

class contractorRegister extends StatefulWidget {
  const contractorRegister({super.key});

  @override
  State<contractorRegister> createState() => _contractorRegisterState();
}

class _contractorRegisterState extends State<contractorRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController timePicker = TextEditingController();
  final TextEditingController datePicker = TextEditingController();
  final TextEditingController _timePicker = TextEditingController();
  final TextEditingController _datePicker = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  String? _selectedPurpose;
  final TextEditingController _carPlateController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _saveContractorData() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      String qrData =
          '${_namecontroller.text}|${_companyController.text}|${_selectedPurpose}|${_carPlateController.text}|${timePicker.text}|${datePicker.text}';

      // Prepare the data to save
      Map<String, dynamic> visitorData = {
        'name': _namecontroller.text,
        'phone_number': _companyController.text,
        'purpose': _selectedPurpose,
        'car_plate': _carPlateController.text,
        'time': timePicker.text,
        'date': datePicker.text,
        'endtime': _timePicker.text,
        'enddate': _datePicker.text,
        'qrcode': qrData,
        'timestamp': DateTime.now(),
        'type': 'contractor',
      };

      // Save to Firestore
      try {
        // DocumentReference visitorRef =
        await FirebaseFirestore.instance.collection('visitor').add(visitorData);

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        _showQRCodeDialog(qrData);

        _namecontroller.clear();
        _companyController.clear();
        _carPlateController.clear();
        timePicker.clear();
        datePicker.clear();
        _timePicker.clear();
        _datePicker.clear();
        setState(() {
          _selectedPurpose = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contractor registration successful.')));
      } catch (e) {
        // Handle the error
        print("Error saving contractor data: $e");
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
      barrierDismissible: false,
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
                      builder: (context) => const RoleChooseRegister()));
            },
          ),
          title: AutoSizeText(
            'Contractor Registration',
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
        extendBody: true,
        body: Container(
          width: screenWidth,
          height: screenHeight,
          color: Color.fromRGBO(255, 202, 75, 0.7),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 40.h, left: 20.w, right: 20.w, bottom: 30.h),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.r,
                        backgroundImage:
                            const AssetImage('images/constractorImage.png'),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      TextFormField(
                        controller: _companyController,
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
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              FontAwesomeIcons.building,
                              color: Colors.yellow[800],
                              size: 20.r,
                            ),
                          ),
                          hintText: 'Compant Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFFFAA1D), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFFFAA1D), width: 1.0),
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
                          if (value == null || value.isEmpty) {
                            return 'Enter the company name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 15.h,
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
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.yellow[800],
                              size: 20.r,
                            ),
                          ),
                          hintText: 'Worker Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFFFAA1D), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFFFAA1D), width: 1.0),
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
                        height: 15.h,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedPurpose,
                        style: GoogleFonts.literata(
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Icon(
                              FontAwesomeIcons
                                  .toolbox, // Update with a relevant icon
                              color: Colors.yellow[800],
                              size: 20.r,
                            ),
                          ),
                          labelText: 'Purpose',
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFFAA1D), width: 1.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFFAA1D), width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0.h),
                          labelStyle: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5.w,
                            ),
                          ),
                        ),
                        items: <String>[
                          'Plumbing',
                          'Wiring',
                          'Gardening',
                          'Cleaner'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPurpose = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Purpose cannot be empty';
                          }
                          return null;
                        },
                      ),

                      SizedBox(
                        height: 15.h,
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
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              FontAwesomeIcons.car,
                              color: Colors.yellow[800],
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
                                color: Color(0xFFFFAA1D), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFFFAA1D), width: 1.0),
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
                        height: 15.h,
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
                                    color: Colors.yellow[800],
                                    size: 20.r,
                                  ),
                                ),
                                hintText: 'ARRIVAL DATE',
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                contentPadding: EdgeInsets.only(right: 15.w),
                                hintStyle: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.yellow[700],
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
                                      DateFormat('yyyy-MM-dd').format(datetime);

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
                                    color: Colors.yellow[800],
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
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                contentPadding: EdgeInsets.only(right: 15.w),
                                hintStyle: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.yellow[700],
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
                        height: 15.h,
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
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Icon(
                                    Icons.date_range,
                                    color: Colors.yellow[800],
                                    size: 20.r,
                                  ),
                                ),
                                hintText: 'LEAVE DATE',
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                contentPadding: EdgeInsets.only(right: 15.w),
                                hintStyle: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.yellow[700],
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
                                  letterSpacing: 0.8.w,
                                ),
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Icon(
                                    FontAwesomeIcons.clock,
                                    color: Colors.yellow[700],
                                    size: 20.r,
                                  ),
                                ),
                                hintText: 'TIME',
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: BorderSide(
                                      color: Color(0xFFFFAA1D),
                                      width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFAA1D), width: 1.0),
                                ),
                                contentPadding: EdgeInsets.only(right: 15.w),
                                hintStyle: GoogleFonts.literata(
                                  textStyle: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.yellow[700],
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
                                    _timePicker.text = _time.format(context);
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
                            backgroundColor: Colors.yellow[900],
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            shadowColor: Colors.black, // Remove default shadow
                          ),
                          onPressed: _saveContractorData,
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
    );
  }
}
