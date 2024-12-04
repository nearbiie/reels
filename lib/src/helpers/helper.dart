import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart' as DIO;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;

import '../core.dart';

class CommonHelper {
  static String getRandomString(int length, {bool numeric = false}) {
    String _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    if (numeric) {
      _chars = '1234567890789435045657822340';
    }
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  late BuildContext context;
  DateTime currentBackPressTime = DateTime.now();

  CommonHelper.of(BuildContext _context) {
    this.context = _context;
  }

  static getData(data) {
    return data!['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int);
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool);
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static String formatter(String currentBalance) {
    try {
      // suffix = {' ', 'k', 'M', 'B', 'T', 'P', 'E'};
      double value = double.parse(currentBalance);

      if (value < 0) {
        // less than a thousand
        return "0";
      } else if (value < 1000) {
        // less than a thousand
        return value.toStringAsFixed(0);
      } else if (value >= 1000 && value < (1000 * 100 * 10)) {
        // less than a million
        double result = value / 1000;
        return result.toStringAsFixed(1) + "k";
      } else if (value >= 1000000 && value < (1000000 * 10 * 100)) {
        // less than 100 million
        double result = value / 1000000;
        return result.toStringAsFixed(1) + "M";
      } else if (value >= (1000000 * 10 * 100) &&
          value < (1000000 * 10 * 100 * 100)) {
        // less than 100 billion
        double result = value / (1000000 * 10 * 100);
        return result.toStringAsFixed(1) + "B";
      } else if (value >= (1000000 * 10 * 100 * 100) &&
          value < (1000000 * 10 * 100 * 100 * 100)) {
        // less than 100 trillion
        double result = value / (1000000 * 10 * 100 * 100);
        return result.toStringAsFixed(1) + "T";
      } else {
        return "0";
      }
    } catch (e) {
      return "";
      // print(e);
    }
  }

  static showLoaderSpinner(color) {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  static String limitString(String text,
      {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) +
        (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(baseUrl).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(baseUrl).scheme,
        host: Uri.parse(baseUrl).host,
        port: Uri.parse(baseUrl).port,
        path: _path + "api/v1/" + path);
    print("URI");
    print(uri.toString());

    return uri;
  }

  Color getColorFromHex(String hex) {
    if (hex.contains('#')) {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } else {
      return Color(int.parse("0xFF" + hex));
    }
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static AlignmentDirectional getAlignmentDirectional(
      String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  static toast(String msg, Color color) {
    msg = removeTrailing("\n", msg);
    return SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  static OverlayEntry overlayLoader(context, [Color? color]) {
    // MainService mainService = Get.find();
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = Get.mediaQuery.size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: color != null
              ? color
              : Theme.of(context).primaryColor.withOpacity(0.85),
          child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader.remove();
      } catch (e) {}
    });
  }

  static String removeTrailing(String pattern, String from) {
    int i = from.length;
    while (from.startsWith(pattern, i - pattern.length)) i -= pattern.length;
    return from.substring(0, i);
  }

  static fSafeChar(var data) {
    if (data == null) {
      return "";
    } else {
      return data;
    }
  }

  static fSafeNum(var data) {
    if (data == null) {
      return 0;
    } else {
      return data;
    }
  }

  static Future<bool> isIpad() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    if (info.name.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: "Tap again to exit an app.");
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  static DateTime getYourCountryTime(DateTime datetime) {
    DateTime dateTime = DateTime.now();
    Duration timezone = dateTime.timeZoneOffset;
    return datetime.add(timezone);
  }

  imageLoaderWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.15),
              blurRadius: 15,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Image.asset('assets/images/loading.gif', fit: BoxFit.fill),
      ),
    );
  }

  static Color? getColor(String colorCode) {
    colorCode = colorCode.replaceAll("#", "");

    try {
      if (colorCode.length == 6) {
        return Color(int.parse("0xFF" + colorCode));
      } else if (colorCode.length == 8) {
        return Color(int.parse("0x" + colorCode));
      } else {
        return Color(0xFFCCCCCC).withOpacity(1);
      }
    } catch (e) {
      print("printColor error $e");
      return Color(0xFFCCCCCC).withOpacity(1);
    }
  }

  static List<int> parsePusherEventData(var data) {
    List<int> ids = [];
    if (Platform.isAndroid) {
      String tempData = data.replaceAll('[', '').replaceAll(']', '');
      List tempIds = tempData.split(',');
      if (tempIds.length > 0) {
        tempIds.forEach((element) {
          if (element.indexOf('User id=') > -1) {
            if (!ids.contains(
                int.parse(element.replaceAll("User id=", "").trim()))) {
              ids.add(int.parse(element.replaceAll("User id=", "").trim()));
            }
          }
        });
      }
    } else {
      var temp = jsonDecode(data);
      if (temp['presence']['ids'] != null) {
        String tempData = temp['presence']['ids']
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '');
        List tempIds = tempData.split(',');
        if (tempIds.length > 0) {
          tempIds.forEach((element) {
            if (!ids.contains(int.parse(element))) {
              ids.add(int.parse(element));
            }
          });
        }
      }
    }
    print("IDSsss $ids");
    return ids;
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static String getDurationString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String timeAgoSinceDate(String dateString,
      {String dateFormat = "yyyy-MM-dd HH:mm:ss", bool short = true}) {
    // if (kDebugMode) print("dateString $dateString");
    print("222222");
    print(dateString);
    DateTime notificationDate = DateFormat(dateFormat).parse(dateString, true);

    notificationDate = notificationDate.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(notificationDate);
    // if (kDebugMode) print("difference.inDays ${difference.inDays}");
    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()}${short ? "y" : " year ago".tr}";
    } else if (difference.inSeconds < 3) {
      return 'just now'.tr;
    } else if (difference.inSeconds < 60) {
      return "${difference.inSeconds}${short ? 's' : ' seconds ago'.tr}";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}${short ? "min" : " min ago".tr}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}${short ? "h" : " hour ago".tr}";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}${short ? "d" : " day ago".tr}";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()}${short ? "m" : " month ago".tr}";
    } else {
      return "";
    }
  }

  static Future sendRequestToServer({
    required String endPoint,
    required Map<String, dynamic> requestData,
    Map<String, String> additionalHeaders = const {},
    String method = 'get',
    Function(int, int)? onSendProgress,
    List<UploadFile> files = const [],
  }) async {
    bool connectionOn = returnFromApiIfInternetIsOff();
    if (!connectionOn) {
      print("Internet is not working");
      return connectionOn;
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': apiUser,
      'KEY': apiKey,
    };
    Uri uri = getUri(endPoint);
    print(
        "uri ${uri.toString()} ${Get.find<AuthService>().currentUser.value.accessToken} $requestData $files");
    if (additionalHeaders.isNotEmpty) {
      headers.addAll(additionalHeaders);
    }
    headers['Authorization'] =
        'Bearer ${Get.find<AuthService>().currentUser.value.accessToken}';
    if (files.isNotEmpty) {
      try {
        for (var element in files) {
          requestData[element.variableName] = await DIO.MultipartFile.fromFile(
              element.filePath,
              filename: element.fileName);
        }

        DIO.FormData formData = DIO.FormData.fromMap(requestData);
        print(
            "uri ${uri.toString()} ${Get.find<AuthService>().currentUser.value.accessToken} $requestData");
        var response = await DIO.Dio().post(
          uri.toString(),
          options: DIO.Options(
            headers: headers,
          ),
          data: formData,
          onSendProgress: onSendProgress,
        );
        return response;
      } catch (e, s) {
        print("Error While uploading the request $e $s");
      }
    }

    if (method == "get") {
      Map<String, dynamic> data = Map<String, dynamic>.from(requestData as Map);
      uri = uri.replace(queryParameters: data);
    }

    HTTP.Response response;

    if (method == "post") {
      try {
        response = await post(
          uri,
          headers: headers,
          body: jsonEncode(requestData),
        );
        dev.log(response.body);
        return response;
      } catch (e, s) {
        print("Error While post request $e $s");
      }
    } else {
      try {
        response = await get(
          uri,
          headers: headers,
        );

        dev.log(response.body);
        return response;
      } catch (e, s) {
        print("Error While get request $e $s");
      }
    }
  }

  static bool returnFromApiIfInternetIsOff() {
    MainService mainService = Get.find();
    if (!mainService.isInternetWorking.value &&
        !mainService.firstTimeLoad.value) {
      Fluttertoast.showToast(
          msg:
              'There is no network connection right now. please check your internet connection.');
      print("ENTERED");
      EasyLoading.dismiss();
      return false;
    } else {
      print("NOT ENTERED");
      return true;
    }
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static String timeAgoCustom(DateTime d) {
    // <-- Custom method Time Show  (Display Example  ==> 'Today 7:00 PM')     // WhatsApp Time Show Status Shimila
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "y" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "m" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "w" : "weeks"} ago";
    if (diff.inDays > 0) return DateFormat.E().add_jm().format(d);
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "minutes"} ago";
    if (diff.inSeconds > 3 && diff.inSeconds < 60)
      return "${diff.inSeconds} ${diff.inSeconds == 1 ? "s" : "seconds"} ago";
    return "just now";
  }
}

class SharedData {
  static final SharedData _instance = SharedData._internal();

  factory SharedData() {
    return _instance;
  }

  SharedData._internal();

  // Data to share
  String sharedValue = "";
}
