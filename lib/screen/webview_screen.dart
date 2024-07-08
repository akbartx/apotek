import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

    controller
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          setState(() {
            isLoading = false;
          });
        },
        onNavigationRequest: (request) async {
          if (request.url.contains('app/v1/api/midtrans_payment_process')) {
            setState(() {
              isLoading = true;
            });

            String responseUrl = request.url;

            if (responseUrl.contains('Failed') ||
                responseUrl.contains('failed')) {
              setState(() {
                isLoading = false;
              });
            } else if (responseUrl.contains('capture') ||
                responseUrl.contains('completed') ||
                responseUrl.toLowerCase().contains('success')) {
              // Handle successful payment
            }

            Navigator.of(context).pop();

            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));

    _controller = controller; // Assign the controller after initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(),
        ],
      ),
    );
  }
}
