import 'geofence.dart';
import 'policy.dart';
import 'telegram_config.dart';

class OfficeConfig {
  final String officeId;
  final String officeName;
  final String groupName;
  final Geofence geofence;
  final Policy policy;
  final TelegramConfig telegramConfig;

  OfficeConfig({
    required this.officeId,
    required this.officeName,
    required this.groupName,
    required this.geofence,
    required this.policy,
    required this.telegramConfig,
  });

  factory OfficeConfig.fromJson(Map<String, dynamic> json) {
    return OfficeConfig(
      officeId: json['office_id'] ?? '',
      officeName: json['office_name'] ?? '',
      groupName: json['group_name'] ?? '',
      geofence: Geofence.fromJson(json['geofence'] ?? {}),
      policy: Policy.fromJson(json['policy'] ?? {}),
      telegramConfig: TelegramConfig.fromJson(json['telegram_config'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'office_id': officeId,
    'office_name': officeName,
    'group_name': groupName,
    'geofence': geofence.toJson(),
    'policy': policy.toJson(),
    'telegram_config': telegramConfig.toJson(),
  };
}
