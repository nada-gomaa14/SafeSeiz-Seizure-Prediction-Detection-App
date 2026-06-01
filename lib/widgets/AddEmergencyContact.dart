import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_states.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class AddEmergencyContact extends StatefulWidget {
  final ValueNotifier<bool> hasUnsavedChanges;

  const AddEmergencyContact({super.key, required this.hasUnsavedChanges});

  @override
  State<AddEmergencyContact> createState() => _AddEmergencyContactState();
}

class _AddEmergencyContactState extends State<AddEmergencyContact> {
  late TextEditingController nameController;
  String? selectedRelationship;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    selectedRelationship = null;
    phoneController = TextEditingController();

    nameController.addListener(checkChanges);
    phoneController.addListener(checkChanges);
  }

  void checkChanges() {
    widget.hasUnsavedChanges.value = nameController.text.trim().isNotEmpty ||
      phoneController.text.trim().isNotEmpty ||
      selectedRelationship != null;
  }

  @override
  Widget build(BuildContext context) {
    final contactCubit = context.read<EmergencyContactsCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          TextField(
            controller: nameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
            ],
            onChanged: (value) {
              if (value.isEmpty) return;

              final capitalized = value
                  .split(' ')
                  .map((word) {
                    if (word.isEmpty) return '';
                    return word[0].toUpperCase() +
                        word.substring(1).toLowerCase();
                  })
                  .join(' ');

              if (capitalized != value) {
                nameController.value = TextEditingValue(
                  text: capitalized,
                  selection: TextSelection.collapsed(
                    offset: capitalized.length,
                  ),
                );
              }
            },
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Relationship
          DropdownButtonFormField<String>(
            value: selectedRelationship,
            isExpanded: true,
            icon: Padding(
              padding: EdgeInsets.only(right: 10.0.r),
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.tertiary
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Relationship',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
            items: EmergencyContactsModel.relationships.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRelationship = value;
              });

              checkChanges();
            },
          ),
          SizedBox(height: 10.h),
          // Phone
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Phone',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          // Error Message
          BlocSelector<EmergencyContactsCubit, EmergencyContactsStates, String?>(
            selector: (state) {
              if (state is EmergencyContactsErrorState) {
                return state.message;
              }
      
              return null;
            },
            builder: (context, errorMessage) {
              if (errorMessage != null) { 
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0.sp,
                        color: Theme.of(context).colorScheme.error
                      )
                    ),
                  ),
                );
              }
      
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: 20.h),
          // Save
          ValueListenableBuilder<bool>(
            valueListenable: widget.hasUnsavedChanges,
            builder: (context, hasChanges, _) {
              return CustomButton(
                text: 'Save',
                onTap: !hasChanges
                  ? null
                  : () async {
                    final success = contactCubit.addContact(
                      name: nameController.text,
                      relationship: selectedRelationship ?? '',
                      phone: phoneController.text
                    );
                      
                    if (!success) return;
                      
                    final saved = await contactCubit.saveEmergencyContacts();
                      
                    if (!saved) return;
                      
                    if (context.mounted) {
                      widget.hasUnsavedChanges.value = false;
                      Navigator.pop(context);
                    }
                  },
              );
            }
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );   
  }

  @override
  void dispose() {
    nameController.removeListener(checkChanges);
    phoneController.removeListener(checkChanges);
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}