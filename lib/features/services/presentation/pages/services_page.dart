import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final services = [
      (Icons.home_work_outlined, 'আশ্রয়কেন্দ্র', 'Shelters'),
      (Icons.volunteer_activism_outlined, 'ত্রাণ কার্যক্রম', 'Relief'),
      (Icons.report_outlined, 'ঘটনা রিপোর্ট', 'Incident Report'),
      (Icons.menu_book_outlined, 'নির্দেশিকা', 'Guidelines'),
      (Icons.newspaper_outlined, 'সংবাদ', 'News'),
      (Icons.photo_library_outlined, 'গ্যালারি', 'Gallery'),
    ];

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('সেবাসমূহ / Services',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.6,
        ),
        itemCount: services.length,
        itemBuilder: (_, i) {
          final s = services[i];
          return Container(
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s.$1, color: c.primary, size: 28.sp),
                SizedBox(height: 8.h),
                Text(s.$2,
                    style: AppTextStyles.title(c.textPrimary)),
                Text(s.$3,
                    style: AppTextStyles.caption(c.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
