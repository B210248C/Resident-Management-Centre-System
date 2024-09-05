import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/startRMS.dart';
import 'component/appscreen_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';

class SuccessAdminGuard extends StatelessWidget {
  static String id = 'SuccessAdminGuard_screen';

  const SuccessAdminGuard({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: successPageAG(),
        );
      },
    );
  }
}

class successPageAG extends StatelessWidget {
  const successPageAG({super.key});
  @override
  Widget build(BuildContext context) {
    // // Get screen size
    double screenWidth = AppConstant.screenWidth(context);
    double screenHeight = AppConstant.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, -0.8),
                end: Alignment(-0, 0.5),
                colors: [
                  Color.fromRGBO(60, 72, 86, 1),
                  Color.fromRGBO(192, 93, 132, 1),
                ],
                stops: <double>[0.2, 1],
              ),
            ),
            child: Stack(
              children: [
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StartRMS()));
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 360.w,
                    height: 160.h,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage(
                          'images/galaxy1.png',
                        ),
                        // repeat: ImageRepeat.repeatX,
                      ),
                    ),
                    // child: Container(
                    //   width: 360,
                    //   height: 800,
                    // ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180.w,
                        height: 180.h,
                        child: Image.asset(
                          'images/checkIcon.png',
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 300.w,
                          minHeight: 30.h,
                          maxWidth: 300.w,
                          maxHeight: 60.h,
                        ),
                        child: Text(
                          'Successful registered!',
                          textWidthBasis: TextWidthBasis.parent,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: GoogleFonts.literata(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600, // Semibold
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
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
