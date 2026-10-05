// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PdfEmbedView extends StatefulWidget {
  final String url;
  const PdfEmbedView({super.key, required this.url});

  @override
  State<PdfEmbedView> createState() => _PdfEmbedViewState();
}

class _PdfEmbedViewState extends State<PdfEmbedView> {
  static final Set<String> _registeredTypes = <String>{};
  late String _viewType;

  @override
  void initState() {
    super.initState();
    _registerIFrame();
  }

  @override
  void didUpdateWidget(covariant PdfEmbedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        _registerIFrame();
      });
    }
  }

  void _registerIFrame() {
    final rawUrl = widget.url;
    final String targetUrl = rawUrl.contains('#') ? rawUrl : '$rawUrl#navpanes=0&view=FitH&toolbar=1';
    _viewType = 'pdf-viewer-${targetUrl.hashCode}';
    if (!_registeredTypes.contains(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = targetUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'block'
            ..setAttribute('type', 'application/pdf')
            ..setAttribute('allow', 'fullscreen');
          return iframe;
        },
      );
      _registeredTypes.add(_viewType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: ValueKey(_viewType),
      viewType: _viewType,
    );
  }
}
