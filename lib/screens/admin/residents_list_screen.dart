import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_strings.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class ResidentsListScreen extends StatelessWidget {
  const ResidentsListScreen({super.key});

  static InputDecoration _fieldDecoration(AppStrings s, String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _editDialog(
    BuildContext context,
    FirestoreService fs,
    UserProfile u,
  ) async {
    final s = AppStrings.of(context);
    final first = TextEditingController(text: u.firstName);
    final last = TextEditingController(text: u.lastName);
    final mi = TextEditingController(text: u.middleInitial);
    final suffix = TextEditingController(text: u.suffix);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          title: Text(s.edit),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 320),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: first,
                      decoration: _fieldDecoration(s, s.firstName),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? s.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: last,
                      decoration: _fieldDecoration(s, s.lastName),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? s.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: mi,
                      decoration: _fieldDecoration(s, s.middleInitial),
                      maxLength: 1,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                          null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                      ],
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: suffix,
                      decoration: _fieldDecoration(s, s.suffix),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final letter = mi.text.trim().isEmpty
                    ? ''
                    : mi.text.trim().substring(0, 1).toUpperCase();
                await fs.updateResidentProfile(
                  uid: u.uid,
                  firstName: first.text,
                  lastName: last.text,
                  middleInitial: letter,
                  suffix: suffix.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(s.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    return Scaffold(
      appBar: AppBar(title: Text(s.residents)),
      body: StreamBuilder<List<UserProfile>>(
        stream: fs.residentsStream(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text(s.genericError));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) return Center(child: Text(s.noResidents));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final u = list[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text('${s.email}: ${u.email}'),
                            Text('@${u.username}'),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (v) async {
                          if (v == 'edit') {
                            await _editDialog(context, fs, u);
                          } else if (v == 'remove') {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(s.delete),
                                content: Text(s.removeUserConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(s.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(s.delete),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true && context.mounted) {
                              try {
                                await fs.softDeleteResident(
                                  uid: u.uid,
                                  username: u.username,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(s.residentRemovedSuccess)),
                                );
                              } on FirebaseException catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${s.residentRemoveFailed} (${e.code})'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'edit', child: Text(s.edit)),
                          PopupMenuItem(value: 'remove', child: Text(s.delete)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
