import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        top: Radius.circular(15.0.r),
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
              title: const Text('Discard Changes?'),
              content: const Text('You have unsaved changes.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Discard'),
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
          padding: EdgeInsets.all(20.0.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18.sp,
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
              SizedBox(height: 20.h),
              child,
            ],
          ),
        ),
      );
    },
  );
}