import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../l10n/app_strings.dart';

/// Logo and app title shown above auth forms (login / register).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final logoSize = compact ? 72.0 : 96.0;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              AppConstants.logoAsset,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_balance,
                size: logoSize * 0.7,
                color: scheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            s.appVersionLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}
