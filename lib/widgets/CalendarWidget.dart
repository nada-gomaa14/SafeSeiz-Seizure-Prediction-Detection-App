import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final List<SeizureModel> seizures;
  const CalendarWidget({super.key, required this.seizures});

  @override
  Widget build(BuildContext context) {
    List<SeizureModel> getSeizuresForDay(DateTime day) {
      return seizures.where((seizure) {
        return seizure.seizureDateTime.year == day.year &&
          seizure.seizureDateTime.month == day.month &&
          seizure.seizureDateTime.day == day.day;
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0.w * Responsive.scale(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              eventLoader: getSeizuresForDay,
              calendarFormat: CalendarFormat.week,
              daysOfWeekVisible: true,
              rowHeight: 40.h * Responsive.scale(context),
                            
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16.sp * Responsive.scale(context),
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
                  fontSize: 14.sp * Responsive.scale(context),
                ),
                defaultTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 14.sp * Responsive.scale(context),
                ),  
                weekendTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 14.sp * Responsive.scale(context),
                ),
              ),
                            
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 14.sp * Responsive.scale(context),
                ),
                weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 14.sp * Responsive.scale(context),
                )    
              ),
              daysOfWeekHeight: 20.h * Responsive.scale(context),  
              
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 5.r * Responsive.scale(context),
                      height: 5.r * Responsive.scale(context),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),   
            ),
            SizedBox(height: 5.0.h * Responsive.scale(context)),
            Row(
              children: [
                Container(
                  width: 5.r * Responsive.scale(context),
                  height: 5.r * Responsive.scale(context),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.0.w * Responsive.scale(context)),
                Text(
                  'Seizure events',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12.sp * Responsive.scale(context),
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}