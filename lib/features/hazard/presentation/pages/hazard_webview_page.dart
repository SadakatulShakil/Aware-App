import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_theme_colors.dart';

class HazardWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const HazardWebViewPage({super.key, required this.title, required this.url});

  @override
  State<HazardWebViewPage> createState() => _HazardWebViewPageState();
}

class _HazardWebViewPageState extends State<HazardWebViewPage> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress / 100),
          onPageStarted: (_) => setState(() => _hasError = false),
          onPageFinished: (_) => setState(() => _progress = 1),
          onWebResourceError: (_) => setState(() => _hasError = true),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(color: c.textPrimary, fontSize: 17.sp, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48.sp, color: c.textSecondary),
                  SizedBox(height: 12.h),
                  Text('Failed to load page', style: TextStyle(color: c.textSecondary)),
                  SizedBox(height: 16.h),
                  ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_progress < 1)
                  LinearProgressIndicator(value: _progress, color: c.primary),
              ],
            ),
    );
  }
}
