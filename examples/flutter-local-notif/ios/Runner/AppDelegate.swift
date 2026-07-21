import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
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

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
