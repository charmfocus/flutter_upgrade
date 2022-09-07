package cn.gbshop.flutter_upgrade

import android.app.DownloadManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.widget.Toast
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import java.io.File

/**
 * 更新的文件地址
 */
const val ArgumentsUrl: String = "argumentsUrl"

/**
 * 通知栏标题
 */
const val ArgumentsTitle: String = "argumentsTitle"

/**
 * 通知栏描述
 */
const val ArgumentsDescription: String = "argumentsDescription"

/**
 * 文件存放目录
 */
const val ApkDirector: String = "apks"

/**
 * apk文件类型
 */
const val ApkType = "application/vnd.android.package-archive"

/**
 * 获取app信息
 */
fun getAppInfo(context: Context?): HashMap<String, String>? {
    context?.also {
        val packageInfo = it.packageManager.getPackageInfo(it.packageName, 0)
        val map = HashMap<String, String>()
        map["packageName"] = packageInfo.packageName
        map["versionName"] = packageInfo.versionName
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            "${packageInfo.longVersionCode}"
        } else {
            "${packageInfo.versionCode}"
        }
        map["versionCode"] = versionCode
        return map
    }
    return null
}

/**
 * 如果手机上安装多个应用市场则弹出对话框，由用户选择进入哪个市场
 */
fun toMarketChoose(context: Context) {
    try {
        var packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
        val uri = Uri.parse("market://details?id=${packageInfo.packageName}")
        val goToMarket = Intent(Intent.ACTION_VIEW, uri)
        goToMarket.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(goToMarket)
    } catch (e: ActivityNotFoundException) {
        e.printStackTrace()
        Toast.makeText(context, "您的手机没有安装应用商店", Toast.LENGTH_SHORT).show()
    }
}

/**
 * 直接跳转到指定应用市场
 *
 * @param context
 * @param packageName
 */
fun toMarket(context: Context, marketPackageName: String?, marketClassName: String?) {
    try {
        var packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
        val uri = Uri.parse("market://details?id=${packageInfo.packageName}")
        var nameEmpty = marketPackageName == null || marketPackageName.isEmpty()
        var classEmpty = marketClassName == null || marketClassName.isEmpty()
        val goToMarket = Intent(Intent.ACTION_VIEW, uri)
        if (nameEmpty || classEmpty) {
            goToMarket.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        } else {
            goToMarket.setClassName(marketPackageName ?: "", marketClassName ?: "")
        }
        context.startActivity(goToMarket)
    } catch (e: ActivityNotFoundException) {
        e.printStackTrace()
        Toast.makeText(context, "您的手机没有安装应用商店($marketPackageName)", Toast.LENGTH_SHORT).show()
    }
}

/**
 * 获取已安装应用商店的包名列表
 */
fun getInstallMarket(context: Context, packages: List<String>?): List<String> {
    val pkgs = ArrayList<String>()
    packages?.also {
        for (i in packages.indices) {
            if (isPackageExist(context, packages.get(i))) {
                pkgs.add(packages.get(i))
            }
        }
    }
    return pkgs
}

/**
 * 是否存在当前应用市场
 *
 */
fun isPackageExist(context: Context, packageName: String?): Boolean {
    val manager = context.packageManager
    return try {
        manager.getPackageInfo(packageName ?: "",
                PackageManager.GET_ACTIVITIES)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }
}


/**
 * 下载apk文件
 */
fun upgradeAndInstall(call: MethodCall, context: Context): Boolean {
    return try {
        //下载的文件地址
        val url = call.argument<String>(ArgumentsUrl)
        //标题
        val title = call.argument<String>(ArgumentsTitle)
        //描述
        val description = call.argument<String>(ArgumentsDescription)

        val downloadManager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        val request = DownloadManager.Request(Uri.parse(url))
        //读取apk文件名称
        val fileName = url?.substring(url.lastIndexOf("/") + 1)
        //设置存放路径, 放在应用内部目录
        request.setDestinationInExternalFilesDir(context, ApkDirector, fileName)

        //判断apk是否存在, 若存在, 直接安装, 否则下载
        val filePath = "${context.getExternalFilesDir(ApkDirector)?.absolutePath}/$fileName"
        if (verificationApkInfo(context, filePath)) {
            //安装文件
            installApk(context, File(filePath))
            return true
        }

        //设置下载完成仍然显示
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)

        //设置标题
        request.setTitle(title)
        //设置描述
        request.setDescription(description)
        //设置下载类型apk
        request.setMimeType(ApkType)
        //开始下载
        downloadManager.enqueue(request)
        return true
    } catch (e: Exception) {
        false
    }
}

/**
 * 验证apk文件是否完整
 */
fun verificationApkInfo(context: Context, filePath: String): Boolean {
    //如果文件不存在, 直接跳过
    if (!File(filePath).exists()) return false
    val pm = context.packageManager
    //获取应用信息
    val info = pm.getPackageArchiveInfo(filePath, PackageManager.GET_ACTIVITIES)
    //如果不为null,则有数据
    return info != null
}


/**
 * 安装app，android 7.0及以上和以下方式不同
 */
fun installApk(context: Context, file: File) {
    if(!file.exists()) {
        return
    }

    val intent = Intent(Intent.ACTION_VIEW)
    //设置flag
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        //7.0及以上
        val uri = FileProvider.getUriForFile(context, context.applicationInfo.packageName + "" +
                ".fileprovider", file)
        intent.setDataAndType(uri, ApkType)

        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    } else {
        //7.0以下, 设置数据
        intent.setDataAndType(Uri.fromFile(file), ApkType)
    }
    //启动activity
    context.startActivity(intent)

}
