import 'package:aware/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';
import '../data/repositories/incident_report_repository.dart';
import '../widgets/incident_report_card.dart';

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  late final IncidentReportRepository _repo = IncidentReportRepository(Get.find<ApiClient>());
  late Future<List<IncidentReportModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchAllReports();
  }

  Future<void> _refresh() async {
    setState(() => _future = _repo.fetchAllReports());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'ঘটনার তালিকা' : 'Incident Report',
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<IncidentReportModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _messageView(
                c,
                icon: Icons.error_outline,
                text: isBangla
                    ? 'তথ্য লোড করা যায়নি। আবার চেষ্টা করুন।'
                    : 'Could not load data. Please try again.',
              );
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return _messageView(
                c,
                icon: Icons.inbox_outlined,
                text: isBangla ? 'কোনো তথ্য পাওয়া যায়নি' : 'No data found',
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.w,
                16.w,
                16.w + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: reports.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final incident = reports[index];
                return IncidentReportCard(
                  report: incident,
                  c: c,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.incidentReportDetails, arguments: incident);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _messageView(AppThemeColors c, {required IconData icon, required String text}) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 40.sp, color: c.textSecondary),
                  SizedBox(height: 12.h),
                  Text(text, textAlign: TextAlign.center, style: AppTextStyles.body(c.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
