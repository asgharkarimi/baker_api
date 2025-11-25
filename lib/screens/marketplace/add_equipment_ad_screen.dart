import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/number_to_words.dart';
import '../map/location_picker_screen.dart';

class AddEquipmentAdScreen extends StatefulWidget {
  const AddEquipmentAdScreen({super.key});

  @override
  State<AddEquipmentAdScreen> createState() => _AddEquipmentAdScreenState();
}

class _AddEquipmentAdScreenState extends State<AddEquipmentAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedLocation;
  String _priceWords = '';
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('آگهی با موفقیت ثبت شد')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('درج آگهی دستگاه'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'عنوان را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'قیمت (تومان)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (value) {
                  setState(() {
                    _priceWords = NumberToWords.convert(value);
                  });
                },
                validator: (v) =>
                    v?.isEmpty ?? true ? 'قیمت را وارد کنید' : null,
              ),
              if (_priceWords.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8, right: 16),
                  child: Text(
                    _priceWords,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'محل',
                  hintText: 'انتخاب از روی نقشه',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGreen),
                  suffixIcon: Icon(Icons.map, color: AppTheme.primaryGreen),
                ),
                controller: TextEditingController(text: _selectedLocation),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPickerScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _selectedLocation = result.toString();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('موقعیت از نقشه انتخاب شد'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  }
                },
                validator: (v) => _selectedLocation == null ? 'محل را از روی نقشه انتخاب کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'شماره تماس',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'شماره تماس را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'توضیحات',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'توضیحات را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              // بخش عکس‌ها با placeholder
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'تصاویر دستگاه',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // Grid عکس‌ها + دکمه افزودن
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _selectedImages.length + 1, // +1 برای دکمه افزودن
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          // دکمه افزودن عکس
                          return GestureDetector(
                            onTap: () async {
                              try {
                                final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                
                                if (image != null && mounted) {
                                  setState(() {
                                    _selectedImages.add(File(image.path));
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('عکس اضافه شد'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('خطا در انتخاب عکس'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryGreen,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: AppTheme.primaryGreen,
                                    size: 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'افزودن',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // نمایش عکس
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // دکمه حذف
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
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
                      },
                    ),
                    
                    if (_selectedImages.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'حداقل یک عکس از دستگاه اضافه کنید',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // آپلود ویدیو
                },
                icon: Icon(Icons.video_library),
                label: Text('افزودن ویدیو'),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAd,
                  child: Text('ثبت آگهی'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
