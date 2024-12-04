import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class InternetPage extends StatefulWidget {
  InternetPage({Key? key}) : super(key: key);
  @override
  _InternetPageState createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage> {
  DashboardService dashboardService = Get.find();
  MainService mainService = Get.find();
  DashboardController dashboardController = Get.find();
  @override
  void initState() {
    dashboardController.stopController(dashboardService.pageIndex.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        mainService.isOnNoInternetPage.value = false;
        mainService.isOnNoInternetPage.refresh();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Get.theme.primaryColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Container(
            height: Get.height,
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/no-wifi.svg",
                  colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: "There is no network connection right now. check your internet connection".text.center.lineHeight(1.4).size(15).color(Get.theme.indicatorColor).make().centered(),
                ),
                SizedBox(
                  height: 20,
                ),
                "Enable wifi or mobile data".text.uppercase.center.lineHeight(1.4).size(15).color(Get.theme.indicatorColor).make().centered(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
