import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';
import '../data/repositories/incident_report_repository.dart';

class IncidentReportCard extends StatelessWidget {
  final IncidentReportModel report;
  final AppThemeColors c;
  final VoidCallback? onTap;
  final bool truncateDescription;
  final bool showReportActions;

  const IncidentReportCard({
    super.key,
    required this.report,
    required this.c,
    this.onTap,
    this.truncateDescription = true,
    this.showReportActions = false,
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
          if (showReportActions) ...[
            SizedBox(height: 12.h),
            _ReportVoteRow(report: report, c: c, isBangla: isBangla),
          ],
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

enum _Vote { none, real, fake }

/// Social-media-style confirm/fake-report counter. Tapping a side casts (or,
/// tapping the same side again, withdraws) a vote; the two sides are
/// mutually exclusive. Counts update immediately and are synced with a
/// demo API call - swap [IncidentReportRepository.voteOnReport]'s endpoint
/// once the real one is ready.
class _ReportVoteRow extends StatefulWidget {
  const _ReportVoteRow({required this.report, required this.c, required this.isBangla});

  final IncidentReportModel report;
  final AppThemeColors c;
  final bool isBangla;

  @override
  State<_ReportVoteRow> createState() => _ReportVoteRowState();
}

class _ReportVoteRowState extends State<_ReportVoteRow> {
  late int _realCount;
  late int _fakeCount;
  _Vote _vote = _Vote.none;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _realCount = int.tryParse(widget.report.reportReal) ?? 0;
    _fakeCount = int.tryParse(widget.report.reportFake) ?? 0;
  }

  Future<void> _castVote(_Vote target) async {
    if (_sending || widget.report.id == null) return;

    final previousVote = _vote;
    final previousReal = _realCount;
    final previousFake = _fakeCount;
    final nextVote = _vote == target ? _Vote.none : target;

    setState(() {
      if (_vote == _Vote.real) _realCount--;
      if (_vote == _Vote.fake) _fakeCount--;
      if (nextVote == _Vote.real) _realCount++;
      if (nextVote == _Vote.fake) _fakeCount++;
      _vote = nextVote;
      _sending = true;
    });

    try {
      // No backend endpoint to withdraw a vote - a toggle-off only updates local state.
      if (nextVote != _Vote.none) {
        final repo = IncidentReportRepository(Get.find<ApiClient>());
        await (nextVote == _Vote.real
            ? repo.confirmReportReal(widget.report.id!)
            : repo.confirmReportFake(widget.report.id!));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _vote = previousVote;
          _realCount = previousReal;
          _fakeCount = previousFake;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isBangla
                ? 'ইন্টারনেট সংযোগ পরীক্ষা করুন'
                : 'Please check your internet connection'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _VoteButton(
          icon: Icons.check_circle_outline,
          label: widget.isBangla ? 'নিশ্চিত' : 'Confirm',
          count: _realCount,
          selectedColor: widget.c.primary,
          unselectedColor: widget.c.textSecondary,
          selected: _vote == _Vote.real,
          onTap: () => _castVote(_Vote.real),
        ),
        SizedBox(width: 16.w),
        _VoteButton(
          icon: Icons.flag_outlined,
          label: widget.isBangla ? 'ফেক রিপোর্ট' : 'Fake Report',
          count: _fakeCount,
          selectedColor: widget.c.severityExtreme,
          unselectedColor: widget.c.textSecondary,
          selected: _vote == _Vote.fake,
          onTap: () => _castVote(_Vote.fake),
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color selectedColor;
  final Color unselectedColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            '$label ($count)',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
        ],
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
