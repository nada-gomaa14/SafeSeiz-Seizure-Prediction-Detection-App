import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w
      ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
                      
          calendarFormat: CalendarFormat.week,
          daysOfWeekVisible: true,
                      
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16.sp,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            )
          ),
                      
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
            defaultTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 14.sp,
            ),  
            weekendTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 14.sp,
            )      
        ),
                      
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 14.sp,
          ),
          weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 14.sp,
          )    
        )          
      )
    );
  }

}



