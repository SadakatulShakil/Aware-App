import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/user_pref_service.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sectionsEn = <(String, String)>[
    (
      'Information We Collect',
      'We collect your device location (with permission) to show weather forecasts and hazard '
          'alerts for your area, along with basic device information to keep notifications working '
          'reliably.',
    ),
    (
      'How We Use Your Information',
      'Location and device data are used only to personalize weather forecasts, disaster alerts, '
          'and emergency service information shown inside the app.',
    ),
    (
      'Data Sharing',
      'We do not sell or share your personal data with third parties. Aggregated, non-identifying '
          'data may be used to improve alert accuracy for the public.',
    ),
    (
      'Data Security',
      'Reasonable technical safeguards are used to protect data stored on your device and in '
          'transit to our servers.',
    ),
    (
      'Your Rights',
      'You can revoke location permission at any time from your device settings, or disable '
          'notifications from the app\'s notification settings.',
    ),
  ];

  static const _sectionsBn = <(String, String)>[
    (
      'আমরা যে তথ্য সংগ্রহ করি',
      'আপনার এলাকার আবহাওয়ার পূর্বাভাস ও দুর্যোগ সতর্কতা দেখানোর জন্য অনুমতি সাপেক্ষে আমরা আপনার ডিভাইসের '
          'অবস্থান সংগ্রহ করি, পাশাপাশি নোটিফিকেশন সঠিকভাবে কাজ করার জন্য মৌলিক ডিভাইস তথ্য সংগ্রহ করি।',
    ),
    (
      'আমরা কীভাবে আপনার তথ্য ব্যবহার করি',
      'অবস্থান ও ডিভাইস তথ্য শুধুমাত্র অ্যাপে দেখানো আবহাওয়ার পূর্বাভাস, দুর্যোগ সতর্কতা এবং জরুরি সেবার তথ্য '
          'ব্যক্তিগতকরণের জন্য ব্যবহার করা হয়।',
    ),
    (
      'তথ্য শেয়ারিং',
      'আমরা আপনার ব্যক্তিগত তথ্য তৃতীয় পক্ষের কাছে বিক্রি বা শেয়ার করি না। জনস্বার্থে সতর্কতার নির্ভুলতা '
          'বাড়াতে অ-শনাক্তযোগ্য সমষ্টিগত তথ্য ব্যবহার করা হতে পারে।',
    ),
    (
      'তথ্য সুরক্ষা',
      'আপনার ডিভাইসে সংরক্ষিত এবং আমাদের সার্ভারে প্রেরিত তথ্য সুরক্ষিত রাখতে যুক্তিসঙ্গত প্রযুক্তিগত ব্যবস্থা '
          'নেওয়া হয়।',
    ),
    (
      'আপনার অধিকার',
      'আপনি যেকোনো সময় ডিভাইস সেটিংস থেকে অবস্থান অনুমতি প্রত্যাহার করতে পারেন, অথবা অ্যাপের নোটিফিকেশন '
          'সেটিংস থেকে বিজ্ঞপ্তি বন্ধ করতে পারেন।',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;
    final sections = isBangla ? _sectionsBn : _sectionsEn;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('গোপনীয়তা নীতি / Privacy Policy',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            isBangla
                ? 'সর্বশেষ হালনাগাদ: জুলাই ২০২৬'
                : 'Last updated: July 2026',
            style: AppTextStyles.caption(c.textSecondary),
          ),
          SizedBox(height: 12.h),
          Text(
            isBangla
                ? 'AWARE অ্যাপ ব্যবহার করে আপনি এই গোপনীয়তা নীতিতে বর্ণিত তথ্য সংগ্রহ ও ব্যবহারের '
                    'সাথে সম্মত হচ্ছেন।'
                : 'By using the AWARE app, you agree to the collection and use of information as '
                    'described in this privacy policy.',
            style: AppTextStyles.body(c.textPrimary),
          ),
          SizedBox(height: 16.h),
          ...sections.map((section) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration:
                    BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16.r)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.$1, style: AppTextStyles.title(c.textPrimary)),
                    SizedBox(height: 6.h),
                    Text(section.$2, style: AppTextStyles.body(c.textSecondary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
