import 'dart:async';
import 'package:flutter/services.dart';

import 'package:onesignal_flutter/src/pushsubscription.dart';

class OneSignalUser {
  static OneSignalPushSubscription _pushSubscription =
      new OneSignalPushSubscription();

  OneSignalPushSubscription get pushSubscription => _pushSubscription;

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#user');

  /// Sets the user's language.
  ///
  /// Sets the user's language to [language] this also applies to
  /// the email and/or SMS player if those are logged in on the device.
  Future<void> setLanguage(String language) async {
    return await _channel
        .invokeMethod("OneSignal#setLanguage", {'language': language});
  }

  /// Set an [alias] for the current user.
  ///
  /// If this [alias] label already exists on this user,
  /// it will be overwritten with the new alias [id].
  Future<void> addAlias(String alias, dynamic id) async {
    return await this.addAliases({alias: id});
  }

  /// Set [aliases] for the current user.
  ///
  /// If any alias already exists, it will be overwritten to the new values.
  Future<void> addAliases(Map<String, dynamic> aliases) async {
    return await _channel.invokeMethod("OneSignal#addAliases", aliases);
  }

  /// Remove an [alias] from the current user.
  Future<void> removeAlias(String label) async {
    return await this.removeAliases([label]);
  }

  /// Remove [aliases] from the current user.
  Future<void> removeAliases(List<String> aliases) async {
    return await _channel.invokeMethod("OneSignal#removeAliases", aliases);
  }

  /// Add a tag for the current user.
  ///
  /// Tags are [key] : [value] pairs used as building blocks for targeting
  /// specific users and/or personalizing messages. If the tag [key] already
  /// exists, it will be replaced with the [value] provided here.
  Future<void> addTagWithKey(String key, dynamic value) async {
    return await this.addTags({key: value.toString()});
  }

  /// Add multiple [tags] for the current user.
  ///
  /// [Tags] are key:value pairs used as building blocks for targeting
  /// specific users and/or personalizing messages. If the tag key already
  /// exists, it will be replaced with the value provided here.
  Future<void> addTags(Map<String, dynamic> tags) async {
    tags.forEach((key, value) {
      tags[key] = value.toString();
    });
    return await _channel.invokeMethod("OneSignal#addTags", tags);
  }

  /// Remove the data tag with the provided [key] from the current user.
  Future<void> removeTag(String key) async {
    return await this.removeTags([key]);
  }

  /// Remove multiple [tags] with the provided keys from the current user.
  Future<void> removeTags(List<String> tags) async {
    return await _channel.invokeMethod("OneSignal#removeTags", tags);
  }

  /// Returns the list of tags on the current user.
  Future<Map<String, String>> getTags() async {
    Map<dynamic, dynamic> tags =
        await _channel.invokeMethod("OneSignal#getTags");
    return tags.cast<String, String>();
  }

  /// Add a new [email] subscription to the current user.
  Future<void> addEmail(String email) async {
    return await _channel.invokeMethod("OneSignal#addEmail", email);
  }

  /// Remove an [email] subscription from the current user.
  ///
  /// Returns false if the specified [email] does not exist
  /// on the user within the SDK, and no request will be made.
  Future<void> removeEmail(String email) async {
    return await _channel.invokeMethod("OneSignal#removeEmail");
  }

  /// Add a new SMS subscription to the current user.
  ///
  /// Add an SMS subscription by adding an [smsNumber]
  Future<void> addSms(String smsNumber) async {
    return await _channel.invokeMethod("OneSignal#addSms", smsNumber);
  }

  /// Remove an SMS subscription from the current user.
  ///
  /// Returns false if the specified [smsNumber] does not
  /// exist on the user within the SDK, and no request will be made.
  Future<void> removeSms(String smsNumber) async {
    return await _channel.invokeMethod("OneSignal#removeSms", smsNumber);
  }
}
