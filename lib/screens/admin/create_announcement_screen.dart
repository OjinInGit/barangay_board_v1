import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../l10n/app_strings.dart';
import '../../models/announcement.dart';
import '../../models/announcement_type.dart';
import '../../services/firestore_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key, this.existing});

  final AnnouncementModel? existing;

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late AnnouncementType _type;
  final _customTagCtrl = TextEditingController();
  late final QuillController _quill;
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();
  bool _saving = false;

  FirestoreService get _fs =>
      FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? AnnouncementType.publicNotice;
    _customTagCtrl.text = widget.existing?.customTag ?? '';
    try {
      final decoded = jsonDecode(widget.existing?.body ?? '');
      if (decoded is List) {
        _quill = QuillController(
          document: Document.fromJson(
            List<Map<String, dynamic>>.from(
              decoded.map((e) => Map<String, dynamic>.from(e as Map)),
            ),
          ),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        _quill = QuillController.basic();
      }
    } catch (_) {
      _quill = QuillController.basic();
      if (widget.existing?.body.isNotEmpty == true) {
        _quill.document.insert(0, widget.existing!.body);
      }
    }
  }

  @override
  void dispose() {
    _customTagCtrl.dispose();
    _quill.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppStrings.of(context);
    if (_type == AnnouncementType.customTag &&
        _customTagCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.customTagRequired)),
      );
      return;
    }
    final plain = _quill.document.toPlainText().trim();
    if (plain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fieldRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final body = jsonEncode(_quill.document.toDelta().toJson());
      final model = AnnouncementModel(
        id: widget.existing?.id ?? '',
        type: _type,
        body: body,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        customTag: _type == AnnouncementType.customTag
            ? _customTagCtrl.text.trim()
            : null,
      );

      if (widget.existing == null) {
        await _fs.createAnnouncement(model);
      } else {
        await _fs.updateAnnouncement(model);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.genericError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final editing = widget.existing != null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(editing ? s.edit : s.makeAnnouncement),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.publish),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              s.announcementType,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: AnnouncementType.bySeverity().map((t) {
                final selected = _type == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    avatar: Icon(t.icon, size: 18),
                    label: Text(t.label(s)),
                    onSelected: (_) => setState(() => _type = t),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_type == AnnouncementType.customTag)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _customTagCtrl,
                decoration: InputDecoration(hintText: s.customTagHint),
              ),
            ),
          const Divider(height: 1),
          _BoundedQuillToolbar(controller: _quill),
          Expanded(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _quill,
                config: const QuillEditorConfig(
                  expands: true,
                  scrollable: true,
                  autoFocus: false,
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoundedQuillToolbar extends StatelessWidget {
  const _BoundedQuillToolbar({required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: kDefaultToolbarSize,
        child: QuillSimpleToolbar(
          controller: controller,
          config: const QuillSimpleToolbarConfig(multiRowsDisplay: false),
        ),
      ),
    );
  }
}
