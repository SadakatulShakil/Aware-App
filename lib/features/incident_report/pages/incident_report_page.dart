import 'package:aware/app/routes/app_routes.dart';
import 'package:aware/features/incident_report/data/models/icident_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../data/static_incident_data/incident_data.dart';

class IncidentReportPage extends StatelessWidget {
  const IncidentReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('ঘটনা তালিকা / Incident Report',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addIncidentReport);
              },
              borderRadius: BorderRadius.circular(999.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: c.textOnPrimary, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: demoIncidents.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final incident = demoIncidents[index];
          return _IncidentCard(incident: incident, c: c);
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.c});

  final IncidentDataModel incident;
  final dynamic c; // AppThemeColors instance from parent

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        //Icon(Icons.location_on_outlined, size: 14.sp, color: c.textSecondary),
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
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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