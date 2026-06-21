import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30.0.w * Responsive.scale(context),
            vertical: 10.0.h * Responsive.scale(context)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0.h * Responsive.scale(context)),
                CustomButton(
                  text: 'Export Report',
                  onTap: () {}, 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}