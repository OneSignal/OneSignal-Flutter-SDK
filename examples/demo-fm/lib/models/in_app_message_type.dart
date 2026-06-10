enum InAppMessageType {
  topBanner('Top Banner', 'top_banner'),
  bottomBanner('Bottom Banner', 'bottom_banner'),
  centerModal('Center Modal', 'center_modal'),
  fullScreen('Full Screen', 'full_screen');

  final String label;
  final String triggerValue;

  const InAppMessageType(this.label, this.triggerValue);
}
