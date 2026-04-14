enum NotificationType {
  simple(
    title: 'Simple Notification',
    body: 'This is a simple push notification',
  ),
  withImage(
    title: 'Image Notification',
    body: 'This notification includes an image',
    bigPicture:
        'https://media.onesignal.com/automated_push_templates/ratings_template.png',
    iosAttachments: {
      'image':
          'https://media.onesignal.com/automated_push_templates/ratings_template.png'
    },
  ),
  withSound(
    title: 'Sound Notification',
    body: 'This notification plays a custom sound',
    iosSound: 'vine_boom.wav',
    androidChannelId: 'b3b015d9-c050-4042-8548-dcc34aa44aa4',
  );

  final String title;
  final String body;
  final String? bigPicture;
  final Map<String, String>? iosAttachments;
  final String? iosSound;
  final String? androidChannelId;

  const NotificationType({
    required this.title,
    required this.body,
    this.bigPicture,
    this.iosAttachments,
    this.iosSound,
    this.androidChannelId,
  });
}
