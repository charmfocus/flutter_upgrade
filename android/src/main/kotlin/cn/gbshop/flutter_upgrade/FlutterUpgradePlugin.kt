package cn.gbshop.flutter_upgrade

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File

/** FlutterUpgradePlugin */
public class FlutterUpgradePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cn.gbshop.plugin/flutter_upgrade")
    channel.setMethodCallHandler(FlutterUpgradePlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    lateinit var mContext: Context
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      mContext = registrar.activity()!!
      val channel = MethodChannel(registrar.messenger(), "flutter_upgrade")
      channel.setMethodCallHandler(FlutterUpgradePlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "getAppInfo" -> {
          result.success(getAppInfo(mContext))
        }
        "getApkDownloadPath" -> {
          result.success(mContext.getExternalFilesDir("")?.absolutePath)
        }
        "upgradeAndInstall" -> {
          result.success(upgradeAndInstall(call, mContext))
        }
        "install" -> {
          //安装app
          val path = call.argument<String>("path")
          path?.also {
            installApk(mContext, File(it))
          }
        }
        "getInstallMarket" -> {
          val packageList = getInstallMarket(mContext, call.argument<List<String>>("packages"))
          result.success(packageList)
        }
        "toMarket" -> {
          val marketPackageName = call.argument<String>("marketPackageName")
          val marketClassName = call.argument<String>("marketClassName")
          toMarket(mContext, marketPackageName, marketClassName)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  override fun onDetachedFromActivity() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    mContext = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }
}
