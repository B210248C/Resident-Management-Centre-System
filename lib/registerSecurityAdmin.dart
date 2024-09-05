import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1001/SuccessAdminGuard.dart';
import 'package:test1001/roleChooseRegister.dart';
import 'package:test1001/successfulregistered.dart';
import 'loginPage.dart';
import 'component/star_widget.dart';
import 'component/appscreen_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dcdg/dcdg.dart';

class RegisterSecurityAdmin extends StatelessWidget {
  static String id = 'RegisterSecurityAdmin_screen';
  final String role;

  const RegisterSecurityAdmin({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RegisterSecurityAdminScreen(role: role),
        );
      },
    );
  }
}

class RegisterSecurityAdminScreen extends StatefulWidget {
  final String role;

  const RegisterSecurityAdminScreen({super.key, required this.role});

  @override
  State<RegisterSecurityAdminScreen> createState() => _RegisterSecurityAdminScreenState();
}

class _RegisterSecurityAdminScreenState extends State<RegisterSecurityAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _invitationTokenController = TextEditingController();
  bool _isObscured = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
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

  // Future<void> _register() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     showLoadingDialog(context);
  //
  //     try {
  //       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //         email: _emailController.text,
  //         password: _passwordController.text,
  //       );
  //       await _firestore.collection('rolescollection').doc(userCredential.user?.uid).set({
  //         'email': _emailController.text,
  //         'role': widget.role,
  //       });
  //
  //       Navigator.of(context, rootNavigator: true).pop();
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessAdminGuard()));
  //     } catch (e) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Registration failed: $e')),
  //       );
  //     }
  //   }
  // }
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      try {
        final token = _invitationTokenController.text.trim();
        final verifyResponse = await http.post(
          Uri.parse('http://192.168.0.13:3000/verify-token'),
          body: jsonEncode({'token': token}),
          headers: {'Content-Type': 'application/json'},
        );

        if (verifyResponse.statusCode != 200) {
          throw Exception('Failed to verify token');
        }

        final verifyData = jsonDecode(verifyResponse.body);
        if (!verifyData['isValid']) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid or expired invitation token')),
          );
          return;
        }

        final tokenRole = verifyData['role'];
        final expectedRole = widget.role; // Set this to the expected role or fetch it from your settings

        if (tokenRole != expectedRole) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token role does not match expected role')),
          );
          return;
        }

        // Proceed with user registration
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user role
        await _firestore.collection('rolescollection').doc(userCredential.user?.uid).set({
          'email': _emailController.text,
          'role': tokenRole,  // Save the role from the token verification
        });

        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));

      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }


  void verifyToken(String token) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.13:3000/verify-token'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['isValid']) {
        print('Token is valid. Role: ${data['role']}');
      } else {
        print('Token is invalid or expired.');
      }
    } else {
      print('Failed to verify token.');
    }
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
                StarWidget(left: 100.w, top: 50.h, width: 25.w, height: 25.h),
                StarWidget(left: 55.w, top: 130.h, width: 20.w, height: 20.h),
                StarWidget(left: 20.w, top: 200.h, width: 10.w, height: 10.h),
                StarWidget(left: 170.w, top: 90.h, width: 10.w, height: 10.h),
                StarWidget(left: 250.w, top: 30.h, width: 15.w, height: 15.h),
                StarWidget(right: 40.w, top: 130.h, width: 25.w, height: 25.h),
                StarWidget(right: 30.w, top: 250.h, width: 10.w, height: 10.h),
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
                            builder: (context) => const RoleChooseRegister(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 360.w,
                    height: 565.h,
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
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 360.w,
                            height: 160.h,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage('images/galaxy1.png'),
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Center(
                            child: Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 50.h),
                                    Text(
                                      'REGISTER',
                                      style: GoogleFonts.mateSc(
                                        textStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontSize: 25.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: 2.0.w,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 4.0,
                                              color: Color.fromRGBO(0, 0, 0, 0.25),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                                          child: Icon(
                                            Icons.email,
                                            color: Colors.grey[800],
                                            size: 30.r,
                                          ),
                                        ),
                                        labelText: 'EMAIL',
                                        hintText: 'Email (xx012@gmail.com)',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF424242), width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                                        ),
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
                                        if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]@[a-zA-Z]{5,7}\.[a-zA-Z]{3,5}$').hasMatch(value)) {
                                          return 'Enter correct email format';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10.h),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _isObscured,
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                                          child: Icon(
                                            Icons.password_rounded,
                                            color: Colors.grey[800],
                                            size: 30.r,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(_isObscured ? Icons.remove_red_eye_rounded : Icons.visibility_off),
                                          onPressed: _toggleVisibility,
                                        ),
                                        labelText: 'PASSWORD',
                                        hintText: 'Password',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF424242), width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                                        ),
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
                                        if (value == null || value.isEmpty) {
                                          return 'Enter the password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10.h),
                                    TextFormField(
                                      controller: _invitationTokenController,
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                                          child: Icon(
                                            Icons.vpn_key,
                                            color: Colors.grey[800],
                                            size: 30.r,
                                          ),
                                        ),
                                        labelText: 'INVITATION TOKEN',
                                        hintText: 'INVITATION TOKEN',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF424242), width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter the invitation token';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 35.h),
                                    Container(
                                      width: 180.w,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100.r),
                                          ),
                                          shadowColor: Colors.black,
                                        ),
                                        onPressed: _register,
                                        child: AutoSizeText(
                                          'REGISTER',
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
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage(
                                                          role: widget.role,
                                                        )));
                                          },
                                          child: AutoSizeText(
                                            'Login account',
                                            textScaleFactor: 1.3.sp,
                                            style: GoogleFonts.literata(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight:
                                                FontWeight.w600,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white,
                                                decorationThickness: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 50.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 75.w,
                  top: 90.h,
                  child: SizedBox(
                    width: 212.w,
                    height: 230.h,
                    child: Image.asset('images/Logosr1.png'),
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
