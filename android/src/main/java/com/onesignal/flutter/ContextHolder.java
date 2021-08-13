package com.onesignal.flutter;

import android.content.Context;

public class ContextHolder {
  private static Context applicationContext;

  public static Context getApplicationContext() {
    return applicationContext;
  }

  public static void setApplicationContext(Context applicationContext) {
    ContextHolder.applicationContext = applicationContext;
  }
}