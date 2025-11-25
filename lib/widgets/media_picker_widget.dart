import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/media_picker_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_buttons_style.dart';
import '../utils/responsive.dart';

class MediaPickerWidget extends StatelessWidget {
  final List<File> selectedImages;
  final List<File> selectedVideos;
  final Function(List<File>) onImagesChanged;
  final Function(List<File>) onVideosChanged;
  final int? maxImages;
  final int? maxVideos;
  final bool showImagePicker;
  final bool showVideoPicker;

  const MediaPickerWidget({
    super.key,
    required this.selectedImages,
    required this.selectedVideos,
    required this.onImagesChanged,
    required this.onVideosChanged,
    this.maxImages,
    this.maxVideos,
    this.showImagePicker = true,
    this.showVideoPicker = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showImagePicker) ...[
          _buildImageSection(context),
          SizedBox(height: context.responsive.spacing(16)),
        ],
        if (showVideoPicker) ...[
          _buildVideoSection(context),
        ],
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final canAddMore = maxImages == null || selectedImages.length < maxImages!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAddMore ? () => _pickImages(context) : null,
                icon: Icon(Icons.image),
                label: Text(
                  maxImages != null
                      ? 'افزودن عکس (${selectedImages.length}/$maxImages)'
                      : 'افزودن عکس',
                ),
                style: AppButtonsStyle.outlinedIconButton(),
              ),
            ),
          ],
        ),
        if (selectedImages.isNotEmpty) ...[
          SizedBox(height: context.responsive.spacing(12)),
          _buildImageGrid(context),
        ],
      ],
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final canAddMore = maxVideos == null || selectedVideos.length < maxVideos!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAddMore ? () => _pickVideo(context) : null,
                icon: Icon(Icons.video_library),
                label: Text(
                  maxVideos != null
                      ? 'افزودن ویدیو (${selectedVideos.length}/$maxVideos)'
                      : 'افزودن ویدیو',
                ),
                style: AppButtonsStyle.outlinedIconButton(),
              ),
            ),
          ],
        ),
        if (selectedVideos.isNotEmpty) ...[
          SizedBox(height: context.responsive.spacing(12)),
          _buildVideoList(context),
        ],
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: context.responsive.spacing(8),
        mainAxisSpacing: context.responsive.spacing(8),
      ),
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageItem(context, selectedImages[index], index);
      },
    );
  }

  Widget _buildImageItem(BuildContext context, File image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              context.responsive.borderRadius(12),
            ),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              final newList = List<File>.from(selectedImages)..removeAt(index);
              onImagesChanged(newList);
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoList(BuildContext context) {
    return Column(
      children: selectedVideos.asMap().entries.map((entry) {
        return _buildVideoItem(context, entry.value, entry.key);
      }).toList(),
    );
  }

  Widget _buildVideoItem(BuildContext context, File video, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsive.spacing(8)),
      padding: context.responsive.padding(all: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(
          context.responsive.borderRadius(12),
        ),
        border: Border.all(color: AppTheme.primaryGreen),
      ),
      child: Row(
        children: [
          Icon(Icons.video_library, color: AppTheme.primaryGreen),
          SizedBox(width: context.responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.path.split('/').last,
                  style: TextStyle(
                    fontSize: context.responsive.fontSize(14),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FutureBuilder<int>(
                  future: MediaPickerService.getFileSize(video),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        MediaPickerService.formatFileSize(snapshot.data!),
                        style: TextStyle(
                          fontSize: context.responsive.fontSize(12),
                          color: AppTheme.textGrey,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              final newList = List<File>.from(selectedVideos)..removeAt(index);
              onVideosChanged(newList);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final source = await _showSourceDialog(context);
    if (source == null) return;

    if (source == ImageSource.gallery && (maxImages == null || maxImages! > 1)) {
      final images = await MediaPickerService.pickMultipleImages();
      if (images.isNotEmpty) {
        final newList = List<File>.from(selectedImages)..addAll(images);
        if (maxImages != null && newList.length > maxImages!) {
          newList.removeRange(maxImages!, newList.length);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حداکثر $maxImages عکس می‌توانید انتخاب کنید'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        onImagesChanged(newList);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${images.length} عکس اضافه شد'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('هیچ عکسی انتخاب نشد'),
            ),
          );
        }
      }
    } else {
      final image = await MediaPickerService.pickImage(source: source);
      if (image != null) {
        final newList = List<File>.from(selectedImages)..add(image);
        onImagesChanged(newList);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('عکس اضافه شد'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final source = await _showSourceDialog(context);
    if (source == null) return;

    final video = await MediaPickerService.pickVideo(
      source: source,
      maxDuration: Duration(minutes: 5),
    );
    
    if (video != null) {
      final newList = List<File>.from(selectedVideos)..add(video);
      onVideosChanged(newList);
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
