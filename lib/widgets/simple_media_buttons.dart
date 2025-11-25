import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/media_picker_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_buttons_style.dart';

// دکمه‌های ساده برای انتخاب رسانه
class SimpleMediaButtons extends StatelessWidget {
  final Function(File) onImagePicked;
  final Function(File) onVideoPicked;
  final bool showImageButton;
  final bool showVideoButton;

  const SimpleMediaButtons({
    super.key,
    required this.onImagePicked,
    required this.onVideoPicked,
    this.showImageButton = true,
    this.showVideoButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showImageButton)
          OutlinedButton.icon(
            onPressed: () => _pickImage(context),
            icon: Icon(Icons.image),
            label: Text('افزودن عکس'),
            style: AppButtonsStyle.outlinedIconButton(),
          ),
        if (showImageButton && showVideoButton) SizedBox(height: 8),
        if (showVideoButton)
          OutlinedButton.icon(
            onPressed: () => _pickVideo(context),
            icon: Icon(Icons.video_library),
            label: Text('افزودن ویدیو'),
            style: AppButtonsStyle.outlinedIconButton(),
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final source = await _showSourceDialog(context);
    if (source == null) return;

    final image = await MediaPickerService.pickImage(source: source);
    if (image != null) {
      onImagePicked(image);
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final source = await _showSourceDialog(context);
    if (source == null) return;

    final video = await MediaPickerService.pickVideo(source: source);
    if (video != null) {
      onVideoPicked(video);
    }
  }

  Future<ImageSource?> _showSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('انتخاب منبع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                title: Text('دوربین'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                title: Text('گالری'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
