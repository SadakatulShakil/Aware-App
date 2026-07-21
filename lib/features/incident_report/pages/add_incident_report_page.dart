import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../drawer/data/models/static_hazard/hazard_safety_data.dart';

class AddIncidentReportPage extends StatefulWidget {
  const AddIncidentReportPage({super.key});

  @override
  State<AddIncidentReportPage> createState() => _AddIncidentReportPageState();
}

class _AddIncidentReportPageState extends State<AddIncidentReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _hazardKey = HazardSafetyData.all.first.hazardKey;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('রিপোর্ট সংরক্ষণ করা হয়েছে। শীঘ্রই এটি পর্যালোচনা করা হবে। '
            '/ Report saved. It will be reviewed soon.'),
      ),
    );
    _formKey.currentState!.reset();
    _locationController.clear();
    _descriptionController.clear();
    setState(() => _hazardKey = HazardSafetyData.all.first.hazardKey);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title:
            Text('ঘটনা রিপোর্ট / Incident Report', style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text('দুর্যোগের ধরন / Hazard Type', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(12.r)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _hazardKey,
                  isExpanded: true,
                  items: HazardSafetyData.all
                      .map((h) => DropdownMenuItem(
                            value: h.hazardKey,
                            child: Text('${h.titleBn} / ${h.titleEn}',
                                style: AppTextStyles.body(c.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _hazardKey = v!),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('অবস্থান / Location', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _locationController,
              style: AppTextStyles.body(c.textPrimary),
              decoration: InputDecoration(
                hintText: 'যেমন: উপজেলা, জেলা / e.g. Upazila, District',
                filled: true,
                fillColor: c.cardBg,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'অবস্থান লিখুন / Enter a location' : null,
            ),
            SizedBox(height: 16.h),
            Text('বিবরণ / Description', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _descriptionController,
              style: AppTextStyles.body(c.textPrimary),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'ঘটনার বিস্তারিত বিবরণ দিন / Describe what happened',
                filled: true,
                fillColor: c.cardBg,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'বিবরণ লিখুন / Enter a description' : null,
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
                child: Text('জমা দিন / Submit',
                    style: AppTextStyles.title(c.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
