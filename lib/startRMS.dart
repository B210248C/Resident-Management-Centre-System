import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/roleChooseRegister.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'roleChoose.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dcdg/dcdg.dart';

class StartRMS extends StatelessWidget {
  static String id = 'startRMS_screen';

  const StartRMS({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 640), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: startRMS(),
        );
      },
    );
  }
}

class startRMS extends StatelessWidget {
  const startRMS({super.key});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            width: 360.w,
            height: 640.h,
            decoration: const BoxDecoration(
              color: Color(0xFFE0FFF8),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  // right: 0,
                  top: 0,
                  // bottom: 0,
                  child: Opacity(
                    opacity: 0.5,
                    child: Container(
                      width: 360.w,
                      height: 640.h,
                      // clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: AssetImage(
                            'images/Bush3.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // //mainAxisAlignment: MainAxisAlignment.center,
                    // // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        // color: Colors.black,
                        width: 212.w,
                        height: 180.h,
                        // color: Colors.black,
                        child: Image.asset('images/Logosr1.png',),
                      ),
                      SizedBox(
                        height: 90.h,
                      ),
                      Container(
                        width: 180.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(40.r), // Border radius
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
                            foregroundColor: const Color(0xFF23496C),
                            backgroundColor: const Color(0xFF48A69D),
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(100.r),
                            ),
                            shadowColor:
                                Colors.black, // Remove default shadow
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleChoose())
                            );
                          },
                          child: AutoSizeText(
                            'LOGIN',
                            textScaleFactor: 1.5.sp,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600, // Semibold
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 180.w,
                        height: 55.h,
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
                            foregroundColor: const Color(0xFF23496C),
                            backgroundColor: const Color(0xFF48A69D),
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(100.r),
                            ),
                            shadowColor:
                            Colors.black, // Remove default shadow
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleChooseRegister())
                            );
                          },
                          child: AutoSizeText(
                            'REGISTER',
                            textScaleFactor: 1.5.sp,
                            style: GoogleFonts.literata(
                              textStyle: TextStyle(
                                overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
