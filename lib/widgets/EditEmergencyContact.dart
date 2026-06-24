import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/contact/cubit/emergency_contact_cubit.dart';
import 'package:safeseiz/user/contact/cubit/emergency_contact_states.dart';
import 'package:safeseiz/user/contact/models/emergency_contact_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class EditEmergencyContact extends StatefulWidget {
  final EmergencyContactModel contact;
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
    phoneController = TextEditingController(
      text: widget.contact.phone.startsWith('+20')
        ? widget.contact.phone.substring(3)
        : widget.contact.phone,
    );
  
    nameController.addListener(checkChanges);
    phoneController.addListener(checkChanges);
  }

  void checkChanges() {
    final originalPhone = widget.contact.phone.startsWith('+20')
      ? widget.contact.phone.substring(3)
      : widget.contact.phone;

    widget.hasUnsavedChanges.value = nameController.text.trim() != widget.contact.name ||
      selectedRelationship != widget.contact.relationship ||
      phoneController.text.trim() != originalPhone;
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
              fontSize: 16.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Relationship
          DropdownButtonFormField<String>(
            value: selectedRelationship,
            isExpanded: true,
            icon: Padding(
              padding: EdgeInsets.only(right: 10.0.r * Responsive.scale(context)),
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.tertiary
              ),
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w * Responsive.scale(context), 
                vertical: 16.h * Responsive.scale(context)
              ),
              labelText: 'Relationship',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
            items: EmergencyContactModel.relationships.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp * Responsive.scale(context),
                    color: Theme.of(context).colorScheme.primary,
                    height: 0.5 * Responsive.scale(context),
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
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Phone
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textInputAction: TextInputAction.done,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Phone',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              prefixText: '(+ 20) ',
              prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.primary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
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
                    padding: EdgeInsets.only(top: 10.h * Responsive.scale(context)),
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0.sp * Responsive.scale(context),
                        color: Theme.of(context).colorScheme.error
                      )
                    ),
                  ),
                );
              }
        
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: 20.h * Responsive.scale(context)),
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
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Delete
          CustomButton(
            text: 'Delete Contact',
            color: Theme.of(context).colorScheme.error,
            onTap: () async {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (_) => AlertDialog(
                  title: Text(
                    'Delete Emergency Contact',
                      style: TextStyle(
                        fontSize: 20.sp * Responsive.scale(context),
                      )
                    ),
                    content: Text(
                      'Are you sure you want to delete this contact?',
                      style: TextStyle(
                        fontSize: 12.sp * Responsive.scale(context),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12.sp * Responsive.scale(context),
                          ),
                        ),
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
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12.sp * Responsive.scale(context),
                          ),
                        ),
                      ),
                    ],
                  ),
              );      
            },
          ),
          SizedBox(height: 10.h * Responsive.scale(context))
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