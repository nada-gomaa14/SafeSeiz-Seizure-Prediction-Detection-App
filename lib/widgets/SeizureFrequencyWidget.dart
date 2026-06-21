import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';

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
    return Wrap(
      spacing: 8.w * Responsive.scale(context),
      runSpacing: 8.h * Responsive.scale(context),
      children: MedicalModel.seizureFrequencyOptions.map((option) {
        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              fontSize: 14.sp * Responsive.scale(context),
              color: selected == option 
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            )
          ),  
          selected: selected == option,
          onSelected: (isSelected) {
            setState(() {
              selected = isSelected ? option : null;
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
            borderRadius: BorderRadius.circular(20.0.r * Responsive.scale(context)),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}