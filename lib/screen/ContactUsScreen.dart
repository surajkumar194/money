
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Contact Us', style: TextStyle(color: Colors.white, fontSize: 19.sp)),
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Text(
            'For inquiries, email us at:\n\ncontact@financeforfinance.com ',
            style: TextStyle(fontSize: 17.sp),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
