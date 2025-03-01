import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool isLoading = true;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    await Future.delayed(Duration(milliseconds: 300)); // Delay to reduce UI lag

    final controller = await _createWebViewController();

    if (mounted) {
      setState(() {
        _controller = controller;
        isInitialized = true;
      });
    }
  }

  Future<WebViewController> _createWebViewController() async {
    return WebViewController()
      ..clearCache() // 🔥 Clears cache
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)") // 🔥 Forces desktop-like WebView behavior
      ..loadRequest(
        Uri.parse("https://myaccount.uscis.gov/sign-in"),
        headers: {
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            offstage: !isInitialized, // Load in background first
            child: isInitialized ? WebViewWidget(controller: _controller!) : SizedBox(),
          ),
          if (isLoading || !isInitialized)
            Center(child: CircularProgressIndicator()), // Show loading until WebView is ready
        ],
      ),
    );
  }
}
