import 'package:flutter/material.dart';

import 'auth_header.dart';

/// Auth screens: header on top, form centered vertically for a formal layout.
class AuthBrandedScaffold extends StatelessWidget {
  const AuthBrandedScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showAppBar = true,
    this.centerForm = false,
  });

  final String title;
  final Widget child;
  final bool showAppBar;
  /// When true (login), logo + name sit above a vertically centered form.
  final bool centerForm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: SafeArea(
        child: centerForm
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeader(),
                          const SizedBox(height: 32),
                          child,
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!showAppBar) ...[
                      const AuthHeader(compact: true),
                      const SizedBox(height: 24),
                    ],
                    child,
                  ],
                ),
              ),
      ),
    );
  }
}
