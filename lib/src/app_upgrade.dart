import 'package:flutter/material.dart';
import 'package:flutter_upgrade/src/app_market.dart';
import 'package:flutter_upgrade/src/simple_app_upgrade.dart';

///
/// des:App 升级组件
///
class AppUpgrade {
  ///
  /// App 升级组件入口函数，在`initState`方法中调用此函数即可。不要在[MaterialApp]控件的`initState`方法中调用，
  /// 需要在[Scaffold]的`body`控件内调用。
  ///
  /// `context`: 用于`showDialog`时使用。
  ///
  /// `future`：返回Future<AppUpgradeInfo>，通常情况下访问后台接口获取更新信息
  ///
  /// `titleStyle`：title 文字的样式
  ///
  /// `descriptionStyle`：版本信息内容文字样式
  ///
  /// `cancel`：取消按钮组件，默认"Icon(Icons.close)"
  ///
  /// `okText`：升级按钮文字，默认"立即体验"
  ///
  /// `okTextStyle`：升级按钮文字样式
  ///
  /// `okBackgroundColors`：升级按钮背景颜色，需要2种颜色，左到右线性渐变,默认是系统的[primaryColor,primaryColor]
  ///
  /// `progressBarColor`：下载进度条颜色
  ///
  /// `borderRadius`：圆角半径，默认20
  ///
  /// `iosAppId`：ios app id,用于跳转app store,格式：idxxxxxxxx
  ///
  /// `appMarketInfo`：指定Android平台跳转到第三方应用市场更新，如果不指定将会弹出提示框，让用户选择哪一个应用市场。
  ///
  static appUpgrade(
    BuildContext context,
    Future<AppUpgradeInfo> future, {
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    Widget? cancel,
    String? okText,
    TextStyle? okTextStyle,
    List<Color>? okBackgroundColors,
    Color? progressBarColor,
    double borderRadius = 20.0,
    String? iosAppId,
    AppMarketInfo? appMarketInfo,
    Function? onDownloaded,
  }) {
    future.then((AppUpgradeInfo? appUpgradeInfo) {
      if (appUpgradeInfo != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _showUpgradeDialog(
            context,
            appUpgradeInfo.title,
            appUpgradeInfo.description,
            apkDownloadUrl: appUpgradeInfo.apkDownloadUrl,
            force: appUpgradeInfo.force,
            titleStyle: titleStyle,
            descriptionStyle: descriptionStyle,
            cancel: cancel,
            okBackgroundColors: okBackgroundColors,
            okText: okText,
            okTextStyle: okTextStyle,
            borderRadius: borderRadius,
            progressBarColor: progressBarColor,
            iosAppId: iosAppId,
            appMarketInfo: appMarketInfo,
            onDownloaded: onDownloaded,
          );
        });
      }
    }).catchError((onError) {
      print('onError');
    });
  }

  ///
  /// 展示app升级提示框
  ///
  static _showUpgradeDialog(
    BuildContext context,
    String title,
    String description, {
    String? apkDownloadUrl,
    bool force = false,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    Widget? cancel,
    TextStyle? cancelTextStyle,
    String? okText,
    TextStyle? okTextStyle,
    List<Color>? okBackgroundColors,
    Color? progressBarColor,
    double borderRadius = 20.0,
    String? iosAppId,
    AppMarketInfo? appMarketInfo,
    Function? onDownloaded,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadius))),
              child: SimpleAppUpgradeWidget(
                title: title,
                titleStyle: titleStyle,
                description: description,
                descriptionStyle: descriptionStyle,
                cancel: cancel,
                okText: okText,
                okTextStyle: okTextStyle,
                okBackgroundColors: okBackgroundColors ??
                    [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor
                    ],
                progressBarColor: progressBarColor,
                borderRadius: borderRadius,
                downloadUrl: apkDownloadUrl,
                force: force,
                iosAppId: iosAppId,
                appMarketInfo: appMarketInfo,
                onDownloaded: onDownloaded,
              ));
        });
  }
}

class AppInfo {
  AppInfo({this.versionName, this.versionCode, this.packageName});

  String? versionName;
  String? versionCode;
  String? packageName;
}

class AppUpgradeInfo {
  AppUpgradeInfo(
      {required this.title,
      required this.description,
      this.apkDownloadUrl,
      this.force = false});

  ///
  /// title,显示在提示框顶部
  ///
  final String title;

  ///
  /// 升级内容
  ///
  final String description;

  ///
  /// apk下载url
  ///
  final String? apkDownloadUrl;

  ///
  /// 是否强制升级
  ///
  final bool force;
}
