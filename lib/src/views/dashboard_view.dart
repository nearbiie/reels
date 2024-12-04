import 'dart:ui' as UI;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leuke/src/views/dashboard1_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../core.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DateTime currentBackPressTime = DateTime.now();
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  DashboardService dashboardService = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
  PostService postService = Get.find();
  double hgt = 0;
  late AnimationController musicAnimationController;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black.withOpacity(0.6),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );

    // TODO: implement initState
    super.initState();
  }

  // DateTime currentBackPressTime = DateTime.now();
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        body: WillPopScope(
          onWillPop: () {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
              return Future.value(false);
            }
            DateTime now = DateTime.now();
            if (dashboardController.pc.isPanelOpen) {
              dashboardController.pc.close();
              return Future.value(false);
            }
            if (dashboardService.prevPage.value == "UserProfile") {
              Get.offNamed("profile-view");
              mainService.userVideoObj.value.userId = 0;
              mainService.userVideoObj.value.videoId = 0;
              mainService.userVideoObj.value.hashTag = '';
              mainService.userVideoObj.value.name = '';
              mainService.userVideoObj.refresh();
              dashboardService.prevPage.value = "";
              dashboardService.prevPage.refresh();
              return Future.value(false);
            } else {
              if (mainService.userVideoObj.value.videoId > 0 ||
                  mainService.userVideoObj.value.userId > 0 ||
                  mainService.userVideoObj.value.hashTag != "" ||
                  mainService.userVideoObj.value.name != "") {
                mainService.userVideoObj.value.videoId = 0;
                mainService.userVideoObj.value.userId = 0;
                mainService.userVideoObj.value.name = "";
                mainService.userVideoObj.value.hashTag = "";
                mainService.userVideoObj.refresh();

                dashboardController.getVideos();
                return Future.value(false);
              } else if (dashboardService.currentPage.value > 0) {
                dashboardService.currentPage.value = 0;
                dashboardService.currentPage.refresh();
                dashboardService.pageController.value.animateToPage(
                    dashboardService.currentPage.value,
                    duration: Duration(milliseconds: 100),
                    curve: Curves.linear);
                dashboardController
                    .stopController(dashboardService.pageIndex.value);
                dashboardController.getVideos();
                return Future.value(false);
              }
              if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
                currentBackPressTime = now;
                Fluttertoast.showToast(msg: "Tap again to exit an app.");
                return Future.value(false);
              }
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              return Future.value(false);
            }
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Obx(
                      () => PageView(
                        controller: dashboardService.pageController.value,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DashboardPage(),

                          // HomeView(),
                          SearchPage(),
                          NotificationsView(),
                          ConversationsView(),
                          MyProfileView(),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: dashboardController.showBannerAd.value,
                      child: Center(
                          child: Container(
                              width: Get.width, child: BannerAdWidget()))),
                  if (!dashboardController.hideBottomBar.value)
                    SafeArea(
                      top: false,
                      bottom: true,
                      child: Container(
                        height: 50.7,
                        color: Colors.black,
                        width: Get.width,
                        child: Wrap(
                          children: <Widget>[
                            Container(
                              width: Get.width,
                              height: 0.7,
                              color: mainService
                                  .setting.value.dashboardIconColor!
                                  .withOpacity(0.6),
                            ),
                            Container(
                              color: dashboardService.currentPage.value == 0
                                  ? Colors.transparent
                                  : Colors.black,
                              height: 50.0,
                              child: Padding(
                                padding: EdgeInsets.only(top: 2, bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: InkWell(
                                        onTap: () async {
                                          print(
                                              "mainService.isOnHomePage.value");
                                          print(mainService.isOnHomePage.value);
                                          if ((mainService.userVideoObj.value
                                                          .userId ==
                                                      0 ||
                                                  mainService.userVideoObj.value
                                                          .userId ==
                                                      0) &&
                                              (mainService.userVideoObj.value
                                                          .videoId ==
                                                      0 ||
                                                  mainService.userVideoObj.value
                                                          .videoId ==
                                                      0) &&
                                              mainService.userVideoObj.value
                                                      .hashTag ==
                                                  "") {
                                            if (!mainService
                                                .isOnHomePage.value) {
                                              mainService.isOnHomePage.value =
                                                  true;
                                              dashboardService
                                                  .currentPage.value = 0;
                                              dashboardService.currentPage
                                                  .refresh();
                                              if (!dashboardController
                                                  .showHomeLoader.value) {
                                                try {
                                                  mainService.userVideoObj.value
                                                      .userId = 0;
                                                  mainService.userVideoObj.value
                                                      .videoId = 0;
                                                  mainService.userVideoObj.value
                                                      .name = "";
                                                  mainService.userVideoObj
                                                      .refresh();
                                                  dashboardController
                                                      .getVideos();
                                                  dashboardService
                                                      .pageController.value
                                                      .animateToPage(
                                                          dashboardService
                                                              .currentPage
                                                              .value,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  100),
                                                          curve: Curves.linear);
                                                  dashboardService
                                                      .pageController
                                                      .refresh();
                                                } catch (e, s) {
                                                  print(
                                                      "dashboardAnimate Error $e $s");
                                                }
                                              }
                                            }
                                          } else {
                                            print("else dashboardAnimate");
                                            mainService
                                                .userVideoObj.value.userId = 0;
                                            mainService
                                                .userVideoObj.value.videoId = 0;
                                            mainService.userVideoObj.value
                                                .hashTag = '';
                                            mainService
                                                .userVideoObj.value.name = '';
                                            mainService.userVideoObj.refresh();
                                            dashboardService.currentPage.value =
                                                0;
                                            dashboardService.currentPage
                                                .refresh();
                                            dashboardService
                                                .pageController.value
                                                .animateToPage(
                                                    dashboardService
                                                        .currentPage.value,
                                                    duration: Duration(
                                                        milliseconds: 100),
                                                    curve: Curves.linear);
                                            dashboardService.pageController
                                                .refresh();
                                            dashboardController.getVideos();
                                          }
                                        },
                                        child: !dashboardController
                                                .showHomeLoader.value
                                            ? SvgPicture.asset(
                                                'assets/icons/home.svg',
                                                width: 20,
                                                colorFilter: ColorFilter.mode(
                                                    mainService.setting.value
                                                        .dashboardIconColor!,
                                                    BlendMode.srcIn),
                                              )
                                            : CommonHelper.showLoaderSpinner(
                                                mainService.setting.value
                                                    .dashboardIconColor!),
                                      ),
                                    ),
                                    
                                    
                                    IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: SvgPicture.asset(
                                        'assets/icons/search.svg',
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                            mainService.setting.value
                                                .dashboardIconColor!,
                                            BlendMode.srcIn),
                                      ),
                                      color:
                                          dashboardService.currentPage.value ==
                                                  1
                                              ? mainService.setting.value
                                                  .dashboardIconColor
                                              : mainService.setting.value
                                                  .dashboardIconColor!
                                                  .withOpacity(0.8),
                                      onPressed: () {
                                        dashboardService.currentPage.value = 1;
                                        mainService.isOnHomePage.value = false;
                                        // dashboardController.checkPlayController = 0;
                                        dashboardService.pageController.value
                                            .animateToPage(
                                                dashboardService
                                                    .currentPage.value,
                                                duration:
                                                    Duration(milliseconds: 100),
                                                curve: Curves.linear);
                                        dashboardController.stopController(
                                            dashboardService.pageIndex.value);
                                        SearchViewController searchController =
                                            Get.find();
                                        searchController.getData();
                                        // searchController.getAds();
                                        dashboardService.currentPage.refresh();
                                        dashboardService.pageController
                                            .refresh();
                                        mainService.isOnHomePage.refresh();
                                      },
                                    ),

                                         IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: SvgPicture.asset(
                                           'assets/icons/notification.svg',
                                        width: 20.0,
                                        colorFilter: ColorFilter.mode(
                                            mainService.setting.value
                                                .dashboardIconColor!,
                                            BlendMode.srcIn),
                                      ),
                                      color:
                                          dashboardService.currentPage.value ==
                                                  2
                                              ? mainService.setting.value
                                                  .dashboardIconColor
                                              : mainService.setting.value
                                                  .dashboardIconColor!
                                                  .withOpacity(0.8),
                                      onPressed: () {
                                       if (dashboardService
                                                        .currentPage.value ==
                                                    2) {
                                                  dashboardController
                                                      .stopController(
                                                          dashboardService
                                                              .pageIndex.value);
                                                }
                                                dashboardService
                                                    .currentPage.value = 2;
                                                dashboardService.currentPage
                                                    .refresh();
                                                mainService.isOnHomePage.value =
                                                    false;
                                                mainService.isOnHomePage
                                                    .refresh();

                                                dashboardService
                                                    .bottomPadding.value = 0.0;
                                                dashboardService.bottomPadding
                                                    .refresh();

                                                if (authService.currentUser
                                                        .value.accessToken !=
                                                    '') {
                                                  dashboardService
                                                      .pageController.value
                                                      .animateToPage(
                                                          dashboardService
                                                              .currentPage
                                                              .value,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  100),
                                                          curve: Curves.linear);
                                                  dashboardService
                                                      .pageController
                                                      .refresh();
                                                } else {
                                                  Get.offNamed('/login');
                                                }
                                              },
                                    ),
                                    // IconButton(
                                    //   padding: EdgeInsets.all(0),
                                    //   icon: SvgPicture.asset(
                                    //     'assets/icons/notification.svg',
                                    //     width: 20.0,
                                    //     colorFilter: ColorFilter.mode(
                                    //         mainService.setting.value
                                    //             .dashboardIconColor!,
                                    //         BlendMode.srcIn),
                                    //   ),
                                    //   onPressed: () async {
                                    //     dashboardService.currentPage.value = 2;
                                    //     //  Get.put(VideoRecorderController(), permanent: true);
                                    //     Get.offNamed('/notifications');
                                    //     // Get.to(() => DashboardView());
                                    //     // MBS.showCupertinoModalBottomSheet(
                                    //     //   // expand: true,
                                    //     //   context: context,
                                    //     //   backgroundColor: Colors.transparent,
                                    //     //   builder: (context) => SizedBox(
                                    //     //     width: Get.mediaQuery.size.width,
                                    //     //     height: 120,
                                    //     //     child: BottomSheetAddButton(),
                                    //     //   ),
                                    //     // );
                                    //   },
                                    // ),
                                    Obx(
                                      () {
                                        print(
                                            "_messageCount ${dashboardService.unreadMessageCount.value}");
                                        return Stack(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.all(0),
                                              icon: SvgPicture.asset(
                                                'assets/icons/chat.svg',
                                                width: 30.0,
                                                colorFilter: ColorFilter.mode(
                                                    dashboardService
                                                                .currentPage.value ==
                                                            3
                                                        ? mainService
                                                            .setting
                                                            .value
                                                            .dashboardIconColor!
                                                        : mainService
                                                            .setting
                                                            .value
                                                            .dashboardIconColor!
                                                            .withOpacity(0.9),
                                                    BlendMode.srcIn),
                                              ),
                                              onPressed: () async {
                                                if (dashboardService
                                                        .currentPage.value ==
                                                    0) {
                                                  dashboardController
                                                      .stopController(
                                                          dashboardService
                                                              .pageIndex.value);
                                                }
                                                dashboardService
                                                    .currentPage.value = 3;
                                                dashboardService.currentPage
                                                    .refresh();
                                                mainService.isOnHomePage.value =
                                                    false;
                                                mainService.isOnHomePage
                                                    .refresh();

                                                dashboardService
                                                    .bottomPadding.value = 0.0;
                                                dashboardService.bottomPadding
                                                    .refresh();

                                                if (authService.currentUser
                                                        .value.accessToken !=
                                                    '') {
                                                  dashboardService
                                                      .pageController.value
                                                      .animateToPage(
                                                          dashboardService
                                                              .currentPage
                                                              .value,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  100),
                                                          curve: Curves.linear);
                                                  dashboardService
                                                      .pageController
                                                      .refresh();
                                                } else {
                                                  Get.offNamed('/login');
                                                }
                                              },
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: dashboardService
                                                          .unreadMessageCount
                                                          .value >
                                                      0
                                                  ? Transform.translate(
                                                      offset: Offset(-2, -6),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 2,
                                                                vertical: 0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: mainService
                                                              .setting
                                                              .value
                                                              .dashboardIconColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            dashboardService
                                                                .unreadMessageCount
                                                                .value
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: Get.theme
                                                                  .highlightColor,
                                                              fontSize: 8,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Obx(() {
                                      print(
                                          "_messageCount ${dashboardService.unreadMessageCount.value}");
                                      return Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: InkWell(
                                          onTap: () {
                                            dashboardService.currentPage.value =
                                                4;
                                            dashboardService.currentPage
                                                .refresh();
                                            mainService.isOnHomePage.value =
                                                false;
                                            mainService.isOnHomePage.refresh();
                                            dashboardController.stopController(
                                                dashboardService
                                                    .pageIndex.value);
                                            dashboardService
                                                .bottomPadding.value = 0.0;
                                            dashboardService.bottomPadding
                                                .refresh();
                                            dashboardController.stopController(
                                                dashboardService
                                                    .pageIndex.value);
                                            if (authService.currentUser.value
                                                    .accessToken !=
                                                '') {
                                              if (authService.currentUser.value
                                                      .userVideos.length ==
                                                  0) {
                                                UserController userController =
                                                    Get.find();
                                                userController.getMyProfile();
                                              }
                                              dashboardService
                                                  .pageController.value
                                                  .animateToPage(
                                                      dashboardService
                                                          .currentPage.value,
                                                      duration: Duration(
                                                          milliseconds: 100),
                                                      curve: Curves.linear);
                                              dashboardService.pageController
                                                  .refresh();
                                            } else {
                                              Get.offNamed("/login");
                                            }
                                          },
                                          child: authService.currentUser.value
                                                      .accessToken !=
                                                  ""
                                              ? Container(
                                                  height: 35.0,
                                                  width: 35.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white30,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: dashboardService
                                                                .currentPage
                                                                .value ==
                                                            4
                                                        ? new Border.all(
                                                            color: mainService
                                                                .setting
                                                                .value
                                                                .dpBorderColor!,
                                                            width: 2.0,
                                                          )
                                                        : null,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    child: authService
                                                                .currentUser
                                                                .value
                                                                .userDP !=
                                                            ""
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                authService
                                                                    .currentUser
                                                                    .value
                                                                    .userDP,
                                                            memCacheHeight: 50,
                                                            memCacheWidth: 50,
                                                            errorWidget:
                                                                (a, b, c) {
                                                              return Image
                                                                  .asset(
                                                                "assets/images/splash.png",
                                                                fit: BoxFit
                                                                    .cover,
                                                              );
                                                            },
                                                          )
                                                        : Image.asset(
                                                            "assets/images/splash.png",
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  color: dashboardService
                                                              .currentPage
                                                              .value ==
                                                          4
                                                      ? mainService
                                                          .setting
                                                          .value
                                                          .dashboardIconColor
                                                      : mainService
                                                          .setting
                                                          .value
                                                          .dashboardIconColor!
                                                          .withOpacity(0.8),
                                                  size: 30,
                                                ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Obx(() {
                  return dashboardService.isUploading.value
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: Get.width * 0.8,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black54,
                                  ),
                                  width: 100,
                                  height: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Center(
                                      child: dashboardService
                                                  .uploadProgress.value <
                                              1
                                          ? CircularPercentIndicator(
                                              progressColor: Colors.pink,
                                              percent: dashboardService
                                                  .uploadProgress.value,
                                              radius: 40.0,
                                              lineWidth: 7.0,
                                              circularStrokeCap:
                                                  CircularStrokeCap.round,
                                              center: Text(
                                                (dashboardService.uploadProgress
                                                                .value *
                                                            100)
                                                        .toStringAsFixed(2) +
                                                    "%",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                            )
                                          : Center(
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 7,
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Preparing".tr,
                                      style: TextStyle(
                                        color: Get.theme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Please wait a little longer".tr,
                                      style: TextStyle(
                                        color: Get.theme.primaryColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).pSymmetric(h: 10),
                        )
                      : SizedBox();
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  buttonPlus() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 46,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.transparent),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0x2dd3e7).withOpacity(1)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 28,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xed316a).withOpacity(1)),
              ),
            ),
            Center(
              child: Container(
                width: 28,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: mainService.setting.value.dashboardIconColor),
                child: Center(child: Icon(Icons.add, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomSheetAddButton extends StatelessWidget {
  BottomSheetAddButton({Key? key}) : super(key: key);
  final DashboardController dashboardController = Get.find();
  final DashboardService dashboardService = Get.find();
  final MainService mainService = Get.find();
  final AuthService authService = Get.find();
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: UI.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: false,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (dashboardService.isUploading.value) {
                    Fluttertoast.showToast(
                      msg:
                          'Video is being uploaded kindly wait for the process to complete'
                              .tr,
                      textColor: Get.theme.primaryColor,
                    );
                  } else {
                    mainService.isOnHomePage.value = false;
                    mainService.isOnHomePage.refresh();

                    dashboardService.bottomPadding.value = 0.0;
                    dashboardController
                        .stopController(dashboardService.pageIndex.value);
                    Get.back();
                    if (authService.currentUser.value.accessToken != '') {
                      mainService.isOnRecordingPage.value = true;
                      Get.put(VideoRecorderController(), permanent: true);
                      Get.offNamed('/video-recorder');
                    } else {
                      Get.offNamed('/login');
                    }
                  }
                },
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/icons/camera.svg',
                      colorFilter:
                          ColorFilter.mode(Color(0XFF4d88e6), BlendMode.srcIn),
                      width: 50,
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 0),
                      child: Text(
                        "Record Video",
                        style: TextStyle(
                            color: Get.theme.indicatorColor, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ).pOnly(top: 20),
        ),
      ),
    );
  }
}
