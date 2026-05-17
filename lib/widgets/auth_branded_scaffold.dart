import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../l10n/app_strings.dart';

/// Login/registration layout with a faded logo watermark behind the form.
class AuthBrandedScaffold extends StatelessWidget {
  const AuthBrandedScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showAppBar = true,
  });

  final String title;
  final Widget child;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                AppConstants.logoAsset,
                width: MediaQuery.sizeOf(context).width * 0.75,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.account_balance,
                  size: 180,
                  color: scheme.primary.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          SafeArea(
            child: AbsorbPointer(
              absorbing: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!showAppBar) ...[
                      Text(
                        s.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.appVersionLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
