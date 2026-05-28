class UserData {
  final Map<String, String> aliases;
  final Map<String, String> tags;
  final List<String> emails;
  final List<String> smsNumbers;
  final String? externalId;

  const UserData({
    required this.aliases,
    required this.tags,
    required this.emails,
    required this.smsNumbers,
    this.externalId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final identity = json['identity'] as Map<String, dynamic>? ?? {};
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final subscriptions = json['subscriptions'] as List<dynamic>? ?? [];
    final tagsRaw = properties['tags'] as Map<String, dynamic>? ?? {};

    final aliases = <String, String>{};
    for (final entry in identity.entries) {
      if (entry.key != 'external_id' && entry.key != 'onesignal_id') {
        aliases[entry.key] = entry.value.toString();
      }
    }

    final tags = <String, String>{};
    for (final entry in tagsRaw.entries) {
      tags[entry.key] = entry.value.toString();
    }

    final emails = <String>[];
    final smsNumbers = <String>[];
    for (final sub in subscriptions) {
      if (sub is Map<String, dynamic>) {
        final type = sub['type'] as String?;
        final token = sub['token'] as String?;
        if (type == 'Email' && token != null) {
          emails.add(token);
        } else if (type == 'SMS' && token != null) {
          smsNumbers.add(token);
        }
      }
    }

    return UserData(
      aliases: aliases,
      tags: tags,
      emails: emails,
      smsNumbers: smsNumbers,
      externalId: identity['external_id']?.toString(),
    );
  }
}
