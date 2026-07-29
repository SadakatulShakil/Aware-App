import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/alert_item_model.dart';
import '../models/notification_model.dart';
import '../models/notification_response_model.dart';
import '../models/ongoing_bulletin_model.dart';

/// Notifications are sourced from BMD's notification/list API (ported 1:1)
/// and mapped into AWARE's NotificationModel, which feeds the header
/// HeaderNotificationCarousel.
class HomeRepository {
  final ApiClient _api;

  HomeRepository(this._api);

  Future<List<NotificationModel>> getNotifications() async {
    final json = await _api.get(ApiEndpoints.bmdNotificationList);
    final response = NotificationListResponse.fromJson(json);
    final items = response.result?.notification ?? [];
    return items.where((n) => n.isActive).map(_toNotification).toList();
  }

  Future<List<OngoingBulletinModel>> getOngoingBulletins() async {
    final json = await _api.get(ApiEndpoints.alertOngoing);
    return OngoingBulletinModel.listFromJson(json);
  }

  Future<List<AlertItemModel>> getAlerts() async {
    // ===== DEMO DATA - remove once the /alerts API is ready =====
    // Delete this line and the `_demoAlerts` field below, then uncomment
    // the two real-API lines underneath.
    return AlertItemModel.listFromJson(_demoAlerts);
    // ===== END DEMO DATA =====

    // final json = await _api.get(ApiEndpoints.alerts);
    // return AlertItemModel.listFromJson(json['result']);
  }

  // ===== DEMO DATA - remove once the /alerts API is ready =====
  static const _demoAlerts = [
    {'id': '1', 'title': 'Alert1', 'value': '8', 'color': '#E53935'},
    {'id': '2', 'title': 'Alert2', 'value': '3', 'color': '#1E88E5'},
    {'id': '3', 'title': 'Alert3', 'value': '4', 'color': '#43A047'},
    {'id': '4', 'title': 'Alert4', 'value': '3', 'color': '#FB8C00'},
    {'id': '5', 'title': 'Alert5', 'value': '1', 'color': '#8E24AA'},
    {'id': '6', 'title': 'Alert6', 'value': '6', 'color': '#00897B'},
    {'id': '7', 'title': 'Alert7', 'value': '2', 'color': '#C0CA33'},
    {'id': '8', 'title': 'Alert8', 'value': '9', 'color': '#6D4C41'},
  ];
  // ===== END DEMO DATA =====

  NotificationModel _toNotification(NotificationItem n) {
    final title = n.title ?? '';
    return NotificationModel(
      id: n.id ?? '',
      title: title,
      // The API only exposes a single title field - no separate body text.
      message: title,
      severity: 'normal', // API has no severity field.
      updatedAt: DateTime.tryParse(n.updatedAt ?? n.createdAt ?? '') ?? DateTime.now(),
    );
  }
}
