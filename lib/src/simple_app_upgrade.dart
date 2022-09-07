import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_upgrade/src/app_market.dart';
import 'package:flutter_upgrade/src/flutter_upgrade.dart';
import 'package:flutter_upgrade/src/liquid_progress_indicator.dart';

///
/// des:app升级提示控件
///
class SimpleAppUpgradeWidget extends StatefulWidget {
  const SimpleAppUpgradeWidget({
    required this.title,
    this.titleStyle,
    required this.description,
    this.descriptionStyle,
    this.cancel,
    this.okText,
    this.okTextStyle,
    this.okBackgroundColors,
    this.loadingOkBackgroundColor = Colors.white,
    this.progressBar,
    this.progressBarColor,
    this.borderRadius = 10,
    this.downloadUrl,
    this.force = false,
    this.iosAppId,
    this.appMarketInfo,
    this.onDownloaded,
  });

  ///
  /// 升级标题
  ///
  final String title;

  ///
  /// 标题样式
  ///
  final TextStyle? titleStyle;

  ///
  /// 升级提示内容
  ///
  final String description;

  ///
  /// 提示内容样式
  ///
  final TextStyle? descriptionStyle;

  ///
  /// 下载进度条
  ///
  final Widget? progressBar;

  ///
  /// 进度条颜色
  ///
  final Color? progressBarColor;

  ///
  /// 确认控件
  ///
  final String? okText;

  ///
  /// 确认控件样式
  ///
  final TextStyle? okTextStyle;

  ///
  /// 确认控件背景颜色,2种颜色左到右线性渐变
  ///
  final List<Color>? okBackgroundColors;

  final Color loadingOkBackgroundColor;

  ///
  /// 取消控件
  ///
  final Widget? cancel;

  ///
  /// app安装包下载url,没有下载跳转到应用宝等渠道更新
  ///
  final String? downloadUrl;

  ///
  /// 圆角半径
  ///
  final double borderRadius;

  ///
  /// 是否强制升级,设置true没有取消按钮
  ///
  final bool force;

  ///
  /// ios app id,用于跳转app store
  ///
  final String? iosAppId;

  ///
  /// 指定跳转的应用市场，
  /// 如果不指定将会弹出提示框，让用户选择哪一个应用市场。
  ///
  final AppMarketInfo? appMarketInfo;

  final Function? onDownloaded;

  @override
  State<StatefulWidget> createState() => _SimpleAppUpgradeWidget();
}

class _SimpleAppUpgradeWidget extends State<SimpleAppUpgradeWidget> {
  static final String _downloadApkName = 'temp.apk';

  ///
  /// 下载进度
  ///
  double _downloadProgress = 0.0;

  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    var close = widget.cancel ?? Icon(Icons.close);
    return Container(
      child: Stack(
        children: <Widget>[
          _buildInfoWidget(context),
          if (!widget.force)
            Positioned(
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: close,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              right: 0,
              top: 0,
            ),
        ],
      ),
    );
  }

  ///
  /// 信息展示widget
  ///
  Widget _buildInfoWidget(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //标题
          _buildTitle(),
          //更新信息
          _buildAppInfo(),
          //操作按钮
          _buildAction()
        ],
      ),
    );
  }

  ///
  /// 构建标题
  ///
  _buildTitle() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(widget.title,
            style: widget.titleStyle ?? TextStyle(fontSize: 22)));
  }

  ///
  /// 构建版本更新信息
  ///
  _buildAppInfo() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      height: 200,
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Text(
          widget.description,
          style: widget.descriptionStyle ?? TextStyle(),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  ///
  /// 构建取消或者升级按钮
  ///
  _buildAction() {
    return Column(
      children: <Widget>[
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        _buildOkActionButton(),
      ],
    );
  }

  ///
  /// 确定按钮
  ///
  _buildOkActionButton() {
    var borderRadius = BorderRadius.only(
        bottomRight: Radius.circular(widget.borderRadius),
        bottomLeft: Radius.circular(widget.borderRadius));
    var _okBackgroundColors = downloading
        ? [widget.loadingOkBackgroundColor, widget.loadingOkBackgroundColor]
        : widget.okBackgroundColors;
    if (widget.okBackgroundColors == null ||
        widget.okBackgroundColors!.length != 2) {
      _okBackgroundColors = [
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColor
      ];
    }

    Widget child;
    if (!downloading) {
      child = Text(widget.okText ?? '立即体验',
          style: widget.okTextStyle ?? TextStyle(color: Colors.white));
    } else {
      child = _buildDownloadProgress();
    }

    return Ink(
      child: InkWell(
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedContainer(
            height: 45,
            alignment: Alignment.center,
            child: child,
            duration: Duration(seconds: 1),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_okBackgroundColors![0], _okBackgroundColors[1]]),
                borderRadius: borderRadius),
          ),
        ),
        onTap: () {
          if (!downloading) {
            _clickOk();
          }
        },
      ),
    );
  }

  ///
  /// 下载进度widget
  ///
  Widget _buildDownloadProgress() {
    final percentage = _downloadProgress * 100;
    return widget.progressBar ??
        LiquidLinearProgressIndicator(
          value: _downloadProgress,
          direction: Axis.horizontal,
          valueColor: AlwaysStoppedAnimation(widget.progressBarColor ??
              Theme.of(context).primaryColor.withOpacity(0.4)),
          borderRadius: 0,
          center: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }

  ///
  /// 点击确定按钮
  ///
  _clickOk() async {
    if (Platform.isIOS) {
      //ios 需要跳转到app store更新，原生实现
      FlutterUpgrade.toAppStore(widget.iosAppId);
      return;
    }
    if (widget.downloadUrl == null || widget.downloadUrl!.isEmpty) {
      //没有下载地址，跳转到第三方渠道更新，原生实现
      FlutterUpgrade.toMarket(appMarketInfo: widget.appMarketInfo);
      return;
    }
    String? path = await FlutterUpgrade.apkDownloadPath;
    _downloadApk(widget.downloadUrl!, '$path/$_downloadApkName');
    setState(() {
      downloading = true;
    });
  }

  ///
  /// 下载apk包
  ///
  _downloadApk(String url, String path) async {
    try {
      var dio = Dio();
      await dio.download(url, path, onReceiveProgress: (int count, int total) {
        if (total == -1) {
          _downloadProgress = 0.01;
        } else {
          _downloadProgress = count / total.toDouble();
        }

        if (_downloadProgress == 1) {
          //下载完成，跳转到程序安装界面
          setState(() {
            downloading = false;
          });
          if (widget.onDownloaded != null) {
            widget.onDownloaded!();
          }
          Navigator.of(context).pop();
          FlutterUpgrade.installAppForAndroid(path);
        } else {
          setState(() {});
        }
      });
    } catch (e) {
      print('$e');
    }
  }
}
