import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_category.dart';
import '../../models/iran_provinces.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/number_to_words.dart';

class AddJobAdScreen extends StatefulWidget {
  const AddJobAdScreen({super.key});

  @override
  State<AddJobAdScreen> createState() => _AddJobAdScreenState();
}

class _AddJobAdScreenState extends State<AddJobAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dailyBagsController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedProvince;
  String _salaryWords = '';

  @override
  void dispose() {
    _titleController.dispose();
    _dailyBagsController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
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
          title: Text('درج آگهی نیازمند همکار'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان آگهی',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'عنوان را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'تخصص مورد نیاز',
                  prefixIcon: Icon(Icons.category),
                ),
                isExpanded: true,
                alignment: Alignment.centerRight,
                items: JobCategory.getCategories()
                    .map((cat) => DropdownMenuItem(
                          value: cat.title,
                          alignment: Alignment.centerRight,
                          child: Text(
                            cat.title,
                            textAlign: TextAlign.right,
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (v) => v == null ? 'تخصص را انتخاب کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dailyBagsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'تعداد کارکرد روزانه (کیسه)',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'تعداد کارکرد روزانه را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'حقوق هفتگی (تومان)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (value) {
                  setState(() {
                    _salaryWords = NumberToWords.convert(value);
                  });
                },
                validator: (v) => v?.isEmpty ?? true ? 'حقوق هفتگی را وارد کنید' : null,
              ),
              if (_salaryWords.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8, right: 16),
                  child: Text(
                    _salaryWords,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: InputDecoration(
                  labelText: 'استان محل کار',
                  prefixIcon: Icon(Icons.location_on),
                ),
                isExpanded: true,
                alignment: Alignment.centerRight,
                items: IranProvinces.getProvinces()
                    .map((province) => DropdownMenuItem(
                          value: province,
                          alignment: Alignment.centerRight,
                          child: Text(
                            province,
                            textAlign: TextAlign.right,
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedProvince = value),
                validator: (v) => v == null ? 'استان را انتخاب کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'شماره تماس',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'شماره تماس را وارد کنید' : null,
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
