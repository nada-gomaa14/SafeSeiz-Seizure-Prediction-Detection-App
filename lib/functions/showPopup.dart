import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';

Future<void> showPopup({
  required BuildContext context,
  required String title,
  required Widget child,
  required ValueNotifier<bool> hasUnsavedChanges,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: !hasUnsavedChanges.value,
    enableDrag: false,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0.r * Responsive.scale(context)),
      ),
    ),
    builder: (bottomSheetContext) {
      Future<void> handleClose() async{
        if (!hasUnsavedChanges.value) {
          Navigator.pop(bottomSheetContext);
          return;
        }

        final close = await showDialog<bool>(
          context: bottomSheetContext, 
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(
                  'Discard Changes?',
                  style: TextStyle(
                    fontSize: 20.sp * Responsive.scale(context),
                  ),
                ),
              content: SizedBox(
                width: Responsive.isTablet(context) ? 500.w : 300.w,
                child: Text(
                  'You have unsaved changes.',
                  style: TextStyle(
                    fontSize: 12.sp * Responsive.scale(context),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 12.sp * Responsive.scale(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    'Discard',
                    style: TextStyle(
                      fontSize: 12.sp * Responsive.scale(context),
                    ),
                  ),
                ),
              ]
            );
          }
        );

        if (close == true && bottomSheetContext.mounted) {
          Navigator.pop(bottomSheetContext);
        }
      };

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await handleClose();
        },
        child: Padding(
          padding: EdgeInsets.only(
            right: 20.0.w * Responsive.scale(context),
            left: 20.0.w * Responsive.scale(context),
            top: 20.0.h * Responsive.scale(context),
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20.0.h * Responsive.scale(context)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18.sp * Responsive.scale(context),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await handleClose();
                    }, 
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.tertiary,
                    )
                  ),
                ],
              ),
              SizedBox(height: 20.h * Responsive.scale(context)),
              child,
            ],
          ),
        ),
      );
    },
  );
}