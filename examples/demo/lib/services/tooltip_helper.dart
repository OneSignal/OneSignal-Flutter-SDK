import 'dart:convert';

import 'package:http/http.dart' as http;

import 'log_manager.dart';

class TooltipData {
  final String title;
  final String description;
  final List<TooltipOption>? options;

  const TooltipData({
    required this.title,
    required this.description,
    this.options,
  });
}

class TooltipOption {
  final String name;
  final String description;

  const TooltipOption({required this.name, required this.description});
}

class TooltipHelper {
  static final TooltipHelper _instance = TooltipHelper._internal();
  factory TooltipHelper() => _instance;
  TooltipHelper._internal();

  Map<String, TooltipData> _tooltips = {};
  bool _initialized = false;

  static const _tooltipUrl =
      'https://raw.githubusercontent.com/OneSignal/sdk-shared/main/demo/tooltip_content.json';

  Future<void> init() async {
    if (_initialized) return;

    try {
      final response = await http.get(Uri.parse(_tooltipUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _tooltips = json.map((key, value) {
          final data = value as Map<String, dynamic>;
          List<TooltipOption>? options;
          if (data['options'] != null) {
            options = (data['options'] as List<dynamic>).map((o) {
              final opt = o as Map<String, dynamic>;
              return TooltipOption(
                name: opt['name'] as String? ?? '',
                description: opt['description'] as String? ?? '',
              );
            }).toList();
          }
          return MapEntry(
            key,
            TooltipData(
              title: data['title'] as String? ?? key,
              description: data['description'] as String? ?? '',
              options: options,
            ),
          );
        });
        LogManager().i('Tooltip', 'Loaded ${_tooltips.length} tooltips');
      }
    } catch (e) {
      LogManager().w('Tooltip', 'Failed to load tooltips: $e');
    }

    _initialized = true;
  }

  TooltipData? getTooltip(String key) => _tooltips[key];
}
