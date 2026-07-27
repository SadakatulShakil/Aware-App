import '../models/service_model.dart';

/// First-open fallback, shown only until the first successful
/// GET /service/list fetch replaces it in Floor.
///
/// Pulled directly from a live GET /service/list response (real ids,
/// titles, icon URLs, and webview url) rather than fabricated - so this
/// fallback carries working artwork/links even before the app has ever
/// reached the network.
class ServiceStaticData {
  ServiceStaticData._();

  static List<ServiceModel> seed({String lang = 'bn'}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    const webviewUrl = 'https://usf.bmd.gov.bd/webview/app/webview/weatheralert';

    ServiceModel item(String id, String title, String iconUrl) => ServiceModel(
          id: id,
          title: title,
          iconUrl: iconUrl,
          url: webviewUrl,
          updatedAt: now,
        );

    return [
      item('1', 'IVR\\nSystem',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAYVEFTDwpO33-LbGAu0xv2NzKZrQQH6UewA&s'),
      item('2', 'DMC\\nPortal', 'https://cdn-icons-png.flaticon.com/512/1357/1357616.png'),
      item('3', 'KIOSK\\nDisplay', 'https://cdn-icons-png.flaticon.com/512/12495/12495636.png'),
      item('4', 'Shelter\\nInformation', 'https://cdn-icons-png.flaticon.com/512/4116/4116065.png'),
      item('5', 'Road\\nInformation', 'https://cdn-icons-png.flaticon.com/512/7891/7891893.png'),
      item('6', 'VMS\\nPortal', 'https://cdn-icons-png.flaticon.com/512/8686/8686419.png'),
      item('7', 'eCRA\\neURA', 'https://cdn-icons-png.flaticon.com/512/3273/3273583.png'),
      item('8', 'Lightning\\nInformation',
          'https://bo.indelec-connect.com/StaticFiles/Upload/cf4637dd-5ce5-4f98-96e3-8e4413b87a9e.png'),
    ];
  }
}
