import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/user_pref_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isBangla = Get.find<UserPrefService>().isBangla;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBangla ? 'আপনার মতামতের জন্য ধন্যবাদ।' : 'Thank you for your feedback.'),
      ),
    );
    _formKey.currentState!.reset();
    _messageController.clear();
    setState(() => _rating = 5);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'মতামত' : 'Feedback', style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 16.w + MediaQuery.of(context).padding.bottom),
          children: [
            Text(isBangla ? 'আপনি অ্যাপটি কেমন মনে করেন?' : 'How do you find the app?',
                style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: c.severityModerate,
                    size: 32.r,
                  ),
                );
              }),
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'আপনার মতামত' : 'Your Feedback', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _messageController,
              style: AppTextStyles.body(c.textPrimary),
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isBangla
                    ? 'আপনার পরামর্শ বা সমস্যার কথা লিখুন'
                    : 'Share your suggestion or issue',
                filled: true,
                fillColor: c.cardBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isBangla ? 'মতামত লিখুন' : 'Enter your feedback')
                  : null,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(isBangla ? 'পাঠান' : 'Send', style: AppTextStyles.title(c.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
