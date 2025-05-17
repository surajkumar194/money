
// Privacy Policy Screen
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 19.sp)),
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
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(
                'This privacy policy applies to the captcha money app (hereby referred to as "Application") for mobile devices created by Quanta (referred to as "Service Provider"). The Application is provided for free and intended for use "AS IS".',
                style: TextStyle(fontSize: 17.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                'Information Collection and Use',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'The Application collects certain information when you download and use it. This information may include:',
                style: TextStyle(fontSize: 17.sp),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '• Your device’s Internet Protocol address (e.g., IP address)',
                style: TextStyle(fontSize: 17.sp),
              ),
              Text(
                '• Pages visited within the Application, date and time of visit, and duration on each page',
                style: TextStyle(fontSize: 17.sp),
              ),
              Text(
                '• Time spent on the Application overall',
                style: TextStyle(fontSize: 17.sp),
              ),
              Text(
                '• Your mobile device’s operating system',
                style: TextStyle(fontSize: 17.sp),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'The Application does not gather precise location data.',
                style: TextStyle(fontSize: 17.sp),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'The Service Provider may use this information to contact you with important updates, required notices, or promotional offers. Additionally, the Service Provider may require you to provide personally identifiable information such as your name, phone number, email, address, and gender to improve your experience. This information will be retained as described in this policy.',
                style: TextStyle(fontSize: 17.sp),
              ),
              // Aap yahan baaki text bhi add kar sakte hain same style me
            ],
          ),
        ),
      ),
    );
  }
}

// Terms & Conditions Screen

// Contact Us Screen (Simple placeholder)