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

class IncidentReportDetailsPage extends StatefulWidget {
  final IncidentReportModel incident;

  const IncidentReportDetailsPage({super.key, required this.incident});

  @override
  State<IncidentReportDetailsPage> createState() => _IncidentReportDetailsPageState();
}

class _IncidentReportDetailsPageState extends State<IncidentReportDetailsPage> {
  late final IncidentReportRepository _repo = IncidentReportRepository(Get.find<ApiClient>());
  late Future<IncidentReportModel> _future;

  @override
  void initState() {
    super.initState();
    final id = widget.incident.id;
    _future = id == null ? Future.value(widget.incident) : _repo.fetchReportById(id);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'ঘটনার বিস্তারিত তথ্য' : 'Incident Details',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<IncidentReportModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            // Fall back to the incident handed in via navigation if the
            // fresh fetch fails (e.g. offline) so the page still renders.
            final incident = snapshot.data ?? widget.incident;
            return IncidentReportCard(
              report: incident,
              c: c,
              truncateDescription: false,
              showReportActions: true,
            );
          },
        ),
      ),
    );
  }
}
