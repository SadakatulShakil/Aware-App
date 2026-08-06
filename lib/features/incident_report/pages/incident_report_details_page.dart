import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';
import '../widgets/incident_report_card.dart';

class IncidentReportDetailsPage extends StatelessWidget {
  final IncidentReportModel incident;

  const IncidentReportDetailsPage({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'ঘটনা বিস্তারিত' : 'Incident Details',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: IncidentReportCard(report: incident, c: c, truncateDescription: false),
      ),
    );
  }
}
