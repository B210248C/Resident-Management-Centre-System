import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/registerResident.dart';
import 'package:test1001/registerSecurityAdmin.dart';
import 'package:test1001/residentHome.dart';
import 'package:test1001/roleChoose.dart';
import 'package:test1001/securityHome.dart';
import 'adminHome.dart';
import 'component/star_widget.dart';
import 'component/appscreen_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dcdg/dcdg.dart';

class LoginPage extends StatelessWidget {
  static String id = 'loginPage_screen';
  final String role;

  const LoginPage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize:
            const Size(360, 800), // Example design size, adjust as needed
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: loginPage(role: role),
            ),
          );
        });
  }
}

class loginPage extends StatefulWidget {
  static String id = 'loginPage_screen';
  final String role;

  const loginPage({Key? key, required this.role}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = true;

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('rolescollection')
              .doc(user.uid)
              .get();
          String dbRole = userDoc['role'];

          if (dbRole != widget.role) {
            Navigator.of(context, rootNavigator: true).pop();
            _showSnackbar('Role does not match');
            return;
          }

          if (dbRole == widget.role) {
            if (widget.role == 'resident') {
              bool statusAccount = userDoc['accountstate'];
              if (statusAccount) {
                _showSnackbar('Login successful');
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResidentHome()),
                );
              } else {
                _showSnackbar('Account is not active');
              }
            } else if (widget.role == 'security') {
              _showSnackbar('Login successful');
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityHome()),
              );
            } else if (widget.role == 'admin') {
              _showSnackbar('Login successful');
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminHome()),
              );
            }
          }

        } else {
          Navigator.of(context, rootNavigator: true).pop();
          _showSnackbar('Invalid email or password.');
        }
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        _showSnackbar('An error occurred: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                StarWidget(
                    left: 100.w, top: 50.h, width: 25.w, height: 25.h),
                StarWidget(
                    left: 55.w, top: 130.h, width: 20.w, height: 20.h),
                StarWidget(
                    left: 20.w, top: 200.h, width: 10.w, height: 10.h),
                StarWidget(
                    left: 170.w, top: 70.h, width: 10.w, height: 10.h),
                StarWidget(
                    left: 250.w, top: 30.h, width: 15.w, height: 15.h),
                StarWidget(
                    right: 40.w, top: 130.h, width: 25.w, height: 25.h),
                StarWidget(
                    right: 30.w, top: 250.h, width: 10.w, height: 10.h),
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
                                builder: (context) =>
                                const RoleChoose()));
                      },
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 360.w,
                      height: 445.h,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 1,
                            spreadRadius: 0,
                            offset: Offset(0, -3),
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 1,
                            spreadRadius: 0,
                            offset: Offset(5, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                        color: const Color.fromRGBO(160, 172, 189, 1),
                      ),
                      child: Stack(children: [
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
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Center(
                            child: Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 60.h,
                                    ),
                                    AutoSizeText(
                                      'LOGIN',
                                      textScaleFactor: 1.2.sp,
                                      style: GoogleFonts.mateSc(
                                        textStyle: TextStyle(
                                          decoration:
                                          TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontSize: 25.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: 2.0.w,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 4.0,
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.25),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.email,
                                            color: Colors.grey[800],
                                            size: 30.r,
                                          ),
                                        ),
                                        labelText: 'EMAIL',
                                        hintText: 'Email',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border:
                                        const OutlineInputBorder(),
                                        focusedBorder:
                                        const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder:
                                        const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            vertical: 10.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Enter correct email';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: _isObscured,
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.password_rounded,
                                            color: Colors.grey[800],
                                            size: 30.r,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscured
                                                ? Icons
                                                .remove_red_eye_rounded
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: _toggleVisibility,
                                        ),
                                        labelText: 'PASSWORD',
                                        hintText: 'Password',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border:
                                        const OutlineInputBorder(),
                                        focusedBorder:
                                        const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder:
                                        const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            vertical: 10.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Enter correct password';
                                        }
                                        return null;
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            String role = widget.role;
                                            if (role == 'resident') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RegisterResident(
                                                            role: role,
                                                          )));
                                            } else if (role ==
                                                'security' ||
                                                role == 'admin') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RegisterSecurityAdmin(
                                                              role:
                                                              role)));
                                            }
                                          },
                                          child: AutoSizeText(
                                            'Sign Up',
                                            textScaleFactor: 1.3.sp,
                                            style: GoogleFonts.literata(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight:
                                                FontWeight.w600,
                                                decoration: TextDecoration
                                                    .underline,
                                                decorationColor:
                                                Colors.white,
                                                decorationThickness: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                    Container(
                                      width: 180.w,
                                      height: 45.h,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(40.r),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                0, 0, 0, 0.19),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                0, 0, 0, 0.23),
                                            blurRadius: 6,
                                            spreadRadius: 0,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor:
                                          const Color.fromRGBO(
                                              35, 73, 108, 1),
                                          backgroundColor:
                                          const Color.fromRGBO(
                                              230, 244, 241, 1),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                100.r),
                                          ),
                                          shadowColor: Colors.black,
                                        ),
                                        onPressed: _login,
                                        child: AutoSizeText(
                                          'LOGIN',
                                          textScaleFactor: 1.2.sp,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                            ),
                          ),
                        ),
                      ]),
                    )),
                Positioned(
                  left: 75.w,
                  top: 60.h,
                  child: SizedBox(
                    width: 212.w,
                    height: 230.h,
                    child: Image.asset(
                      'images/Logosr1.png',
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
