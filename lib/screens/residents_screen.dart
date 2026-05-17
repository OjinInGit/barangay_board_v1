import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../data/repos.dart";
import "../l10n/locale_scope.dart";
import "../models/user_profile.dart";
import "../utils/auth_error_message.dart";
import "../utils/snacks.dart";

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.residents)),
      body: StreamBuilder<List<UserProfile>>(
        stream: userRepo.residentsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(child: Text(s.noResidents));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = list[i];
              final theme = Theme.of(context);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              r.email,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "@${r.username}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == "edit") {
                            await _openEdit(context, r);
                          } else if (v == "delete") {
                            await _confirmDelete(context, r);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: "edit", child: Text(s.edit)),
                          PopupMenuItem(value: "delete", child: Text(s.delete)),
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

  Future<void> _openEdit(BuildContext context, UserProfile r) async {
    final s = LocaleScope.stringsOf(context);
    final first = TextEditingController(text: r.firstName);
    final last = TextEditingController(text: r.lastName);
    final middle = TextEditingController(text: r.middleInitial);
    final suffix = TextEditingController(text: r.suffix);
    final user = TextEditingController(text: r.username);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.edit),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.email, style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(r.email, style: Theme.of(ctx).textTheme.bodyLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: first,
                  decoration: InputDecoration(labelText: s.firstName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: last,
                  decoration: InputDecoration(labelText: s.lastName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: middle,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z]")),
                  ],
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: s.middleInitial,
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: suffix,
                  decoration: InputDecoration(labelText: s.suffix),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: user,
                  decoration: InputDecoration(labelText: s.username),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.save),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) {
      first.dispose();
      last.dispose();
      middle.dispose();
      suffix.dispose();
      user.dispose();
      return;
    }

    final mi = middle.text.trim().toUpperCase();
    if (mi.length != 1 || !RegExp(r"[A-Z]").hasMatch(mi)) {
      showAppSnack(context, s.errMiddleInitial);
      first.dispose();
      last.dispose();
      middle.dispose();
      suffix.dispose();
      user.dispose();
      return;
    }

    final updated = UserProfile(
      uid: r.uid,
      email: r.email,
      username: user.text.trim(),
      firstName: first.text.trim(),
      lastName: last.text.trim(),
      middleInitial: mi,
      suffix: suffix.text.trim(),
      role: r.role,
      createdAt: r.createdAt,
    );

    try {
      await userRepo.updateResidentProfile(
        uid: r.uid,
        oldUsername: r.username,
        updated: updated,
      );
      if (context.mounted) showAppSnack(context, s.residentUpdated);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showAppSnack(context, authErrorMessage(s, e));
      }
    } catch (_) {
      if (context.mounted) showAppSnack(context, s.errNetwork);
    }

    first.dispose();
    last.dispose();
    middle.dispose();
    suffix.dispose();
    user.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, UserProfile r) async {
    final s = LocaleScope.stringsOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteResidentTitle),
        content: Text(s.deleteResidentBody),
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
    if (ok != true || !context.mounted) return;
    try {
      await userRepo.deleteResidentProfile(uid: r.uid, username: r.username);
      if (context.mounted) showAppSnack(context, s.residentDeleted);
    } catch (_) {
      if (context.mounted) showAppSnack(context, s.errNetwork);
    }
  }
}
