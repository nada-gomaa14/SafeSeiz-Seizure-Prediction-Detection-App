import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';

class SeizureFrequencyWidget extends StatefulWidget {
  final Function(String?) onChanged;

  const SeizureFrequencyWidget({
    super.key,
    required this.onChanged,
  });

  @override
  _SeizureFrequencyWidgetState createState() => _SeizureFrequencyWidgetState();
}

class _SeizureFrequencyWidgetState extends State<SeizureFrequencyWidget> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seizure Frequency',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          )
        ),
        Wrap(
          spacing: 8.w,
          children: MedicalModel.seizureFrequencyOptions.map((option) {
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: selected == option 
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
                )
              ),  
              selected: selected == option,
              onSelected: (_) {
                setState(() {
                  selected = option;
                  widget.onChanged(selected);
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              side: BorderSide(
                color: selected == option 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}