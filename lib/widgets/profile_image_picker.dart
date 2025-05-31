import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ProfileImagePicker({
    super.key,
    required this.selectedImage,
    required this.imageUrl,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : (imageUrl != null ? NetworkImage(imageUrl!) : null)
                  as ImageProvider?,
          child: (selectedImage == null && imageUrl == null)
              ? Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null || selectedImage != null)
                GestureDetector(
                  onTap: onRemoveImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF60A5FA),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.camera_alt,
                    color: Color(0xFFF8FAFC),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}