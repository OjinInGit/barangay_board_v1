import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Announcement categories ordered by severity (lowest number = highest priority).
enum AnnouncementType {
  urgentNotice,
  healthAdvisory,
  officialAdvisory,
  publicNotice,
  generalAssembly,
  wasteManagement,
  event,
  customTag;

  int get severityRank => index + 1;

  String get code {
    switch (this) {
      case AnnouncementType.urgentNotice:
        return 'urgent_notice';
      case AnnouncementType.healthAdvisory:
        return 'health_advisory';
      case AnnouncementType.officialAdvisory:
        return 'official_advisory';
      case AnnouncementType.publicNotice:
        return 'public_notice';
      case AnnouncementType.generalAssembly:
        return 'general_assembly';
      case AnnouncementType.wasteManagement:
        return 'waste_management';
      case AnnouncementType.event:
        return 'event';
      case AnnouncementType.customTag:
        return 'custom_tag';
    }
  }

  static AnnouncementType fromCode(String? raw) {
    if (raw == null || raw.isEmpty) return AnnouncementType.publicNotice;
    switch (raw) {
      case 'urgent_notice':
      case 'urgentNotice':
        return AnnouncementType.urgentNotice;
      case 'health_advisory':
      case 'healthAdvisory':
        return AnnouncementType.healthAdvisory;
      case 'official_advisory':
      case 'officialAdvisory':
      case 'ordinance':
        return AnnouncementType.officialAdvisory;
      case 'public_notice':
      case 'publicNotice':
      case 'notice':
        return AnnouncementType.publicNotice;
      case 'general_assembly':
      case 'generalAssembly':
      case 'meeting':
        return AnnouncementType.generalAssembly;
      case 'waste_management':
      case 'wasteManagement':
        return AnnouncementType.wasteManagement;
      case 'event':
        return AnnouncementType.event;
      case 'custom_tag':
      case 'customTag':
      case 'other':
        return AnnouncementType.customTag;
      default:
        return AnnouncementType.publicNotice;
    }
  }

  String label(AppStrings s) {
    switch (this) {
      case AnnouncementType.urgentNotice:
        return s.typeUrgentNotice;
      case AnnouncementType.healthAdvisory:
        return s.typeHealthAdvisory;
      case AnnouncementType.officialAdvisory:
        return s.typeOfficialAdvisory;
      case AnnouncementType.publicNotice:
        return s.typePublicNotice;
      case AnnouncementType.generalAssembly:
        return s.typeGeneralAssembly;
      case AnnouncementType.wasteManagement:
        return s.typeWasteManagement;
      case AnnouncementType.event:
        return s.typeEvent;
      case AnnouncementType.customTag:
        return s.typeCustomTag;
    }
  }

  String displayLabel(AppStrings s, String? customTagText) {
    if (this == AnnouncementType.customTag &&
        customTagText != null &&
        customTagText.trim().isNotEmpty) {
      return customTagText.trim();
    }
    return label(s);
  }

  IconData get icon {
    switch (this) {
      case AnnouncementType.urgentNotice:
        return Icons.campaign_outlined;
      case AnnouncementType.healthAdvisory:
        return Icons.medical_services_outlined;
      case AnnouncementType.officialAdvisory:
        return Icons.gavel_outlined;
      case AnnouncementType.publicNotice:
        return Icons.info_outline;
      case AnnouncementType.generalAssembly:
        return Icons.groups_outlined;
      case AnnouncementType.wasteManagement:
        return Icons.delete_outline;
      case AnnouncementType.event:
        return Icons.event_outlined;
      case AnnouncementType.customTag:
        return Icons.label_outline;
    }
  }

  static List<AnnouncementType> bySeverity() => AnnouncementType.values;
}
