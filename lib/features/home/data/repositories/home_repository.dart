import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/alert_model.dart';
import '../models/notification_model.dart';

/// Alerts are sourced from BMD's notification/list API (ported 1:1) and
/// mapped into AWARE's AlertModel so AlertCarousel's design stays unchanged.
class HomeRepository {
  final ApiClient _api;

  HomeRepository(this._api);

  Future<List<AlertModel>> getAlerts({required String lang}) async {
    final json = await _api.get(
      ApiEndpoints.bmdNotificationList,
      headers: {'Accept-Language': lang},
    );
    final model = NotificationModel.fromJson(json);
    final items = model.result?.notification ?? [];
    return items.where((n) => n.isActive).map(_toAlert).toList();
  }

  AlertModel _toAlert(NotificationItem n) {
    final title = n.title ?? '';
    return AlertModel(
      id: n.id ?? '',
      title: title,
      // The API only exposes a single title field - no separate body text.
      message: title,
      severity: 'normal', // API has no severity field.
      updatedAt: DateTime.tryParse(n.updatedAt ?? n.createdAt ?? '') ?? DateTime.now(),
    );
  }
}
