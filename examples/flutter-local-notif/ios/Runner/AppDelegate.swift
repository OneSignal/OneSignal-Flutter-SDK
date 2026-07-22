import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var localNotificationResponseChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    let isFlutterLocalNotification =
      userInfo["NotificationId"] != nil &&
      userInfo["presentAlert"] != nil &&
      userInfo["presentSound"] != nil &&
      userInfo["presentBadge"] != nil &&
      userInfo["payload"] != nil

    guard isFlutterLocalNotification else {
      super.userNotificationCenter(
        center,
        willPresent: notification,
        withCompletionHandler: completionHandler
      )
      return
    }

    func isEnabled(_ key: String) -> Bool {
      (userInfo[key] as? NSNumber)?.boolValue ?? false
    }

    var options: UNNotificationPresentationOptions = []
    if #available(iOS 14.0, *) {
      if isEnabled("presentBanner") {
        options.insert(.banner)
      }
      if isEnabled("presentList") {
        options.insert(.list)
      }
    } else if isEnabled("presentAlert") {
      options.insert(.alert)
    }
    if isEnabled("presentSound") {
      options.insert(.sound)
    }
    if isEnabled("presentBadge") {
      options.insert(.badge)
    }
    completionHandler(options)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    let isFlutterLocalNotification =
      userInfo["NotificationId"] != nil &&
      userInfo["presentAlert"] != nil &&
      userInfo["presentSound"] != nil &&
      userInfo["presentBadge"] != nil &&
      userInfo["payload"] != nil

    guard isFlutterLocalNotification else {
      super.userNotificationCenter(
        center,
        didReceive: response,
        withCompletionHandler: completionHandler
      )
      return
    }

    localNotificationResponseChannel?.invokeMethod(
      "didReceiveLocalNotificationResponse",
      arguments: [
        "notificationId": response.notification.request.identifier,
        "payload": userInfo["payload"] as? String ?? "",
      ]
    )
    completionHandler()
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    localNotificationResponseChannel = FlutterMethodChannel(
      name: "com.onesignal.example/local_notification_response",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
  }
}
