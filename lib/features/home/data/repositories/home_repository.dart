import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/notification_response_model.dart';
import '../models/ongoing_bulletin_model.dart';

/// Notifications are sourced from BMD's notification/list API (ported 1:1)
/// and mapped into AWARE's NotificationModel, which feeds the home
/// NotificationCarousel.
class HomeRepository {
  final ApiClient _api;

  HomeRepository(this._api);

  Future<List<NotificationModel>> getNotifications({required String lang}) async {
    final json = await _api.get(
      ApiEndpoints.bmdNotificationList,
      headers: {'Accept-Language': lang},
    );
    final response = NotificationListResponse.fromJson(json);
    final items = response.result?.notification ?? [];
    return items.where((n) => n.isActive).map(_toNotification).toList();
  }

  Future<List<OngoingBulletinModel>> getOngoingBulletins({required String lang}) async {
    final json = await _api.get(
      ApiEndpoints.alertOngoing,
      headers: {'Accept-Language': lang},
    );
    return OngoingBulletinModel.listFromJson(json);
  }

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
