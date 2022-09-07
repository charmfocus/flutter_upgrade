import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_upgrade/upgrade.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App 升级测试'),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Home(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppInfo? _appInfo;
  List<AppMarketInfo> _appMarketList = [];

  @override
  void initState() {
    _checkAppUpgrade();
    _getInstallMarket();
    super.initState();
  }

  _checkAppUpgrade() {
    List<Color>? bgColors = [Colors.blue[400]!, Colors.lightBlue[400]!];
    AppUpgrade.appUpgrade(context, _checkAppInfo(),
        okBackgroundColors: bgColors,
        okText: '马上升级',
        okTextStyle: TextStyle(color: Colors.white),
        titleStyle: TextStyle(fontSize: 30),
        descriptionStyle: TextStyle(fontSize: 18),
        progressBarColor: Colors.cyan,
        borderRadius: 15,
        iosAppId: 'id88888888',
        appMarketInfo: AppMarket.huaWei);
  }

  Future<AppUpgradeInfo> _checkAppInfo() {
    return Future.value(AppUpgradeInfo(
      title: '新版本V1.1.1',
      description: '''1、支持立体声蓝牙耳机，同时改善配对性能2、提供屏幕虚拟键盘
3、更简洁更流畅，使用起来更快
4、修复一些软件在使用时自动退出bug
5、新增加了分类查看功能''',
      apkDownloadUrl:
          'https://dl.gb-cdn.gbshop.cn/apk/vender-app-1.0.6+66-stable.apk',
      force: false,
    ));
  }

  _getAppInfo() async {
    var appInfo = await FlutterUpgrade.appInfo;
    setState(() {
      _appInfo = appInfo;
    });
  }

  _getInstallMarket() async {
    List<String> marketList = await FlutterUpgrade.getInstallMarket();
    if (marketList.isNotEmpty) {
      var packageName = marketList[0];
      AppMarketInfo? _marketInfo = AppMarket.getBuildInMarket(packageName);
      print('${_marketInfo?.marketName}');
    } else {
      print('not install market!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextButton(
            onPressed: () {
              _checkAppUpgrade();
            },
            child: Text('更新')),
        Text('packageName:${_appInfo?.packageName}'),
        Text('versionName:${_appInfo?.versionName}'),
        Text('versionCode:${_appInfo?.versionCode}'),
        Text('安装的应用商店:${_appMarketList.map((f) {
          return f.marketName;
        }).toList()}'),
      ],
    );
  }
}
