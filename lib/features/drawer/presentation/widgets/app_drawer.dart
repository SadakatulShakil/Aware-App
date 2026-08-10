import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../data/models/drawer_item_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    final items = <DrawerItem>[
      const DrawerItem(Icons.info_outline, 'drawer_about', AppRoutes.about),
      const DrawerItem(
        Icons.warning_amber_outlined,
        'drawer_risk_information',
        AppRoutes.hazardDetails,
        arguments: {'url': 'https://rapid.ddm.gov.bd/app/webview/riskinfo'},
      ),
      const DrawerItem(
          Icons.report_outlined, 'drawer_incident_report', AppRoutes.incidentReport),
      const DrawerItem(
          Icons.privacy_tip_outlined, 'drawer_privacy_policy', AppRoutes.privacyPolicy),
      const DrawerItem(Icons.contact_mail_outlined, 'drawer_contact_us', AppRoutes.contactUs),
      const DrawerItem(Icons.feedback_outlined, 'drawer_feedback', AppRoutes.feedback),
    ];

    return Drawer(
      backgroundColor: c.scaffoldBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(c),
            SizedBox(height: 16.h),
            ...items.map((item) => _buildTile(context, c, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors c) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(AssetPaths.logo, width: 50.r, height: 50.r, fit: BoxFit.contain),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AWARE', style: AppTextStyles.sectionTitle(c.textPrimary)),
                SizedBox(height: 2.h),
                Text('aware_full_name'.tr,
                    style: AppTextStyles.caption(c.textPrimary)
                ),
                Text('app_owner'.tr,
                    style: AppTextStyles.caption(c.textPrimary)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, AppThemeColors c, DrawerItem item) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      leading: Icon(item.icon, color: c.primary),
      title: Text(item.labelKey.tr, style: AppTextStyles.body(c.textPrimary)),
      onTap: () {
        Navigator.of(context).pop();
        final args = item.arguments == null
            ? null
            : {...item.arguments!, 'title': item.labelKey.tr};
        Get.toNamed(item.route, arguments: args);
      },
    );
  }
}
