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
  );

  final String title;
  final String body;
  final String? bigPicture;
  final Map<String, String>? iosAttachments;

  const NotificationType({
    required this.title,
    required this.body,
    this.bigPicture,
    this.iosAttachments,
  });
}
