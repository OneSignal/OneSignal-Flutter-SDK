import 'package:flutter/material.dart';

enum InAppMessageType {
  topBanner('Top Banner', 'top_banner', Icons.vertical_align_top),
  bottomBanner('Bottom Banner', 'bottom_banner', Icons.vertical_align_bottom),
  centerModal('Center Modal', 'center_modal', Icons.crop_square),
  fullScreen('Full Screen', 'full_screen', Icons.fullscreen);

  final String label;
  final String triggerValue;
  final IconData icon;

  const InAppMessageType(this.label, this.triggerValue, this.icon);
}
