package com.silent.update.silent_update


import android.app.Activity
import android.content.Context
import android.annotation.TargetApi
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.OutputStream
import java.lang.ref.WeakReference


/**
 * OtaUpdatePlugin
 */


abstract class ContextAwarePlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

  abstract val pluginName: String

  private lateinit var channel : MethodChannel

  protected val activity get() = activityReference.get()
  protected val applicationContext get() =
    contextReference.get() ?: activity?.applicationContext

  private var activityReference = WeakReference<Activity>(null)
  private var contextReference = WeakReference<Context>(null)

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityReference = WeakReference(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityReference.clear()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityReference = WeakReference(binding.activity)
  }

  override fun onDetachedFromActivity() {
    activityReference.clear()
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, pluginName)
    channel.setMethodCallHandler(this)

    contextReference = WeakReference(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

  class SilentUpdatePlugin: ContextAwarePlugin() {
  override val pluginName: String = "silent_update"

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    applicationContext //Do something
    activity
    if (call.method == "getPlatformVersion") {

      result.success("Android version: ${android.os.Build.VERSION.RELEASE}")
    }
    else
      if (call.method == "installApp"){
        Log.d("Silent Update","Test 0")
      val packageInstaller = applicationContext?.packageManager?.packageInstaller

      // Prepare params for installing one APK file with MODE_FULL_INSTALL
      // We could use MODE_INHERIT_EXISTING to install multiple split APKs
      val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
      params.setAppPackageName(call.argument("packageName"))
        Log.d("Silent Update","Test 1")
      // Get a PackageInstaller.Session for performing the actual update
      val sessionId = packageInstaller?.createSession(params)
      val session = packageInstaller?.openSession(sessionId as Int)
        Log.d("Silent Update","Test 2")
      // Copy APK file bytes into OutputStream provided by install Session
      val out = session?.openWrite((call.argument<String>("packageName") as String), 0, -1)
        Log.d("Silent Update","Test 3")
      val fis = File(call.argument<String>("apkPath") as String).inputStream()
      fis.copyTo(out as OutputStream)
        Log.d("Silent Update","Test 4")
        session.fsync(out)
      out.close()
        Log.d("Silent Update","Test 5")
      // The app gets killed after installation session commit
      session.commit(PendingIntent.getBroadcast(applicationContext, sessionId as Int,
              Intent("android.intent.action.MAIN"), 0).intentSender)
        Log.d("Silent Update","Test 6")
        result.success("Success")
    }
      else {
        Log.d("SilentUpdate",call.method)
      result.error("Error","Error message","Error Details")
    }
  }
}