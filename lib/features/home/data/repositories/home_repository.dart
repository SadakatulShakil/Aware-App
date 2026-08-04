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

  /// DDM's notification list API
  Future<List<NotificationModel>> getNotifications() async {
    final json = await _api.get(ApiEndpoints.notificationList);
    final response = NotificationListResponse.fromJson(json);
    final items = response.result?.notification ?? [];
    return items.where((n) => n.isActive).map(_toNotification).toList();
  }

  /// DDM's bulletin API
  Future<List<OngoingBulletinModel>> getOngoingBulletins() async {
    final json = await _api.get(ApiEndpoints.alertOngoing);
    return OngoingBulletinModel.listFromJson(json);
  }

  /// DDM's alert current API
  Future<List<AlertItemModel>> getAlerts() async {

    final json = await _api.get(ApiEndpoints.alerts);
    return AlertItemModel.listFromJson(json['result']);
  }

  /// DDM's NotificationItem .
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
