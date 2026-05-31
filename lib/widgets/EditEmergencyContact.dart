import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_states.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class EditEmergencyContact extends StatefulWidget {
  final EmergencyContactsModel contact;
  final ValueNotifier<bool> hasUnsavedChanges;

  const EditEmergencyContact({super.key, required this.contact, required this.hasUnsavedChanges});

  @override
  State<EditEmergencyContact> createState() => _EditEmergencyContactState();
}

class _EditEmergencyContactState extends State<EditEmergencyContact> {
  late TextEditingController nameController;
  String? selectedRelationship;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact.name);
    selectedRelationship = widget.contact.relationship;
    phoneController = TextEditingController(text: widget.contact.phone);
  
    nameController.addListener(checkChanges);
    phoneController.addListener(checkChanges);
  }

  void checkChanges() {
    widget.hasUnsavedChanges.value = nameController.text.trim() != widget.contact.name ||
      selectedRelationship != widget.contact.relationship ||
      phoneController.text.trim() != widget.contact.phone;
  }

  @override
  Widget build(BuildContext context) {
    final contactCubit = context.read<EmergencyContactsCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            // Name
            controller: nameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
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
          // Update
          ValueListenableBuilder<bool>(
            valueListenable: widget.hasUnsavedChanges,
            builder: (context, hasChanges, _) {
              return CustomButton(
                text: 'Update',
                onTap: !hasChanges
                  ? null
                  : () async {
                    final success = contactCubit.updateContact(
                      id: widget.contact.id,
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
          // Delete
          CustomButton(
            text: 'Delete Contact',
            color: Theme.of(context).colorScheme.error,
            onTap: () async {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Emergency Contact'),
                    content: const Text('Are you sure you want to delete this contact?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          contactCubit.removeContact(widget.contact.id);
      
                            final saved = await contactCubit.saveEmergencyContacts();
                            if (!saved) return;
      
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
              );      
            },
          ),
          SizedBox(height: 10.h)
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