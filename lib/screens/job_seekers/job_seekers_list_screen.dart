import 'package:flutter/material.dart';
import '../../models/job_seeker.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/add_menu_fab.dart';
import '../../widgets/empty_state_widget.dart';
import 'job_seeker_detail_screen.dart';

class JobSeekersListScreen extends StatefulWidget {
  const JobSeekersListScreen({super.key});

  @override
  State<JobSeekersListScreen> createState() => _JobSeekersListScreenState();
}

class _JobSeekersListScreenState extends State<JobSeekersListScreen> {
  String? _selectedProvince;
  RangeValues? _priceRange;

  final List<JobSeeker> _sampleSeekers = [
    JobSeeker(
      id: '1',
      name: 'علی محمدی',
      skills: ['شاطر بربری'],
      location: 'تهران',
      expectedSalary: 8000000,
    ),
    JobSeeker(
      id: '2',
      name: 'حسین احمدی',
      skills: ['خمیرگیر بربری', 'چونه گیر بربری'],
      location: 'کرج',
      expectedSalary: 7500000,
    ),
    JobSeeker(
      id: '3',
      name: 'رضا کریمی',
      skills: ['شاطر لواش'],
      location: 'اصفهان',
      expectedSalary: 9000000,
    ),
    JobSeeker(
      id: '4',
      name: 'مهدی رضایی',
      skills: ['خمیرگیر لواش'],
      location: 'مشهد',
      expectedSalary: 6000000,
    ),
    JobSeeker(
      id: '5',
      name: 'امیر حسینی',
      skills: ['شاطر بربری', 'شاطر لواش'],
      location: 'شیراز',
      expectedSalary: 10000000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          title: const Text('جویندگان کار'),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => FilterBottomSheet(
                    selectedProvince: _selectedProvince,
                    priceRange: _priceRange,
                    onApply: (province, priceRange) {
                      setState(() {
                        _selectedProvince = province;
                        _priceRange = priceRange;
                      });
                    },
                  ),
                );
              },
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list),
                  if (_selectedProvince != null || _priceRange != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: _sampleSeekers.isEmpty
            ? EmptyStateWidget(
                icon: Icons.person_search_outlined,
                title: 'هیچ کارجویی یافت نشد',
                message:
                    'در حال حاضر کارجویی ثبت نشده است.\nپروفایل خود را ثبت کنید!',
                buttonText: 'ثبت پروفایل کارجو',
                onButtonPressed: () {},
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _sampleSeekers.length,
                itemBuilder: (context, index) {
                  final seeker = _sampleSeekers[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobSeekerDetailScreen(seeker: seeker),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppTheme.primaryGreen,
                                    backgroundImage: seeker.profileImage != null
                                        ? NetworkImage(seeker.profileImage!)
                                        : null,
                                    child: seeker.profileImage == null
                                        ? Text(
                                            seeker.name.isNotEmpty
                                                ? seeker.name[0]
                                                : '?',
                                            style: TextStyle(
                                              color: AppTheme.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          seeker.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${seeker.rating}',
                                              style: TextStyle(
                                                color: AppTheme.textGrey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppTheme.textGrey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: seeker.skills
                                    .map((skill) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF42A5F5),
                                                Color(0xFF64B5F6),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF42A5F5)
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            skill,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppTheme.textGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    seeker.location,
                                    style: TextStyle(
                                      color: AppTheme.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: AppTheme.textGrey,
                                            fontSize: 14,
                                            fontFamily: 'Vazir',
                                          ),
                                          children: [
                                            const TextSpan(
                                                text: 'حقوق هفتگی درخواستی: '),
                                            TextSpan(
                                              text: NumberFormatter.formatPrice(
                                                  seeker.expectedSalary),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: const AddMenuFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
