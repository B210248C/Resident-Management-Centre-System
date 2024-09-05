import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1001/loginPage.dart';
import 'package:test1001/roleChooseRegister.dart';
import 'package:test1001/successfulregistered.dart';
import 'component/star_widget.dart';
import 'component/appscreen_constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dcdg/dcdg.dart';

enum Gender { male, female }

class RegisterResident extends StatelessWidget {
  static String id = 'RegisterResident_screen';
  final String role;

  const RegisterResident({super.key, required this.role});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Example design size, adjust as needed
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: registerResident(role:role),
        );
      },
    );
  }
}

class registerResident extends StatefulWidget {
  final String role;

  const registerResident({super.key, required this.role});

  @override
  State<registerResident> createState() => _registerResidentState();
}

class _registerResidentState extends State<registerResident> {
  Color textColor = Colors.white;
  Gender _selectedGender = Gender.male;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  // Add controllers for the form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isObscured = true;
  // Gender _selectedGender = Gender.male;

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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _firestore.collection('rolescollection').doc(userCredential.user!.uid).set({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'gender': _selectedGender.toString().split('.').last,
          'timestamp': FieldValue.serverTimestamp(),
          'role': widget.role,
          'isRead': false,
          'accountstate': false,
        });

        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }
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
                                builder: (context) => const RoleChooseRegister()));
                      },
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    // top: 271,
                    // left: 0,
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
                                // repeat: ImageRepeat.repeatX,
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Center(
                            child: Form(
                              key: _formKey,
                              child: Padding(
                                padding:  EdgeInsets.all(20.w),
                                child: Column(
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // EdgeInsets.fromLTRB(0, 52, 0, 81),
                                  children: [
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    AutoSizeText(
                                      'REGISTER',
                                      textScaleFactor: 1.5.sp,
                                      style: GoogleFonts.mateSc(
                                        textStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontSize: 20.sp,
                                          // fontSize: fontSize,
                                          fontWeight:
                                              FontWeight.w400, // Regular weight
                                          color: Colors.white,
                                          letterSpacing: 2.0.w,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 4.0,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.25),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 10
                                              .sp, // Adjust the factor as needed
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5.w,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey[800],
                                            size: 25.r,
                                          ),
                                        ),
                                        // suffixIcon: Icon(Icons.clear),
                                        labelText: 'USERNAME',
                                        hintText: 'Username',
                                        filled: true,
                                        fillColor: Colors.white,
                                        // border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 5.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight:
                                                FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            // fontSize: fontSize/13,
                                            color: Colors.grey[400],
                                            fontWeight:
                                                FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !RegExp(r'^[a-z A-Z]+$')
                                                .hasMatch(value)) {
                                          return 'Enter correct username';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    TextFormField(
                                      controller: _emailController,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 10
                                              .sp, // Adjust the factor as needed
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5.w,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.email,
                                            color: Colors.grey[800],
                                            size: 25.r,
                                          ),
                                        ),
                                        // suffixIcon: Icon(Icons.clear),
                                        labelText: 'EMAIL',
                                        hintText: 'Email (xx012@gmail.com)',
                                        filled: true,
                                        fillColor: Colors.white,
                                        // border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                         color: Colors.white, width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            // fontSize: fontSize/13,
                                            color: Colors.grey[400],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]@[a-zA-Z]{5,7}\.[a-zA-Z]{3,5}$')
                                                .hasMatch(value)) {
                                          return 'Enter correct email format';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _isObscured,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 10
                                              .sp, // Adjust the factor as needed
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5.w,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.password,
                                            color: Colors.grey[800],
                                            size: 25.r,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscured ? Icons.remove_red_eye_rounded : Icons.visibility_off,
                                          ),
                                          onPressed: _toggleVisibility,
                                        ),
                                        labelText: 'PASSWORD',
                                        hintText: 'Password',
                                        filled: true,
                                        fillColor: Colors.white,
                                        // border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            // fontSize: fontSize/13,
                                            color: Colors.grey[400],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
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
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    TextFormField(
                                      controller: _phoneController,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 10
                                              .sp, // Adjust the factor as needed
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5.w,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.phone,
                                            color: Colors.grey[800],
                                            size: 25.r,
                                          ),
                                        ),
                                        // suffixIcon: Icon(Icons.clear),
                                        labelText: 'PHONE',
                                        hintText: 'Phone',
                                        filled: true,
                                        fillColor: Colors.white,
                                        // border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            // fontSize: fontSize/13,
                                            color: Colors.grey[400],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                                                .hasMatch(value)) {
                                          return 'Enter correct phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    TextFormField(
                                      controller: _addressController,
                                      style: GoogleFonts.literata(
                                        textStyle: TextStyle(
                                          fontSize: 10
                                              .sp, // Adjust the factor as needed
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5.w,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Icon(
                                            Icons.home,
                                            color: Colors.grey[800],
                                            size: 25.r,
                                          ),
                                        ),
                                        // suffixIcon: Icon(Icons.clear),
                                        labelText: 'ADDRESS',
                                        hintText: 'Address',
                                        filled: true,
                                        fillColor: Colors.white,
                                        // border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF424242),
                                              width: 2.0),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0.h),
                                        labelStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[800],
                                            fontWeight:
                                            FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                        hintStyle: GoogleFonts.literata(
                                          textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            // fontSize: fontSize/13,
                                            color: Colors.grey[400],
                                            fontWeight:
                                                FontWeight.w600, // Semibold
                                            letterSpacing: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter the address';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    Container(
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15.w),
                                                child: Icon(
                                                  Icons.wc,
                                                  color: Colors.grey[800],
                                                  size: 25.r,
                                                ),
                                              ),
                                              Text(
                                                'GENDER',
                                                style: GoogleFonts.literata(
                                                  textStyle: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    letterSpacing: 1.5.w,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 80.w,
                                            height: 30.h,
                                            // color: Colors.white,
                                            child: Row(
                                              children: [
                                                Radio<Gender>(
                                                  value: Gender.male,
                                                  groupValue: _selectedGender,
                                                  onChanged: (Gender? value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        _selectedGender = value;
                                                      });
                                                    }
                                                  },
                                                ),
                                                Icon(
                                                  Icons.male,
                                                  color: Colors.grey[800],
                                                  size: 25.r,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80.w,
                                            height: 30.h,
                                            // color: Colors.blue,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Radio<Gender>(
                                                  value: Gender.female,
                                                  groupValue: _selectedGender,
                                                  onChanged: (Gender? value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        _selectedGender = value;
                                                      });
                                                    }
                                                  },
                                                ),
                                                Icon(
                                                  Icons.female,
                                                  color: Colors.grey[800],
                                                  size: 25.r,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 35.h,
                                    ),
                                    Container(
                                      width: 180.w,
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            40.r), // Border radius
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
                                          foregroundColor:
                                              const Color.fromRGBO(35, 73, 108, 1),
                                          backgroundColor:
                                              const Color.fromRGBO(230, 244, 241, 1),
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                100.r),
                                          ),
                                          shadowColor: Colors
                                              .black, // Remove default shadow
                                        ),
                                        onPressed: _register,
                                        child: AutoSizeText(
                                          'REGISTER',
                                          textScaleFactor: 1.2.sp,
                                          style: GoogleFonts.literata(
                                            textStyle: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight:
                                                  FontWeight.w600, // Semibold
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
                                            String role = widget.role;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          loginPage(
                                                            role: role,
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
                                    SizedBox(
                                      height: 50.h,
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
                  top: 90.h,
                  child: SizedBox(
                    // color: Colors.black,
                    width: 212.w,
                    height: 230.h,
                    // color: Colors.black,
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

