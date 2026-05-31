import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';


class SeizureTypeWidget extends StatefulWidget {
  final Function(List<String>) onChanged;

  const SeizureTypeWidget({
    super.key,
    required this.onChanged,
  });

  @override
  _SeizureTypeWidgetState createState() => _SeizureTypeWidgetState();
}

class _SeizureTypeWidgetState extends State<SeizureTypeWidget> {
  Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 5.w,
          children: [
            Text(
              'Seizure Type',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              )
            ),
            Text(
              ' (select all that apply)',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ) 
            )
          ]     
        ),
        Wrap(
          spacing: 8.w,
          children: MedicalModel.seizureTypeOptions.map((option) {
            final isSelected = selected.contains(option);
        
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.secondary 
                    : Theme.of(context).colorScheme.primary,
                )
              ),  
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  value ? selected.add(option) : selected.remove(option);
                  widget.onChanged(selected.toList());
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              showCheckmark: false,
            );
          }).toList(),
        )
      ]
    );
  }
}