enum NotificationType {
  simple(
    title: 'OneSignal',
    body: 'This is a simple notification',
  ),
  withImage(
    title: 'OneSignal',
    body: 'This notification has an image',
    bigPicture:
        'https://media.onesignal.com/automated_push_templates/ratings_template.png',
  );

  final String title;
  final String body;
  final String? bigPicture;

  const NotificationType({
    required this.title,
    required this.body,
    this.bigPicture,
  });
}
