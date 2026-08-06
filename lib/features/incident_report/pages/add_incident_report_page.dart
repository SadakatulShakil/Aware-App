import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/nsfw_check_service.dart';
import '../../../core/services/user_pref_service.dart';
import '../../../core/utils/image_compress_util.dart';
import '../../drawer/data/models/static_hazard/hazard_safety_data.dart';
import '../data/models/incident_report_model.dart';
import '../data/repositories/incident_report_repository.dart';

enum _ImageStage { idle, checking, compressing, ready, flagged }

class AddIncidentReportPage extends StatefulWidget {
  const AddIncidentReportPage({super.key});

  @override
  State<AddIncidentReportPage> createState() => _AddIncidentReportPageState();
}

class _AddIncidentReportPageState extends State<AddIncidentReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deathController = TextEditingController(text: '0');
  final _injuredController = TextEditingController(text: '0');
  final _structuralController = TextEditingController(text: '0');

  String _hazardKey = HazardSafetyData.all.first.hazardKey;

  _ImageStage _imageStage = _ImageStage.idle;
  Uint8List? _previewBytes;
  Uint8List? _compressedBytes;
  bool _imageCheckSkipped = false;
  bool _isSubmitting = false;

  bool get _isBangla => Get.find<UserPrefService>().isBangla;

  @override
  void initState() {
    super.initState();
    final userService = Get.find<UserPrefService>();
    _locationController.text = userService.locationName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _deathController.dispose();
    _injuredController.dispose();
    _structuralController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 95);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _previewBytes = bytes;
      _compressedBytes = null;
      _imageCheckSkipped = false;
      _imageStage = _ImageStage.checking;
    });

    final nsfwResult = await NsfwCheckService.instance.checkBytes(bytes);
    if (!mounted) return;

    if (nsfwResult.ran && !nsfwResult.isSafe) {
      setState(() => _imageStage = _ImageStage.flagged);
      return;
    }

    setState(() => _imageStage = _ImageStage.compressing);
    final compressed = await compressImageUnderLimit(bytes);
    if (!mounted) return;
    setState(() {
      _compressedBytes = compressed;
      _imageCheckSkipped = !nsfwResult.ran;
      _imageStage = _ImageStage.ready;
    });
  }

  void _removeImage() {
    setState(() {
      _previewBytes = null;
      _compressedBytes = null;
      _imageCheckSkipped = false;
      _imageStage = _ImageStage.idle;
    });
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      _imageStage != _ImageStage.checking &&
      _imageStage != _ImageStage.compressing &&
      _imageStage != _ImageStage.flagged;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    try {
      final userService = Get.find<UserPrefService>();
      final hazard = HazardSafetyData.all.firstWhere((h) => h.hazardKey == _hazardKey);
      final deviceId = await userService.getOrCreateDeviceId();

      final report = IncidentReportModel(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        hazardType: hazard.titleEn,
        location: _locationController.text.trim(),
        deathCount: int.tryParse(_deathController.text.trim()) ?? 0,
        injuredCount: int.tryParse(_injuredController.text.trim()) ?? 0,
        structuralDamage: int.tryParse(_structuralController.text.trim()) ?? 0,
        imageBase64: _compressedBytes != null ? base64Encode(_compressedBytes!) : '',
        description: _descriptionController.text.trim(),
        lat: userService.lat ?? '',
        lon: userService.lon ?? '',
        deviceId: deviceId,
      );

      final repo = IncidentReportRepository(Get.find<ApiClient>());
      await repo.createReport(report);

      if (!mounted) return;
      Get.offNamed(AppRoutes.incidentReportSuccess, arguments: report);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBangla
              ? 'জমা দেওয়া যায়নি। আবার চেষ্টা করুন।'
              : 'Could not submit. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = _isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'ঘটনা রিপোর্ট' : 'Incident Report',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(isBangla ? 'আপনার নাম' : 'Your Name', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            _textField(
              c,
              controller: _nameController,
              hint: isBangla ? 'যেমন: মোঃ করিম' : 'e.g. Md. Karim',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isBangla ? 'নাম লিখুন' : 'Enter your name')
                  : null,
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'মোবাইল নম্বর' : 'Mobile Number', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            _textField(
              c,
              controller: _mobileController,
              hint: '01XXXXXXXXX',
              keyboardType: TextInputType.phone,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) {
                  return isBangla ? 'মোবাইল নম্বর লিখুন' : 'Enter your mobile number';
                }
                if (!RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
                  return isBangla ? 'সঠিক মোবাইল নম্বর দিন' : 'Enter a valid mobile number';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'দুর্যোগের ধরন' : 'Hazard Type', style: AppTextStyles.title(c.textPrimary)),
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
                            child: Text(isBangla ? h.titleBn : h.titleEn,
                                style: AppTextStyles.body(c.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _hazardKey = v!),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'অবস্থান' : 'Location', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            _textField(
              c,
              controller: _locationController,
              hint: isBangla ? 'যেমন: উপজেলা, জেলা' : 'e.g. Upazila, District',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? (isBangla ? 'অবস্থান লিখুন' : 'Enter a location') : null,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _counterField(c,
                      label: isBangla ? 'মৃত্যু' : 'Deaths', controller: _deathController),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _counterField(c,
                      label: isBangla ? 'আহত' : 'Injured', controller: _injuredController),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _counterField(
              c,
              label: isBangla ? 'কাঠামোগত ক্ষতি (সংখ্যা)' : 'Structural Damage (count)',
              controller: _structuralController,
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'বিবরণ' : 'Description', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            _textField(
              c,
              controller: _descriptionController,
              hint: isBangla ? 'ঘটনার বিস্তারিত বিবরণ দিন' : 'Describe what happened',
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isBangla ? 'বিবরণ লিখুন' : 'Enter a description')
                  : null,
            ),
            SizedBox(height: 16.h),
            Text(isBangla ? 'ছবি (ঐচ্ছিক)' : 'Photo (optional)', style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
            _buildImageSection(c, isBangla),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(strokeWidth: 2.w, color: c.textOnPrimary),
                      )
                    : Text(isBangla ? 'জমা দিন' : 'Submit', style: AppTextStyles.title(c.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    AppThemeColors c, {
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body(c.textPrimary),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: c.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }

  Widget _counterField(
    AppThemeColors c, {
    required String label,
    required TextEditingController controller,
  }) {
    final isBangla = _isBangla;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.title(c.textPrimary)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: AppTextStyles.body(c.textPrimary),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.cardBg,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            return int.tryParse(v.trim()) == null ? (isBangla ? 'শুধু সংখ্যা' : 'Numbers only') : null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection(AppThemeColors c, bool isBangla) {
    if (_imageStage == _ImageStage.idle) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(isBangla ? 'ক্যামেরা' : 'Camera'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(isBangla ? 'গ্যালারি' : 'Gallery'),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.memory(_previewBytes!, width: 64.w, height: 64.w, fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _imageStatus(c, isBangla)),
          IconButton(
            onPressed: _removeImage,
            icon: Icon(Icons.close, color: c.textSecondary, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _imageStatus(AppThemeColors c, bool isBangla) {
    switch (_imageStage) {
      case _ImageStage.checking:
        return _statusRow(
          child: SizedBox(width: 16.w, height: 16.w, child: CircularProgressIndicator(strokeWidth: 2.w)),
          text: isBangla
              ? 'ছবিতে অনুপযুক্ত/বিভ্রান্তিকর কনটেন্ট আছে কিনা পরীক্ষা করা হচ্ছে...'
              : 'Checking image for inappropriate or misleading content...',
          textColor: c.textSecondary,
        );
      case _ImageStage.compressing:
        return _statusRow(
          child: SizedBox(width: 16.w, height: 16.w, child: CircularProgressIndicator(strokeWidth: 2.w)),
          text: isBangla ? 'ছবি প্রস্তুত করা হচ্ছে...' : 'Preparing image...',
          textColor: c.textSecondary,
        );
      case _ImageStage.flagged:
        return _statusRow(
          child: Icon(Icons.report_gmailerrorred, color: c.severityExtreme, size: 18.sp),
          text: isBangla
              ? 'এই ছবিতে অনুপযুক্ত/বিভ্রান্তিকর কনটেন্ট শনাক্ত হয়েছে। অনুগ্রহ করে অন্য ছবি বেছে নিন।'
              : 'This image was flagged as inappropriate or misleading. Please choose a different photo.',
          textColor: c.severityExtreme,
        );
      case _ImageStage.ready:
        if (_imageCheckSkipped) {
          return _statusRow(
            child: Icon(Icons.info_outline, color: c.severityModerate, size: 18.sp),
            text: isBangla
                ? 'স্বয়ংক্রিয় পরীক্ষা এই মুহূর্তে করা যায়নি, ছবি অনুমোদিত হয়েছে।'
                : 'Automatic content check was unavailable - image allowed.',
            textColor: c.textSecondary,
          );
        }
        return _statusRow(
          child: Icon(Icons.verified_outlined, color: c.secondary, size: 18.sp),
          text: isBangla ? 'ছবি যাচাই করা হয়েছে - নিরাপদ কনটেন্ট।' : 'Verified - safe content.',
          textColor: c.textSecondary,
        );
      case _ImageStage.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _statusRow({required Widget child, required String text, required Color textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: AppTextStyles.caption(textColor))),
      ],
    );
  }
}
