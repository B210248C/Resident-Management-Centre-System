import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/startRMS.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'loginPage.dart';
import 'package:dcdg/dcdg.dart';

class RoleChoose extends StatelessWidget {
  static String id = 'roleChoose_screen';

  const RoleChoose({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 640 ), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: roleChoose(),
        );
      },
    );
  }
}

class roleChoose extends StatelessWidget {
  const roleChoose({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: ((didpop) {
            if(!didpop) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoleChoose()),
              );
            }
          }),
          child: Scaffold(
            body: Container(
              width: 360.w,
              height: 640.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.717, -0.494),
                  end: Alignment(-0.219, 0.3),
                  colors: [
                    Color.fromRGBO(160, 172, 189, 1),
                    Color.fromRGBO(60, 72, 86, 1),
                  ],
                  stops: <double>[0.165, 1],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    // right: 0,
                    top: 0,
                    // bottom: 0,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 360.w,
                        height: 640.h,
                        // clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: AssetImage(
                              'images/starsky.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    top: 10.h,
                    child: SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey[100],
                          size: 30.r,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const StartRMS())
                          );
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        SizedBox(
                          // color: Colors.black,
                          width: 212.w,
                          height: 180.h,
                          // color: Colors.black,
                          child: Image.asset(
                            'images/Logosr1.png',
                          ),
                        ),
                        SizedBox(
                          height: 70.h,
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
                              foregroundColor: const Color.fromRGBO(35, 73, 108, 1),
                              backgroundColor: const Color.fromRGBO(230, 244, 241, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(100.r),
                              ),
                              shadowColor: Colors.black, // Remove default shadow
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const loginPage(role: 'resident'),
                                ),
                              );

                            },
                            child: AutoSizeText(
                              'RESIDENT',
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
                              foregroundColor: const Color.fromRGBO(35, 73, 108, 1),
                              backgroundColor: const Color.fromRGBO(230, 244, 241, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(100.r),
                              ),
                              shadowColor: Colors.black, // Remove default shadow
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const loginPage(role: 'admin'),
                                ),
                              );

                            },
                            child: AutoSizeText(
                              'ADMIN',
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
                              foregroundColor: const Color.fromRGBO(35, 73, 108, 1),
                              backgroundColor: const Color.fromRGBO(230, 244, 241, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(100.r), // Border radius
                                // side: BorderSide(
                                //   color: Colors.black, // Stroke color
                                //   width: 5, // Stroke width
                                // ),
                              ),
                              shadowColor: Colors.black, // Remove default shadow
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const loginPage(role: 'security'),
                                ),
                              );

                            },
                            child: AutoSizeText(
                              'SECURITY',
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
                        //---------------------------------------------
                        // buildElevatedButton('RESIDENT', context),
                        // SizedBox(height: 35),
                        // buildElevatedButton('ADMIN', context),
                        // SizedBox(height: 35),
                        // buildElevatedButton('SECURITY', context),
                        //------------------------------------------------
                      ],
                    ),
                  ),
                  // Center(
                  //   child: Container(
                  //     color: Colors.green,
                  //     width: 100,
                  //     height: 100,
                  //   ),
                  // ),
                  //Image.asset('images/Logosr1.png'),
                  // Container(
                  //   padding: EdgeInsets.fromLTRB(0, 52, 0, 81),
                  //   child:
                  // Column(
                  //   children: [
                  //     Container(
                  //       color: Colors.black,
                  //       // margin: EdgeInsets.fromLTRB(0, 0, 0, 75),
                  //       child: Image.asset('images/Logosr1.png'),
                  //       // width: 221,
                  //       // height: 360,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

//---------------------------------------------------------------------------
// Utility function to build elevated buttons
Widget buildElevatedButton(String text, BuildContext context) {
  return Container(
    width: 180,
    height: 55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40), // Border radius
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
        foregroundColor: const Color.fromRGBO(35, 73, 108, 1),
        backgroundColor: const Color.fromRGBO(230, 244, 241, 1),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // Border radius
        ),
        shadowColor: Colors.black, // Remove default shadow
      ),
      onPressed: () {
        // Button action
      },
      child: Text(
        text,
        style: GoogleFonts.literata(
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600, // Semibold
          ),
        ),
      ),
    ),
  );
}