import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/registerResident.dart';
import 'package:test1001/registerSecurityAdmin.dart';
import 'package:test1001/startRMS.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';
import 'constructorRegister.dart';

class RoleChooseRegister  extends StatelessWidget {
  static String id = 'RoleChooseRegister_screen';

  const RoleChooseRegister({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 640), // Example design size, adjust as needed
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: roleChooseRegister (),
        );
      },
    );
  }
}

class roleChooseRegister extends StatefulWidget {
  const roleChooseRegister({super.key});

  @override
  State<roleChooseRegister> createState() => _roleChooseRegisterState();
}

class _roleChooseRegisterState extends State<roleChooseRegister> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                top: 0,
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: 360.w,
                    height: 640.h,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StartRMS()),
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 212.w,
                      height: 180.h,
                      child: Image.asset(
                        'images/Logosr1.png',
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Container(
                      width: 190.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.r),
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
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          shadowColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterResident(role: 'resident'),
                            ),
                          );
                        },
                        child: AutoSizeText(
                          'RESIDENT',
                          textScaleFactor: 1.5.sp,
                          style: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: 190.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60.r),
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
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          shadowColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterSecurityAdmin(role: 'admin'),
                            ),
                          );
                        },
                        child: AutoSizeText(
                          'ADMIN',
                          textScaleFactor: 1.5.sp,
                          style: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: 190.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60.r),
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
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          shadowColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterSecurityAdmin(role: 'security'),
                            ),
                          );
                        },
                        child: AutoSizeText(
                          'SECURITY',
                          textScaleFactor: 1.5.sp,
                          style: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: 190.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60.r),
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
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          shadowColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const ContractorRegister(),
                            ),
                          );
                        },
                        child: AutoSizeText(
                          'CONTRACTOR',
                          textScaleFactor: 1.5.sp,
                          style: GoogleFonts.literata(
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
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
    );
  }
}


