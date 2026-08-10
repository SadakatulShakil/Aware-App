import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/incident_report_model.dart';

class IncidentReportRepository {
  final ApiClient _api;

  IncidentReportRepository(this._api);

  Future<void> createReport(IncidentReportModel report) async {
    final json = await _api.post(ApiEndpoints.incidentReportCreate, body: report.toJson());
    if (json is Map && json['status'] == false) {
      throw ApiException(json['message']?.toString() ?? 'Failed to submit report');
    }
  }

  /// All reports, newest first. The read endpoint always returns
  /// everything (no server-side filtering or paging).
  Future<List<IncidentReportModel>> fetchAllReports() async {
    final json = await _api.get(ApiEndpoints.incidentReportRead);
    final result = (json is Map ? json['result'] : null) as List<dynamic>? ?? [];
    final reports =
        result.whereType<Map<String, dynamic>>().map(IncidentReportModel.fromJson).toList();
    reports.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return reports;
  }

  /// Matching reports for this mobile number, filtered client-side since
  /// the read endpoint ignores query filters.
  Future<List<IncidentReportModel>> fetchReportsByMobile(String mobile) async {
    final reports = await fetchAllReports();
    return reports.where((r) => r.mobile == mobile).toList();
  }

  /// A single report by id, fetched fresh (e.g. for the details page so it
  /// reflects the latest real/fake vote counts rather than stale list data).
  Future<IncidentReportModel> fetchReportById(String id) async {
    final json = await _api.get(ApiEndpoints.incidentReportReadById(id));
    final result = json is Map ? json['result'] : null;
    Map<String, dynamic>? data;
    if (result is Map<String, dynamic>) {
      data = result;
    } else if (result is List && result.isNotEmpty) {
      data = result.first as Map<String, dynamic>?;
    }
    if (data == null) {
      throw const ApiException('Report not found');
    }
    return IncidentReportModel.fromJson(data);
  }

  /// Marks a report as real (confirmed).
  Future<void> confirmReportReal(String reportId) => _vote(ApiEndpoints.incidentReportReal(reportId));

  /// Flags a report as fake.
  Future<void> confirmReportFake(String reportId) => _vote(ApiEndpoints.incidentReportFake(reportId));

  Future<void> _vote(String url) async {
    final json = await _api.patch(url);
    if (json is Map && json['status'] == false) {
      throw ApiException(json['message']?.toString() ?? 'Failed to submit vote');
    }
  }
}
