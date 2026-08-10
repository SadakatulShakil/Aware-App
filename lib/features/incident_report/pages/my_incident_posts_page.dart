import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';
import '../data/repositories/incident_report_repository.dart';
import '../widgets/incident_report_card.dart';

class MyIncidentPostsPage extends StatefulWidget {
  final String mobile;

  const MyIncidentPostsPage({super.key, required this.mobile});

  @override
  State<MyIncidentPostsPage> createState() => _MyIncidentPostsPageState();
}

class _MyIncidentPostsPageState extends State<MyIncidentPostsPage> {
  late final IncidentReportRepository _repo = IncidentReportRepository(Get.find<ApiClient>());
  late Future<List<IncidentReportModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchReportsByMobile(widget.mobile);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'আপনার পোস্ট' : 'Your Posts',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<IncidentReportModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      isBangla ? 'পোস্ট লোড করা যায়নি।' : 'Could not load your posts.',
                      style: AppTextStyles.body(c.textSecondary),
                    ),
                  );
                }
                final reports = snapshot.data ?? [];
                if (reports.isEmpty) {
                  return Center(
                    child: Text(
                      isBangla ? 'এখনো কোনো পোস্ট নেই।' : 'No posts yet.',
                      style: AppTextStyles.body(c.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) => IncidentReportCard(report: reports[index], c: c),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.w,
              16.w,
              16.w + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.incidentReport),
                child: Text(
                  isBangla ? 'রিপোর্ট পাতায় ফিরে যান' : 'Back to Report Page',
                  style: AppTextStyles.title(c.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
