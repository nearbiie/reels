import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core.dart';

class BannerAdWidget extends StatefulWidget {
  BannerAdWidget();

  // final AdSize size;

  @override
  State<StatefulWidget> createState() => BannerAdState();
}

class BannerAdState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  final Completer<BannerAd> bannerCompleter = Completer<BannerAd>();

  bool _bannerAdIsLoaded = false;
  AdSize? size;
  MainService mainService = Get.find();
  @override
  void initState() {
    print("BannerAdState");
    super.initState();
  }

  DashboardService dashboardService = Get.find();

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(int.parse(Get.width.round().toString()));
    print("mainService.adsData['ios_banner_app_id'] ${mainService.adsData['ios_banner_app_id']}");
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid ? mainService.adsData['android_banner_app_id'] : mainService.adsData['ios_banner_app_id'],
      request: AdRequest(),
      size: size!,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAdIsLoaded = true;
          });
          print('BannerAd loaded. 111');
          dashboardService.bottomPadding.value = size!.height.toDouble();
          dashboardService.bottomPadding.refresh();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          dashboardService.bottomPadding.value = 0;
          dashboardService.bottomPadding.refresh();
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    )..load();

    print("didChangeDependencies BannerAdState ${dashboardService.bottomPadding.value}");
    // Future<void>.delayed(Duration(seconds: 1), () => _bannerAd.load());
  }

  @override
  void dispose() {
    print("AdsWidget BannerAd disposed");
    super.dispose();
    _bannerAd!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? bannerAd = _bannerAd;
    return _bannerAdIsLoaded && bannerAd != null
        ? Container(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            color: Colors.black,
            child: AdWidget(ad: bannerAd),
          )
        : Container();
  }
}
