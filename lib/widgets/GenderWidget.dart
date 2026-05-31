import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class GenderWidget extends StatefulWidget {
  const GenderWidget({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.errorText
  });

  final Function(String) onChanged;
  final String? initialValue;
  final String? errorText;

  @override
  State<GenderWidget> createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant GenderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync UI if cubit updates value externally
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedGender = widget.initialValue;
      });
    }
  }

  Widget buildGenderButton({
    required String label,
    required String value
  }) {
    final isSelected = selectedGender == value;

    return CustomButton(
      text: label,
      onTap: () {
        setState(() {
          selectedGender = value;
        });
        widget.onChanged(value);
      },
      color: isSelected
          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)
          : Colors.transparent,
      textColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      border: isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey
          )
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: buildGenderButton(
                label:'Male',
                value: 'male'
              )
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: buildGenderButton(
                label: 'Female',
                value: 'female',
              )
            ),
          ],
        ),

        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              widget.errorText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                color: const Color(0xFF990000)
              )
            ),
          ),
      ],
    );
  }
}