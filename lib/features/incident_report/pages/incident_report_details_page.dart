import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../data/models/icident_data_model.dart';

class IncidentReportDetailsPage extends StatelessWidget {
  final IncidentDataModel incident;

  const IncidentReportDetailsPage({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('ঘটনা বিস্তারিত / Incident Details',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + location
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: c.primary.withOpacity(0.15),
                  child: Icon(Icons.person_outline_sharp, color: c.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.userName, style: AppTextStyles.title(c.textPrimary)),
                      Text(incident.name, style: AppTextStyles.caption(c.textPrimary)),
                      //SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              incident.location,
                              style: AppTextStyles.body(c.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Death / Injured counts
            Row(
              children: [
                _StatChip(
                  label: 'Death',
                  value: incident.deathCount,
                  color: Colors.red,
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  label: 'Injured',
                  value: incident.injuredCount,
                  color: Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Image placeholder — swap for Image.network(incident.imageUrl) later
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 140.h,
                width: double.infinity,
                color: c.scaffoldBg,
                child: incident.imageUrl == null
                    ? Center(
                  child: Icon(Icons.image_outlined, size: 36.sp, color: c.textSecondary),
                )
                    : Image.network(incident.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 12.h),

            // Description
            Text('বিবরণ / Description', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 4.h),
            Text(
              incident.description,
              style: AppTextStyles.body(c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.sp),
      ),
    );
  }
}