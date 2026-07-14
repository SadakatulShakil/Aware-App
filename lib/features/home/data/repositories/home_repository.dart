import '../../../../core/network/api_client.dart';
import '../models/alert_model.dart';

/// Static-first repository. When APIs are ready, swap the body with
/// _api.get(ApiEndpoints.alerts) - controller & UI stay untouched.
class HomeRepository {
  // ignore: unused_field
  final ApiClient _api;

  HomeRepository(this._api);

  Future<List<AlertModel>> getAlerts() async {
    // TODO(API): final json = await _api.get(ApiEndpoints.alerts);
    // return (json['data'] as List).map(AlertModel.fromJson).toList();
    await Future.delayed(const Duration(milliseconds: 300));
    return AlertModel.mockList();
  }
}
