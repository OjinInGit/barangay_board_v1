import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AnnouncementBodyView extends StatefulWidget {
  const AnnouncementBodyView({
    super.key,
    required this.body,
    this.maxHeight,
  });

  final String body;
  final double? maxHeight;

  @override
  State<AnnouncementBodyView> createState() => _AnnouncementBodyViewState();
}

class _AnnouncementBodyViewState extends State<AnnouncementBodyView> {
  QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant AnnouncementBodyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body) {
      _disposeCtrl();
      _attach();
    }
  }

  void _attach() {
    try {
      final decoded = jsonDecode(widget.body);
      if (decoded is List) {
        _controller = QuillController(
          document: Document.fromJson(
            List<Map<String, dynamic>>.from(
              decoded.map((e) => Map<String, dynamic>.from(e as Map)),
            ),
          ),
          selection: const TextSelection.collapsed(offset: 0),
        );
        return;
      }
    } catch (_) {}
    _controller = null;
  }

  void _disposeCtrl() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeCtrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl != null) {
      final editor = IgnorePointer(
        child: QuillEditor.basic(
          controller: ctrl,
          config: QuillEditorConfig(
            scrollable: true,
            expands: false,
            autoFocus: false,
            maxHeight: widget.maxHeight,
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      );
      if (widget.maxHeight != null) {
        return SizedBox(height: widget.maxHeight, child: editor);
      }
      return editor;
    }
    return Text(widget.body, style: Theme.of(context).textTheme.bodyLarge);
  }
}
