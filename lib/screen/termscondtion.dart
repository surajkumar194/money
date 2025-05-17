import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Terms & Conditions', style: TextStyle(color: Colors.white, fontSize: 19.sp)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff70C7EA), Color(0xff2157AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 21.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms & Conditions',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              Text(
                'These terms and conditions apply to the captcha money (referred to as the "Application"), created by captcha money (referred to as the "Service Provider") as a free service for mobile devices.',
                style: TextStyle(fontSize: 17.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                'By downloading or using the Application, you agree to these terms. Please read them carefully. Unauthorized copying, modification, or redistribution of the Application, or use of our trademarks, is prohibited. Any attempts to extract the source code, translate the Application, or create derivative versions are not permitted. All related trademarks, copyrights, and intellectual property rights remain the property of the Service Provider.',
                style: TextStyle(fontSize: 17.sp),
              ),
              // Add rest of terms text here as needed
            ],
          ),
        ),
      ),
    );
  }
}
