import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:image_picker/image_picker.dart';

class edit_staff extends StatefulWidget {
  const edit_staff({super.key});

  @override
  State<edit_staff> createState() => _edit_staffState();
  
}

class _edit_staffState extends State<edit_staff> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

    void showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                AppStrings.tr('choose_photo'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOptionItem(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: AppStrings.tr('gallery'),
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  buildOptionItem(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: AppStrings.tr('camera'),
                    color: AppColors.secondary,
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
           Icon(
            Icons.chevron_left,
          color: AppColors.primary,
        ),
        Spacer(),
            Text(
              "Edit Employee",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20
              ),
        ),
         Spacer(),
          Icon(
            Icons.star,
            
          color: AppColors.secondary,
        )
        ]
        ),
      ),
      body: Column(
        children: [
          buildAvatarSection()
        ],
      ),
    );
  }
    Widget buildAvatarSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            child: ClipOval(
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 80, color: Colors.white),
            ),
          ),
          // GestureDetector(
          //   onTap: () => _showPickerOptions(context),
          //   child: CircleAvatar(
          //     radius: 18,
          //     backgroundColor: Theme.of(context).colorScheme.primary,
          //     child: const Icon(
          //       Icons.camera_alt,
          //       size: 18,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    ).animate().scale(duration: 400.ms);
  }
}