import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/job_seeker.dart';
import '../../models/job_category.dart';
import '../../models/iran_provinces.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/number_to_words.dart';
import '../../services/api_service.dart';

class AddJobSeekerProfileScreen extends StatefulWidget {
  final JobSeeker? profileToEdit;

  const AddJobSeekerProfileScreen({super.key, this.profileToEdit});

  @override
  State<AddJobSeekerProfileScreen> createState() =>
      _AddJobSeekerProfileScreenState();
}

class _AddJobSeekerProfileScreenState extends State<AddJobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _salaryController = TextEditingController();

  bool _isMarried = false;
  bool _isSmoker = false;
  bool _hasAddiction = false;
  bool _hasHealthCard = false;
  List<String> _selectedSkills = [];
  String _salaryWords = '';
  File? _profileImage;
  File? _healthCardImage;
  String? _existingProfileImage;
  String? _selectedProvince;
  bool _isLoading = false;
  double _rating = 4.8;

  bool get _isEditMode => widget.profileToEdit != null;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFields();
    } else {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          if (user['name'] != null && user['name'].toString().isNotEmpty) {
            final nameParts = user['name'].toString().split(' ');
            _firstNameController.text =
                nameParts.isNotEmpty ? nameParts.first : '';
            _lastNameController.text =
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          }
          if (user['profileImage'] != null &&
              user['profileImage'].toString().isNotEmpty) {
            _existingProfileImage = user['profileImage'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  void _populateFields() {
    final profile = widget.profileToEdit!;
    final nameParts = profile.name.split(' ');
    _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
    _lastNameController.text =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    _salaryController.text = _formatNumber(profile.expectedSalary);
    _salaryWords = NumberToWords.convert(_salaryController.text);
    _selectedProvince = profile.location;
    _selectedSkills = List<String>.from(profile.skills);
    _isMarried = profile.isMarried;
    _isSmoker = profile.isSmoker;
    _hasAddiction = profile.hasAddiction;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    _showImagePickerSheet((file) {
      setState(() => _profileImage = file);
    });
  }

  Future<void> _pickHealthCardImage() async {
    _showImagePickerSheet((file) {
      setState(() => _healthCardImage = file);
    });
  }

  void _showImagePickerSheet(Function(File) onPicked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.camera_alt,
                    label: 'دوربین',
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final image = await _picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        imageQuality: 85,
                      );
                      if (image != null) onPicked(File(image.path));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.photo_library,
                    label: 'گالری',
                    color: Colors.purple,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        imageQuality: 85,
                      );
                      if (image != null) onPicked(File(image.path));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حداقل یک مهارت انتخاب کنید'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await ApiService.uploadImage(_profileImage!);
      }

      final salaryText = _salaryController.text.replaceAll(',', '');
      final salary = int.tryParse(salaryText) ?? 0;

      final data = {
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'skills': _selectedSkills,
        'expectedSalary': salary,
        'province': _selectedProvince,
        'location': _selectedProvince,
        'isMarried': _isMarried,
        'isSmoker': _isSmoker,
        'hasAddiction': _hasAddiction,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
      };

      bool success;
      if (_isEditMode) {
        success =
            await ApiService.updateJobSeeker(widget.profileToEdit!.id, data);
      } else {
        success = await ApiService.createJobSeeker(data);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isEditMode
                    ? 'پروفایل با موفقیت ویرایش شد'
                    : 'پروفایل با موفقیت ثبت شد'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isEditMode
                    ? 'خطا در ویرایش پروفایل'
                    : 'خطا در ثبت پروفایل'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('پروفایل کارجو',
              style: TextStyle(color: Colors.black87)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // پروفایل هدر
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // اطلاعات فردی
              _buildSectionCard(
                title: 'اطلاعات فردی',
                children: [
                  // نام و نام خانوادگی
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'نام خانوادگی',
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'وارد کنید' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'نام',
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'وارد کنید' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // وضعیت تاهل
                  _buildLabel('وضعیت تاهل'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChoiceChip('مجرد', !_isMarried,
                          () => setState(() => _isMarried = false)),
                      const SizedBox(width: 12),
                      _buildChoiceChip('متاهل', _isMarried,
                          () => setState(() => _isMarried = true)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // محل سکونت
                  _buildLabel('محل سکونت'),
                  const SizedBox(height: 8),
                  _buildProvinceDropdown(),
                  const SizedBox(height: 16),

                  // حقوق درخواستی
                  _buildLabel('حقوق درخواستی (تومان)'),
                  const SizedBox(height: 8),
                  _buildSalaryField(),
                ],
              ),
              const SizedBox(height: 16),

              // مهارت‌های نانوایی
              _buildSkillsSection(),
              const SizedBox(height: 16),

              // وضعیت سلامت
              _buildHealthSection(),
              const SizedBox(height: 16),

              // کارت بهداشت - فقط اگه داره نمایش بده
              if (_hasHealthCard) _buildHealthCardSection(),
              if (_hasHealthCard) const SizedBox(height: 16),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // دکمه ذخیره
        bottomNavigationBar: _buildBottomButton(),
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // عکس پروفایل
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGreen, width: 3),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : _existingProfileImage != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    '${ApiService.serverUrl}$_existingProfileImage'),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: _profileImage == null && _existingProfileImage == null
                      ? Icon(Icons.person,
                          size: 50, color: Colors.grey.shade400)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // نام
          Text(
            _firstNameController.text.isNotEmpty ||
                    _lastNameController.text.isNotEmpty
                ? '${_firstNameController.text} ${_lastNameController.text}'
                : 'نام شما',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // لینک ویرایش عکس
          TextButton(
            onPressed: _pickProfileImage,
            child: Text(
              'ویرایش عکس پروفایل',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 13,
              ),
            ),
          ),

          // امتیاز
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                _rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'امتیاز کارفرما:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedProvince,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on, color: Colors.grey),
        ),
        hint: const Text('انتخاب استان'),
        isExpanded: true,
        items: IranProvinces.getProvinces()
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
            .toList(),
        onChanged: (v) => setState(() => _selectedProvince = v),
        validator: (v) => v == null ? 'استان را انتخاب کنید' : null,
      ),
    );
  }

  Widget _buildSalaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            onChanged: (v) =>
                setState(() => _salaryWords = NumberToWords.convert(v)),
            validator: (v) => v?.isEmpty ?? true ? 'حقوق را وارد کنید' : null,
          ),
        ),
        if (_salaryWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _salaryWords,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }


  Widget _buildSkillsSection() {
    final skills = JobCategory.getCategories();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'مهارت‌های نانوایی',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => _showSkillsBottomSheet(skills),
                child: Text(
                  'افزودن +',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSkills.map((skill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (_selectedSkills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'مهارت‌های خود را اضافه کنید',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  void _showSkillsBottomSheet(List<JobCategory> skills) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'انتخاب مهارت‌ها',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (_, i) {
                  final skill = skills[i];
                  final isSelected = _selectedSkills.contains(skill.title);
                  return ListTile(
                    title: Text(skill.title),
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isSelected ? AppTheme.primaryGreen : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkills.remove(skill.title);
                        } else {
                          _selectedSkills.add(skill.title);
                        }
                      });
                      Navigator.pop(ctx);
                      _showSkillsBottomSheet(skills);
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تایید',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وضعیت سلامت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // استعمال دخانیات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('استعمال دخانیات',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('سیگار یا مواد مخدر',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              Row(
                children: [
                  _buildSmallChoiceChip(
                      'خیر', !_isSmoker, () => setState(() => _isSmoker = false)),
                  const SizedBox(width: 8),
                  _buildSmallChoiceChip(
                      'بله', _isSmoker, () => setState(() => _isSmoker = true)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // کارت بهداشت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('کارت بهداشت',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('دارای اعتبار قانونی',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              Row(
                children: [
                  _buildSmallChoiceChip('خیر', !_hasHealthCard,
                      () => setState(() => _hasHealthCard = false)),
                  const SizedBox(width: 8),
                  _buildSmallChoiceChip('بله', _hasHealthCard,
                      () => setState(() => _hasHealthCard = true)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChoiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'کارت بهداشت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickHealthCardImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                image: _healthCardImage != null
                    ? DecorationImage(
                        image: FileImage(_healthCardImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _healthCardImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'آپلود تصویر کارت بهداشت',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'فرمت JPG یا PNG (حداکثر 2 مگابایت)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ],
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
            onPressed: _isLoading ? null : _submitProfile,
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
                        'ذخیره تغییرات',
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
