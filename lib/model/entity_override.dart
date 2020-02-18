import 'package:hasskit/helper/logger.dart';

class EntityOverride {
  String overrideName;
  String overrideIcon;
  bool openRequireAttention;

  EntityOverride({
    this.overrideName,
    this.overrideIcon,
    this.openRequireAttention,
  });
  factory EntityOverride.fromJson(Map<String, dynamic> json) {
    try {
      return EntityOverride(
        overrideName: json['friendlyName'],
        overrideIcon: json['icon'],
        openRequireAttention: json['openRequireAttention'],
      );
    } catch (e) {
      log.e("EntityOverride.fromJson $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'friendlyName': overrideName,
        'icon': overrideIcon,
        'openRequireAttention': openRequireAttention,
      };
}
