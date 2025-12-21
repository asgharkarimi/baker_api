import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_ad.dart';
import '../../models/job_category.dart';
import '../../models/iran_provinces.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_input_formatter.dart';
import '../../services/api_service.dart';

class AddJobAdScreen extends StatefulWidget {
  final JobAd? adToEdit;

  const AddJobAdScreen({super.key, this.adToEdit});

  @override
  State<AddJobAdScreen> createState() => _AddJobAdScreenState();
}

class _AddJobAdScreenState extends State<AddJobAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dailyBagsController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedProvince;
  bool _isLoading = false;

  bool get _isEditMode => widget.adToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFields();
    } else {
      _loadUserPhone();
    }
  }

  Future<void> _loadUserPhone() async {
    try {
      final user = await ApiService.getCurrentUser();
      if (user != null && user['phone'] != null && mounted) {
        setState(() {
          _phoneController.text = user['phone'].toString();
        });
      }
    } catch (e) {
      debugPrint('Error loading user phone: $e');
    }
  }

  void _populateFields() {
    final ad = widget.adToEdit!;
    _dailyBagsController.text = ad.dailyBags.toString();
    _salaryController.text = _formatNumber(ad.salary);
    _phoneController.text = ad.phoneNumber;
    _descriptionController.text = ad.description;
    _selectedCategory = ad.category;
    _selectedProvince = ad.location;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  void dispose() {
    _dailyBagsController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _convertPersianToEnglish(String input) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String result = input;
    for (int i = 0; i < persian.length; i++) {
      result = result.replaceAll(persian[i], english[i]);
    }
    return result;
  }

  int _parseNumber(String value) {
    final converted = _convertPersianToEnglish(value);
    return int.tryParse(converted.replaceAll(',', '')) ?? 0;
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adData = {
        'title': _selectedCategory ?? 'آگهی استخدام',
        'category': _selectedCategory,
        'dailyBags': _parseNumber(_dailyBagsController.text),
        'salary': _parseNumber(_salaryController.text),
        'location': _selectedProvince,
        'phoneNumber': _convertPersianToEnglish(_phoneController.text),
        'description': _descriptionController.text,
        'images': [],
      };

      bool success;
      if (_isEditMode) {
        success = await ApiService.updateJobAd(widget.adToEdit!.id, adData);
      } else {
        success = await ApiService.createJobAd(adData);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'آگهی با موفقیت ویرایش شد'
                : 'آگهی شما با موفقیت ثبت شد'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'خطا در ویرایش آگهی'
                : 'خطا در ثبت آگهی'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'درج آگهی نیازمند همکار',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'انصراف',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ردیف شغلی
              _buildLabel('ردیف شغلی'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),

              // تعداد پخت و حقوق
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('تعداد پخت (کیسه)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _dailyBagsController,
                          hint: 'مثلا: ۱۰',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'وارد کنید' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('حقوق هفتگی (تومان)'),
                        const SizedBox(height: 8),
                        _buildSalaryField(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // استان محل کار
              _buildLabel('استان محل کار'),
              const SizedBox(height: 8),
              _buildProvinceDropdown(),
              const SizedBox(height: 24),

              // شماره تماس کارفرما
              _buildLabel('شماره تماس کارفرما'),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 24),

              // توضیحات تکمیلی
              _buildLabel('توضیحات تکمیلی'),
              const SizedBox(height: 8),
              _buildDescriptionField(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomButton(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
        ),
        hint: Text(
          'انتخاب کنید (شاطر، چانه‌گیر...)',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        isExpanded: true,
        items: JobCategory.getCategories()
            .map((cat) => DropdownMenuItem(
                  value: cat.title,
                  child: Text(cat.title),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
        validator: (v) => v == null ? 'انتخاب کنید' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSalaryField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'توافقی یا مبلغ',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (v) => setState(() {}),
        validator: (v) {
          if (v?.isEmpty ?? true) return 'وارد کنید';
          return null;
        },
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedProvince,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          prefixIcon:
              Icon(Icons.location_on_outlined, color: Colors.grey.shade600),
        ),
        hint: Text(
          'انتخاب استان',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        isExpanded: true,
        items: IranProvinces.getProvinces()
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
            .toList(),
        onChanged: (v) => setState(() => _selectedProvince = v),
        validator: (v) => v == null ? 'انتخاب کنید' : null,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '09xxxxxxxxx',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Icon(Icons.phone_outlined, color: Colors.grey.shade600),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        validator: (v) {
          if (v?.isEmpty ?? true) return 'شماره تماس را وارد کنید';
          if (v!.length != 11) return 'شماره باید ۱۱ رقم باشد';
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 5,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              'در مورد ساعات کاری، وضعیت بیمه، جای خواب و\nسایر شرایط بنویسید...',
          hintStyle: TextStyle(color: Colors.grey.shade500, height: 1.5),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitAd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'ثبت آگهی',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
