import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';

class IncidentReportCard extends StatelessWidget {
  final IncidentReportModel report;
  final AppThemeColors c;
  final VoidCallback? onTap;
  final bool truncateDescription;

  const IncidentReportCard({
    super.key,
    required this.report,
    required this.c,
    this.onTap,
    this.truncateDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = Get.find<UserPrefService>().isBangla;
    final card = Container(
      decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16.r)),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Text(report.name, style: AppTextStyles.title(c.textPrimary)),
                    Text(report.hazardType, style: AppTextStyles.caption(c.textSecondary)),
                    Text(report.location,
                        style: AppTextStyles.body(c.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _StatChip(
                label: isBangla ? 'মৃত্যু' : 'Death',
                value: report.deathCount,
                color: c.severityExtreme,
              ),
              SizedBox(width: 8.w),
              _StatChip(
                label: isBangla ? 'আহত' : 'Injured',
                value: report.injuredCount,
                color: c.severityModerate,
              ),
              SizedBox(width: 8.w),
              _StatChip(
                label: isBangla ? 'ক্ষতি' : 'Damage',
                value: report.structuralDamage,
                color: c.severityHeavy,
              ),
            ],
          ),
          if (_decodedImage != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(_decodedImage!, height: 140.h, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          SizedBox(height: 12.h),
          Text(isBangla ? 'বিবরণ' : 'Description', style: AppTextStyles.title(c.textPrimary)),
          SizedBox(height: 4.h),
          truncateDescription
              ? _TruncatedDescription(
                  text: report.description,
                  style: AppTextStyles.body(c.textSecondary),
                  isBangla: isBangla,
                )
              : Text(report.description, style: AppTextStyles.body(c.textSecondary)),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }

  Uint8List? get _decodedImage {
    if (report.imageBase64.isEmpty) return null;
    try {
      return base64Decode(report.imageBase64);
    } catch (_) {
      return null;
    }
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.sp),
      ),
    );
  }
}

class _TruncatedDescription extends StatelessWidget {
  const _TruncatedDescription({required this.text, required this.style, required this.isBangla});

  final String text;
  final TextStyle style;
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxLines = 2;
        final maxWidth = constraints.maxWidth;

        final fullPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth);

        if (!fullPainter.didExceedMaxLines) {
          return Text(text, style: style);
        }

        final seeMoreText = isBangla ? 'আরও দেখুন' : 'See more';
        final suffixSpan = TextSpan(
          text: '    $seeMoreText',
          style: style.copyWith(color: Colors.blue, fontWeight: FontWeight.w600),
        );

        int low = 0;
        int high = text.length;
        String bestTruncated = '';

        while (low <= high) {
          final mid = (low + high) ~/ 2;
          final candidate = text.substring(0, mid).trimRight();

          final testPainter = TextPainter(
            text: TextSpan(style: style, children: [TextSpan(text: candidate), suffixSpan]),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          if (testPainter.didExceedMaxLines) {
            high = mid - 1;
          } else {
            bestTruncated = candidate;
            low = mid + 1;
          }
        }

        return RichText(
          maxLines: maxLines,
          overflow: TextOverflow.clip,
          text: TextSpan(style: style, children: [TextSpan(text: bestTruncated), suffixSpan]),
        );
      },
    );
  }
}
