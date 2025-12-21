import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(4, (_) => FocusNode());
  
  bool _codeSent = false;
  bool _isLoading = false;
  int _resendSeconds = 120;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_resendSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _enteredCode {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شماره موبایل باید 11 رقم باشد'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.sendVerificationCode(phone);

    setState(() => _isLoading = false);

    if (result['success'] == true && mounted) {
      setState(() => _codeSent = true);
      _startResendTimer();
      // فوکوس روی اولین فیلد کد
      _codeFocusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تایید ارسال شد'), backgroundColor: Colors.green),
      );
      // در حالت توسعه کد رو نشون بده
      if (result['code'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('کد تایید: ${result['code']}'), duration: const Duration(seconds: 5)),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'خطا در ارسال کد'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyAndLogin() async {
    final code = _enteredCode;
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد 4 رقمی را کامل وارد کنید'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.verifyCode(_phoneController.text, code);

    if (result['success'] == true && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'کد وارد شده اشتباه است'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    // اگه همه پر شدن، خودکار verify کن
    if (_enteredCode.length == 4) {
      _verifyAndLogin();
    }
  }

  void _editPhone() {
    setState(() {
      _codeSent = false;
      for (var c in _codeControllers) {
        c.clear();
      }
    });
    _resendTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _codeSent ? _buildVerifyPage() : _buildPhonePage(),
        ),
      ),
    );
  }

  // صفحه اول - وارد کردن شماره موبایل
  Widget _buildPhonePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // دکمه بستن
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 32),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          
          // تصویر گندم / لوگو
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.8),
                  AppTheme.primaryGreen,
                ],
              ),
            ),
            child: Stack(
              children: [
                // پترن پس‌زمینه
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: _WheatPatternPainter(),
                    ),
                  ),
                ),
                // آیکون و متن
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bakery_dining,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'کاریابی نانوایان',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // عنوان
          const Text(
            'ورود به نانوایی',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // توضیحات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'برای دسترسی به فرصت‌های شغلی و امکانات برنامه،\nلطفا شماره موبایل خود را وارد کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // لیبل شماره موبایل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'شماره موبایل',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // فیلد شماره موبایل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: '0912 345 6789',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.phone_android, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // دکمه ارسال کد
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
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
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ارسال کد تایید',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_back, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // متن قوانین
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                children: [
                  const TextSpan(text: 'با ورود به برنامه، '),
                  TextSpan(
                    text: 'قوانین و مقررات',
                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' را می‌پذیرم.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // صفحه دوم - وارد کردن کد تایید
  Widget _buildVerifyPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // عنوان
            const Text(
              'تایید شماره موبایل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // توضیحات
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'کد 4 رقمی ارسال شده به ',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  _phoneController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                Text(
                  ' را وارد کنید.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // دکمه ویرایش شماره
            TextButton(
              onPressed: _editPhone,
              child: Text(
                'ویرایش',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // فیلدهای کد 4 رقمی
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 60,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _codeControllers[index].text.isNotEmpty
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _codeFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => _onCodeChanged(index, value),
                      onTap: () {
                        // انتخاب همه متن
                        _codeControllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _codeControllers[index].text.length,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // تایمر و ارسال مجدد
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // تایمر
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.grey.shade400,
                  ),
                  
                  // دکمه ارسال مجدد
                  GestureDetector(
                    onTap: _resendSeconds == 0 ? _sendCode : null,
                    child: Text(
                      'ارسال مجدد کد',
                      style: TextStyle(
                        fontSize: 14,
                        color: _resendSeconds == 0 ? AppTheme.primaryGreen : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // دکمه ورود
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndLogin,
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
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'ورود به برنامه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// پترن گندم برای پس‌زمینه
class _WheatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // رسم خطوط مورب
    for (var i = -10; i < 20; i++) {
      final startX = i * 30.0;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
