import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomColumn extends StatelessWidget {
  final String title;
  final String imagePath;
  final int unreadCount;
  final Widget destination;
  final bool showBadge;
  final bool overflowEllipsis;
  final bool singleLine;
  final double imageSize;
  final double badgeTop;
  final double badgeRight;

  const CustomColumn({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.unreadCount,
    required this.destination,
    this.showBadge = true,
    this.overflowEllipsis = false,
    this.singleLine = false,
    this.imageSize = 100.0,
    this.badgeTop = 0.0,
    this.badgeRight = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: imageSize.h,
                  maxWidth: imageSize.w,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 220, 196, 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      blurRadius: 7,
                      spreadRadius: 0,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              if (showBadge)
                Positioned(
                  top: badgeTop.h,
                  right: badgeRight.w,
                  child: badges.Badge(
                    badgeContent: Text(
                      '$unreadCount',
                      style: TextStyle(color: Colors.white),
                    ),
                    position: badges.BadgePosition.topEnd(top: 0, end: 0),
                    badgeAnimation: badges.BadgeAnimation.slide(),
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.circle,
                      badgeColor: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        SizedBox(
          height: 60.h,
          width: 90.w,
          child: AutoSizeText(
            title,
            textScaleFactor: 1.2.sp,
            maxLines: singleLine ? 1 : 2,
            textAlign: TextAlign.center,
            overflow: overflowEllipsis ? TextOverflow.ellipsis : TextOverflow.visible,
            softWrap: !singleLine,
            style: GoogleFonts.literata(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}