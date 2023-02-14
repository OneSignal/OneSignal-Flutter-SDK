import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';

import 'package:onesignal_flutter/src/pushsubscription.dart';

class OneSignalUser {

  static OneSignalPushSubscription _pushSubscription = new OneSignalPushSubscription();

  OneSignalPushSubscription get pushSubscription => _pushSubscription;

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#user');

  /// Sets the user's language.
  ///
  /// Sets the user's language to [language] this also applies to
  /// the email and/or SMS player if those are logged in on the device.
  void setLanguage(String language)  {
   _channel.invokeMethod("OneSignal#setLanguage", {'language' : language});
  }

  /// Set an [alias] for the current user.
  /// 
  /// If this [alias] label already exists on this user, 
  /// it will be overwritten with the new alias [id].
  void addAlias(String alias, dynamic id) {
    this.addAliases({alias: id});
  }

  /// Set [aliases] for the current user. 
  ///
  /// If any alias already exists, it will be overwritten to the new values.
  void addAliases(Map<String, dynamic> aliases) {
    _channel.invokeMethod("OneSignal#addAlias", aliases);
  }

  /// Remove an [alias] from the current user.
  void removeAlias(String alias, dynamic id) {
    this.removeAliases({alias: id});
  }

  /// Remove [aliases] from the current user.
  void removeAliases(Map<String, dynamic> aliases) {
    _channel.invokeMethod("OneSignal#removeAliases", aliases);
  }

  /// Add a tag for the current user. 
  ///
  /// Tags are [key] : [value] pairs used as building blocks for targeting 
  /// specific users and/or personalizing messages. If the tag [key] already 
  /// exists, it will be replaced with the [value] provided here.
  void addTagWithKey(String key, dynamic value) {
    this.addTags({key: value});
  }

  /// Add multiple [tags] for the current user. 
  ///
  /// [Tags] are key:value pairs used as building blocks for targeting 
  /// specific users and/or personalizing messages. If the tag key already 
  /// exists, it will be replaced with the value provided here.
  void addTags(Map<String, dynamic> tags) {
    _channel.invokeMethod("OneSignal#addTags", tags);
  }

  /// Remove the data tag with the provided [key] from the current user.
  void removeTag(String key) {
    this.removeTags([key]);
  }

  /// Remove multiple [tags] with the provided keys from the current user.
  void removeTags(List<String> tags) {
    _channel.invokeMethod("OneSignal#removeTags", tags);
  }

  /// Add a new [email] subscription to the current user.
  void addEmail(String email) {
    _channel.invokeMethod("OneSignal#addEmail", email);
  }

  /// Remove an [email] subscription from the current user. 
  ///
  /// Returns false if the specified [email] does not exist 
  /// on the user within the SDK, and no request will be made.
  Future<bool> removeEmail(String email) async {
    return await _channel.invokeMethod("OneSignal#removeEmail");
  }

  /// Add a new SMS subscription to the current user.
  ///
  /// Add an SMS subscription by adding an [smsNumber]
  void addSmsNumber(String smsNumber) {
    _channel.invokeMethod("OneSignal#addSmsNumber", smsNumber);
  }

  /// Remove an SMS subscription from the current user. 
  ///
  /// Returns false if the specified [smsNumber] does not
  /// exist on the user within the SDK, and no request will be made.
  Future<bool> removeSmsNumber(String smsNumber) async {
    return await _channel.invokeMethod("OneSignal#removeSmsNumber");
  }


 
}
