enum InAppMessageType {
  topBanner('Top', 'top_banner'),
  bottomBanner('Bottom', 'bottom_banner'),
  centerModal('Center', 'center_modal'),
  html('HTML', 'html'),
  fullScreen('Full', 'full_screen'),
  fullBleed('Full Bleed', 'full_bleed'),
  carousel('Carousel', 'carousel'),
  carouselBleed('Carousel Bleed', 'carousel_bleed');

  final String label;
  final String triggerValue;

  const InAppMessageType(this.label, this.triggerValue);
}
