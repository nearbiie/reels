import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../core.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin, RouteAware {
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  DashboardService dashboardService = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
  PostService postService = Get.find();
  // double hgt = 0;
  late AnimationController musicAnimationController;
  DateTime currentBackPressTime = DateTime.now();

  double _tempAdPadding = 0;
  @override
  Future<void> didChangeDependencies() async {
    print("|didChangeDependencies|");
    // final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    Timer(
        Duration(milliseconds: 800),
        () => setState(() {
              final bottomInset = Get.mediaQuery.viewInsets.bottom;
              final newValue = bottomInset > 0.0;
              setState(() {
                dashboardController.textFieldMoveToUp = newValue;
              });
            }));
    super.didChangeDependencies();
  }

  @override
  void initState() {
    mainService.isOnHomePage.value = true;
    mainService.isOnHomePage.refresh();

    musicAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
    musicAnimationController.repeat();
    if (authService.currentUser.value.email != '') {
      Timer(Duration(milliseconds: 300), () {
        dashboardController.checkEulaAgreement();
      });
    }
    dashboardController.getAds();
    super.initState();
  }

  waitForSometime() {
    Future.delayed(Duration(seconds: 2));
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      dashboardController.onTap.value = false;
      dashboardController.onTap.refresh();
      dashboardController.stopController(dashboardService.pageIndex.value);
    } else {
      dashboardController.onTap.value = true;
      dashboardController.onTap.refresh();
      dashboardController.playController(dashboardService.pageIndex.value);
    }
  }

  @override
  dispose() async {
    print("HomePage dispose");
    musicAnimationController.dispose();
    dashboardController.stopController(dashboardService.pageIndex.value);
    dashboardService.postIds = [];
    super.dispose();
  }

  validateForm(Video videoObj, context) {
    if (dashboardController.formKey.currentState!.validate()) {
      dashboardController.formKey.currentState!.save();
      dashboardController.submitReport(videoObj, context);
    }
  }

  reportLayout(context, Video videoObj) {
    print("dashboardController.selectedType ${dashboardController.selectedType}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: mainService.setting.value.bgShade,
          title: dashboardController.showReportMsg.value
              ? Text("REPORT SUBMITTED!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ))
              : Text("REPORT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
          insetPadding: EdgeInsets.zero,
          content: Obx(
            () => Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: dashboardController.formKey,
              child: !dashboardController.showReportMsg.value
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Get.theme.highlightColor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                hint: new Text(
                                  "Select Type",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                                iconEnabledColor: Get.theme.iconTheme.color,
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                                value: dashboardController.selectedType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dashboardController.selectedType = newValue!;
                                  });
                                },
                                validator: (value) => value == null ? 'This field is required!' : null,
                                items: dashboardController.reportType.map((String val) {
                                  print("val $val");
                                  return new DropdownMenuItem(
                                    value: val,
                                    child: new Text(
                                      val,
                                      style: new TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          maxLines: 4,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15.0,
                            ),
                          ),
                          onChanged: (String val) {
                            setState(() {
                              dashboardService.videoReportDescription = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: Get.width - 100,
                          height: 30,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    "Block".text.color(Colors.white).size(16).make(),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: CupertinoSwitch(
                                    activeColor: Get.theme.highlightColor,
                                    value: dashboardService.videoReportBlocked.value,
                                    onChanged: (value) {
                                      dashboardService.videoReportBlocked.value = !dashboardService.videoReportBlocked.value;
                                      dashboardService.videoReportBlocked.refresh();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  setState(() {
                                    if (!dashboardController.showReportLoader.value) {
                                      validateForm(videoObj, context);
                                    }
                                  });
                                });
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(color: Get.theme.highlightColor),
                                child: Obx(
                                  () => Center(
                                    child: (!dashboardController.showReportLoader.value)
                                        ? Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: mainService.setting.value.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          )
                                        : CommonHelper.showLoaderSpinner(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                dashboardController.playController(dashboardService.pageIndex.value);

                                Get.back();
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(color: Get.theme.highlightColor),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: mainService.setting.value.buttonTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      fontFamily: 'RockWellStd',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: Get.width - 100,
                          child: Center(
                            child: Text(
                              "Thanks for reporting. If we find this content to be in violation of our Guidelines, we will remove it.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (dashboardController.pc.isPanelOpen) {
          dashboardController.pc.close();
          return Future.value(false);
        }
        if (mainService.userVideoObj.value.videoId > 0 || mainService.userVideoObj.value.userId > 0 || mainService.userVideoObj.value.hashTag != "" || mainService.userVideoObj.value.name != "") {
          mainService.userVideoObj.value.videoId = 0;
          mainService.userVideoObj.value.userId = 0;
          mainService.userVideoObj.value.name = "";
          mainService.userVideoObj.value.hashTag = "";
          dashboardController.stopController(dashboardService.pageIndex.value);

          dashboardService.postIds = [];
          Get.offNamed('/home');
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
      },
      child: Scaffold(
        // key: dashboardController.scaffoldKey,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Obx(
          () => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  if (dashboardService.randomString.value != "") {
                    dashboardService.randomString.value = CommonHelper.getRandomString(4, numeric: true);
                    dashboardService.randomString.refresh();
                  }
                  dashboardController.stopController(dashboardService.pageIndex.value);
                  Get.offNamed('/home');
                  dashboardService.postIds = [];
                  return dashboardController.getVideos();
                },
                child: homeWidget(),
              ),
              !dashboardController.isVideoInitialized.value
                  ? Container(
                      width: Get.width,
                      height: Get.height,
                    )
                  : Container(),
              !dashboardController.hideBottomBar.value
                  ? Positioned(
                      right: 10,
                      top: (mainService.userVideoObj.value.userId == 0 || mainService.userVideoObj.value.userId == 0) &&
                              (mainService.userVideoObj.value.videoId == 0 || mainService.userVideoObj.value.videoId == 0) &&
                              mainService.userVideoObj.value.hashTag == ""
                          ? Get.height * 0.052
                          : Get.height * 0.056,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed("/notifications");
                        },
                        child: Obx(
                          () => Stack(
                            children: [
                              Container(
                                width: Get.width * 0.15,
                                child: SvgPicture.asset(
                                  "assets/icons/notification.svg",
                                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 10,
                                child: authService.notificationsCount.value > 0
                                    ? Transform.translate(
                                        offset: Offset(-2, -6),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Get.theme.highlightColor,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Center(
                                            child: Text(
                                              authService.notificationsCount.value.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
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
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomToolbarWidget(index, PanelController pc3, PanelController pc2) {
    {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Obx(
                        () {
                          return IconButton(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.all(0),
                            icon: SvgPicture.asset(
                              dashboardController.showHomeLoader.value ? 'assets/icons/reloading.gif' : 'assets/icons/home.svg',
                              width: 28.0,
                              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            onPressed: () async {
                              if (!dashboardController.showHomeLoader.value) {
                                if (!dashboardService.showFollowingPage.value) {
                                  dashboardController.stopController(dashboardService.pageIndex.value);
                                } else {}
                                mainService.userVideoObj.value.userId = 0;
                                mainService.userVideoObj.value.videoId = 0;
                                mainService.userVideoObj.value.name = "";
                                mainService.userVideoObj.refresh();
                                dashboardController.showHomeLoader.value = true;
                                dashboardController.showHomeLoader.refresh();
                                await Future.delayed(
                                  Duration(seconds: 2),
                                );

                                dashboardService.postIds = [];
                                Get.offNamed('/home');
                                dashboardController.getVideos();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/hash-tag.svg',
                          width: 30.0,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                        onPressed: () async {
                          mainService.isOnHomePage.value = false;
                          mainService.isOnHomePage.refresh();

                          dashboardController.stopController(dashboardService.pageIndex.value);

                          dashboardService.postIds = [];
                          Get.offNamed('/hash-videos');
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.all(0),
                      icon: SvgPicture.asset(
                        'assets/icons/create-video.svg',
                        width: 20.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () async {
                        mainService.isOnHomePage.value = false;
                        mainService.isOnHomePage.refresh();
                        setState(() {
                          dashboardService.bottomPadding.value = 0.0;
                        });
                        if (!dashboardService.showFollowingPage.value) {
                          dashboardController.stopController(dashboardService.pageIndex.value);
                        } else {}
                        if (authService.currentUser.value.accessToken != '') {
                          videoRecorderService.isOnRecordingPage.value = true;
                          videoRecorderService.isOnRecordingPage.refresh();
                          dispose();
                          dashboardService.postIds = [];
                          Get.put(VideoRecorderController(), permanent: true);
                          Get.offNamed("/video-recorder");
                        } else {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => PasswordLoginView(userId: 0),
                          //   ),
                          // );
                        }
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/chat.svg',
                          width: 30.0,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                        onPressed: () async {
                          mainService.isOnHomePage.value = false;
                          mainService.isOnHomePage.refresh();
                          if (!dashboardService.showFollowingPage.value) {
                            dashboardController.stopController(dashboardService.pageIndex.value);
                          } else {}
                          setState(() {
                            dashboardService.bottomPadding.value = 0.0;
                          });

                          if (authService.currentUser.value.accessToken != '') {
                            Navigator.pushReplacementNamed(
                              context,
                              "/user-chats",
                            );
                          } else {
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PasswordLoginView(userId: 0),
                            //   ),
                            // );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/user.svg',
                          width: 30.0,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                        onPressed: () async {
                          mainService.isOnHomePage.value = false;
                          mainService.isOnHomePage.refresh();
                          if (!dashboardService.showFollowingPage.value) {
                            dashboardController.stopController(dashboardService.pageIndex.value);
                          } else {}
                          setState(() {
                            dashboardService.bottomPadding.value = 0.0;
                          });
                          if (!dashboardService.showFollowingPage.value) {
                            dashboardController.stopController(dashboardService.pageIndex.value);
                          } else {}
                          if (authService.currentUser.value.accessToken != "") {
                            Navigator.pushReplacementNamed(
                              context,
                              "/my-profile",
                            );
                          } else {
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PasswordLoginView(userId: 0),
                            //   ),
                            // );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  bool _keyboardVisible = false;
  Widget commentField() {
    // Video videoObj = dashboardService.videosData.value.videos.elementAt(dashboardService.pageIndex.value);
    return Obx(
      () => TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        obscureText: false,
        focusNode: dashboardController.inputNode,
        keyboardType: TextInputType.text,
        controller: dashboardController.commentController.value,
        onSaved: (String? val) {
          dashboardController.commentValue = val!;
        },
        onChanged: (String? val) {
          dashboardController.commentValue = val!;
        },
        onTap: () {
          setState(() {
            if (dashboardController.bannerShowOn.indexOf("1") > -1) {
              dashboardService.bottomPadding.value = 0;
            }
            dashboardController.textFieldMoveToUp = true;
            dashboardController.loadMoreUpdateView.value = true;
            dashboardController.loadMoreUpdateView.refresh();
            Timer(Duration(milliseconds: 200), () => setState(() {}));
          });
        },
        decoration: new InputDecoration(
          fillColor: Get.theme.shadowColor,
          filled: true,
          contentPadding: EdgeInsets.only(left: 20, top: 0),
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          hintText: "Add a comment",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                dashboardController.textFieldMoveToUp = false;
              });
              if (dashboardController.commentValue.trim() != '' && dashboardController.commentValue != "") {
                print("dashboardController.editedComment.value ${dashboardController.editedComment.value} videoObj!.videoId ${dashboardController.videoObj.value.videoId}");
                dashboardController.editedComment.value != ""
                    ? dashboardController.editComment(dashboardController.editedComment.value, dashboardController.videoObj.value.videoId, context)
                    : dashboardController.addComment(dashboardController.videoObj.value.videoId, context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 15),
              child: SvgPicture.asset(
                'assets/icons/send.svg',
                width: 15,
                height: 15,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(Get.theme.highlightColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget homeWidget() {
    {
      _keyboardVisible = View.of(context).viewInsets.bottom != 0;
      print("dashboardService.videosData.value.videos.isNotEmpty ${dashboardService.videosData.value.videos.isNotEmpty} ${Get.mediaQuery.viewInsets.bottom} ${View.of(context).viewInsets.bottom}");
      return (dashboardService.videosData.value.videos.isNotEmpty)
          ? Obx(
              () => SlidingUpPanel(
                  controller: dashboardController.pc,
                  minHeight: 0,
                  backdropEnabled: true,
                  color: Colors.black,
                  backdropColor: Colors.white,
                  padding: EdgeInsets.only(top: 20, bottom: 0),
                  maxHeight: Get.height * (_keyboardVisible ? 0.5 : 0.7),
                  header: Column(
                    children: [
                      Container(
                        width: Get.width,
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => LikeButton(
                                    size: 25,
                                    circleColor: CircleColor(start: Colors.transparent, end: Colors.transparent),
                                    bubblesColor: BubblesColor(
                                      dotPrimaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                                      dotSecondaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                                    ),
                                    likeBuilder: (bool isLiked) {
                                      return SvgPicture.asset(
                                        'assets/icons/liked.svg',
                                        width: 28.0,
                                        colorFilter: ColorFilter.mode(dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Colors.white, BlendMode.srcIn),
                                      );
                                    },
                                    onTap: dashboardController.onLikeButtonTapped,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  CommonHelper.formatter(dashboardController.videoObj.value.totalLikes.toString()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/chat.svg',
                                  width: 25,
                                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  CommonHelper.formatter(dashboardController.videoObj.value.totalComments.toString()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/views.svg',
                                  width: 25,
                                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  CommonHelper.formatter(dashboardController.videoObj.value.totalViews.toString()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Codec<String, String> stringToBase64 = utf8.fuse(base64);
                                String vId = stringToBase64.encode(dashboardController.videoObj.value.videoId.toString());
                                Share.share('$baseUrl$vId');
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/share.svg',
                                    width: 35,
                                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Container(
                        width: Get.width,
                        height: .5,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onPanelOpened: () async {
                    if (dashboardController.bannerShowOn.indexOf("1") > -1) {
                      dashboardController.showBannerAd.value = false;
                      dashboardController.showBannerAd.refresh();
                      _tempAdPadding = dashboardService.bottomPadding.value;
                      dashboardService.bottomPadding.value = 0;
                      dashboardService.bottomPadding.refresh();
                    }
                  },
                  onPanelClosed: () {
                    dashboardService.bottomPadding.value = _tempAdPadding;
                    dashboardService.bottomPadding.refresh();
                    dashboardController.showBannerAd.value = true;
                    dashboardController.showBannerAd.refresh();
                    setState(() {
                      if (dashboardController.bannerShowOn.indexOf("1") > -1) {
                        // dashboardService.bottomPadding.value = Platform.isAndroid ? 50.0 : 80.0;
                      }
                    });
                    dashboardController.textFieldMoveToUp = false;
                    FocusScope.of(context).unfocus();
                    // setState(() {
                    dashboardController.hideBottomBar.value = false;
                    dashboardController.hideBottomBar.refresh();
                    postService.commentsObj.value.comments = [];
                    // });

                    dashboardController.commentController.value = new TextEditingController(text: "");
                    dashboardController.loadMoreUpdateView.value = false;
                    dashboardController.loadMoreUpdateView.refresh();
                  },
                  panelBuilder: () => Padding(
                        padding: const EdgeInsets.only(top: 55, bottom: 0),
                        child: Obx(() {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: (postService.commentsObj.value.comments.length > 0)
                                          ? Obx(
                                              () => Padding(
                                                padding: postService.commentsObj.value.comments.length > 5
                                                    ? authService.currentUser.value.accessToken != ''
                                                        ? EdgeInsets.only(bottom: 10)
                                                        : EdgeInsets.zero
                                                    : EdgeInsets.zero,
                                                child: ListView.separated(
                                                  controller: dashboardController.scrollController,
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: postService.commentsObj.value.comments.length,
                                                  itemBuilder: (context, i) {
                                                    return Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: Get.width * (0.25),
                                                            child: InkWell(
                                                              onTap: () {
                                                                mainService.isOnHomePage.value = false;
                                                                mainService.isOnHomePage.refresh();
                                                                dashboardController.hideBottomBar.value = false;
                                                                dashboardController.hideBottomBar.refresh();
                                                                if (!dashboardService.showFollowingPage.value) {
                                                                  dashboardController.stopController(dashboardService.pageIndex.value);
                                                                } else {}
                                                                if (postService.commentsObj.value.comments.elementAt(i).userId == authService.currentUser.value.id) {
                                                                  dashboardService.currentPage.value = 4;
                                                                  dashboardService.currentPage.refresh();
                                                                  dashboardService.pageController.value
                                                                      .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                                  dashboardService.pageController.refresh();
                                                                } else {
                                                                  UserController userCon = Get.find();
                                                                  userCon.openUserProfile(postService.commentsObj.value.comments.elementAt(i).userId);
                                                                }
                                                              },
                                                              child: Container(
                                                                width: 60.0,
                                                                height: 60.0,
                                                                decoration: new BoxDecoration(
                                                                  border: Border.all(color: Colors.white, width: 2),
                                                                  shape: BoxShape.circle,
                                                                  image: new DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                    image: postService.commentsObj.value.comments.elementAt(i).userDp.isNotEmpty
                                                                        ? CachedNetworkImageProvider(
                                                                            postService.commentsObj.value.comments.elementAt(i).userDp,
                                                                            maxWidth: 120,
                                                                            maxHeight: 120,
                                                                          )
                                                                        : AssetImage(
                                                                            "assets/images/video-logo.png",
                                                                          ) as ImageProvider,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () {
                                                                        mainService.isOnHomePage.value = false;
                                                                        mainService.isOnHomePage.refresh();
                                                                        mainService.isOnHomePage.value = false;
                                                                        mainService.isOnHomePage.refresh();
                                                                        dashboardController.hideBottomBar.value = false;
                                                                        dashboardController.hideBottomBar.refresh();
                                                                        if (postService.commentsObj.value.comments.elementAt(i).userId == authService.currentUser.value.id) {
                                                                          dashboardService.currentPage.value = 4;
                                                                          dashboardService.currentPage.refresh();
                                                                          dashboardService.pageController.value
                                                                              .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                                          dashboardService.pageController.refresh();
                                                                        } else {
                                                                          UserController userCon = Get.find();
                                                                          userCon.openUserProfile(postService.commentsObj.value.comments.elementAt(i).userId);
                                                                        }
                                                                      },
                                                                      child: Row(
                                                                        children: [
                                                                          Text(
                                                                            postService.commentsObj.value.comments.elementAt(i).username,
                                                                            style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white,
                                                                              fontSize: 18.0,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: 5,
                                                                          ),
                                                                          postService.commentsObj.value.comments.elementAt(i).isVerified == true
                                                                              ? Icon(
                                                                                  Icons.verified,
                                                                                  color: Get.theme.highlightColor,
                                                                                  size: 16,
                                                                                )
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    authService.currentUser.value.id == postService.commentsObj.value.comments.elementAt(i).userId ||
                                                                            authService.currentUser.value.id == dashboardController.videoObj.value.userId
                                                                        ? Container(
                                                                            width: 50,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Container(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                  child: Text(
                                                                                    postService.commentsObj.value.comments.elementAt(i).time,
                                                                                    style: TextStyle(
                                                                                      color: Colors.white.withOpacity(0.5),
                                                                                      fontSize: 12.0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 20,
                                                                                  width: 18,
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                                                                  child: Center(
                                                                                    child: PopupMenuButton<int>(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                        color: Get.theme.shadowColor,
                                                                                        icon: Icon(
                                                                                          Icons.more_vert,
                                                                                          size: 18,
                                                                                          color: Colors.white.withOpacity(0.5),
                                                                                        ),
                                                                                        onSelected: (int) {
                                                                                          print("onSelected int $int");
                                                                                          if (int == 0) {
                                                                                            dashboardController.onEditComment(i, context);
                                                                                          } else {
                                                                                            PostController postController = Get.find();
                                                                                            postController.showDeleteAlert(
                                                                                                context,
                                                                                                "Delete Confirmation",
                                                                                                "Do you realy want to delete this comment",
                                                                                                postService.commentsObj.value.comments.elementAt(i).commentId,
                                                                                                dashboardController.videoObj.value.videoId);
                                                                                          }
                                                                                        },
                                                                                        itemBuilder: (context) {
                                                                                          return authService.currentUser.value.id == postService.commentsObj.value.comments.elementAt(i).userId
                                                                                              ? [
                                                                                                  PopupMenuItem(
                                                                                                    height: 15,
                                                                                                    value: 0,
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                                      child: Text(
                                                                                                        "Edit",
                                                                                                        style: TextStyle(
                                                                                                          color: Colors.white,
                                                                                                          // fontFamily: 'RockWellStd',
                                                                                                          fontSize: 12,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  PopupMenuItem(
                                                                                                    height: 15,
                                                                                                    value: 1,
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                                      child: Text(
                                                                                                        "Delete",
                                                                                                        style: TextStyle(
                                                                                                          color: Colors.white,
                                                                                                          fontSize: 12,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                ]
                                                                                              : [
                                                                                                  PopupMenuItem(
                                                                                                    height: 15,
                                                                                                    value: 1,
                                                                                                    child: Text(
                                                                                                      "Delete",
                                                                                                      style: TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        // fontFamily: 'RockWellStd',
                                                                                                        fontSize: 12,
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                ];
                                                                                        }),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                            child: Text(
                                                                              postService.commentsObj.value.comments.elementAt(i).time,
                                                                              style: TextStyle(
                                                                                color: Colors.white.withOpacity(0.5),
                                                                                fontSize: 12.0,
                                                                              ),
                                                                            ),
                                                                          )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  postService.commentsObj.value.comments.elementAt(i).comment,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 12.0,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder: (context, index) {
                                                    return Divider(
                                                      color: Colors.white,
                                                      thickness: 0.1,
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : (dashboardController.videoObj.value.totalComments > 0)
                                              ? SkeletonLoader(
                                                  builder: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10,
                                                    ),
                                                    child: Row(
                                                      children: <Widget>[
                                                        CircleAvatar(
                                                          backgroundColor: Colors.white,
                                                          radius: 18,
                                                        ),
                                                        SizedBox(width: 20),
                                                        Expanded(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Align(
                                                                alignment: Alignment.topLeft,
                                                                child: Container(
                                                                  height: 8,
                                                                  width: 80,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              SizedBox(height: 10),
                                                              Container(
                                                                width: double.infinity,
                                                                height: 8,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(height: 4),
                                                              Container(
                                                                width: double.infinity,
                                                                height: 8,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(height: 15),
                                                              Align(
                                                                alignment: Alignment.topLeft,
                                                                child: Container(
                                                                  width: 50,
                                                                  height: 9,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  items: dashboardController.videoObj.value.totalComments > 3 ? 3 : dashboardController.videoObj.value.totalComments,
                                                  period: Duration(seconds: 1),
                                                  highlightColor: Colors.white60,
                                                  direction: SkeletonDirection.ltr,
                                                )
                                              : Center(
                                                  child: Text(
                                                    "No comment available",
                                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 17, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                    ),
                                    dashboardController.commentsLoader.value
                                        ? CommonHelper.showLoaderSpinner(Colors.white)
                                        : SizedBox(
                                            height: 0,
                                          )
                                  ],
                                ),
                              ),
                              Container(
                                height: 0.1,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              authService.currentUser.value.accessToken != ''
                                  ? Container(
                                      padding: EdgeInsets.only(bottom: 20),
                                      height: 100,
                                      width: Get.width,
                                      child: Center(
                                        child: Obx(() {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: Get.width * 0.25,
                                                child: Center(
                                                  child: Container(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: authService.currentUser.value.userDP != ""
                                                          ? CachedNetworkImage(
                                                              imageUrl: authService.currentUser.value.userDP,
                                                              placeholder: (context, url) => Center(
                                                                child: CommonHelper.showLoaderSpinner(Colors.white),
                                                              ),
                                                              fit: BoxFit.fill,
                                                            )
                                                          : Image.asset(
                                                              "assets/images/video-logo.png",
                                                              width: 40,
                                                              height: 40,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: Get.width * 0.70,
                                                  child: commentField(),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                            ],
                          );
                        }),
                      ),
                  body: GetBuilder<DashboardController>(
                      initState: (_) => dashboardController.jumpToCurrentVideo(),
                      builder: (logic) {
                        return Obx(
                          () {
                            return Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: <Widget>[
                                PageView.builder(
                                  allowImplicitScrolling: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  controller: dashboardController.pageViewController.value,
                                  onPageChanged: (index) {
                                    print("onIndexChanged $index ${dashboardService.videosData.value.videos.length}");
                                    dashboardController.videoObj.value = dashboardService.videosData.value.videos.elementAt(index);
                                    dashboardService.pageIndex.value = index;
                                    dashboardController.videoObj.refresh();
                                    dashboardController.showProgress.value = false;
                                    dashboardController.showProgress.refresh();
                                    if (dashboardService.videosData.value.videos.length - index == 3) {
                                      dashboardController.listenForMoreVideos();
                                    }
                                  },
                                  restorationId: dashboardService.videosData.value.videos.elementAt(0).videoId.toString(),
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        print("Page index $index");
                                        dashboardController.onTap.value = true;
                                        dashboardController.onTap.refresh();
                                        dashboardController.playOrPauseVideo();
                                      },
                                      child: Stack(
                                        fit: StackFit.passthrough,
                                        children: <Widget>[
                                          Container(
                                            height: Get.height,
                                            width: Get.width,
                                            child: Center(
                                              child: Container(
                                                color: Colors.black,
                                                child: VideoPlayerWidgetV2(videoObj: dashboardService.videosData.value.videos.elementAt(index)),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              // Top section
                                              // Middle expanded
                                              Obx(
                                                () => Container(
                                                  padding: new EdgeInsets.only(
                                                    bottom: dashboardService.bottomPadding.value + Get.mediaQuery.viewPadding.bottom,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      VideoDescription(
                                                        dashboardService.videosData.value.videos.elementAt(index),
                                                        dashboardController.pc3,
                                                      ),
                                                      sidebar(index)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 60.0,
                                              ),
                                            ],
                                          ),
                                          (dashboardService.pageIndex.value == 0 && !dashboardController.initializePage)
                                              ? SafeArea(
                                                  child: Container(
                                                    height: Get.height / 4,
                                                    width: Get.width,
                                                    color: Colors.transparent,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    );
                                    // }
                                  },
                                  itemCount: dashboardService.videosData.value.videos.length,
                                  scrollDirection: Axis.vertical,
                                ),
                                Obx(() {
                                  return (mainService.userVideoObj.value.userId == 0 || mainService.userVideoObj.value.userId == 0) &&
                                          (mainService.userVideoObj.value.videoId == 0 || mainService.userVideoObj.value.videoId == 0) &&
                                          mainService.userVideoObj.value.hashTag == ""
                                      ? topSection()
                                      : Padding(
                                          padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 0,
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.arrow_back_ios,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () async {
                                                      if (mainService.userVideoObj.value.videoId != 0 && mainService.userVideoObj.value.userId == 0) {
                                                        mainService.userVideoObj.value.userId = 0;
                                                        mainService.userVideoObj.value.videoId = 0;
                                                        mainService.userVideoObj.value.hashTag = '';
                                                        mainService.userVideoObj.value.name = '';
                                                        mainService.userVideoObj.refresh();
                                                        dashboardService.postIds = [];
                                                        Get.offNamed('/home');
                                                        dashboardController.getVideos();
                                                      } else {
                                                        mainService.userVideoObj.value.userId = 0;
                                                        mainService.userVideoObj.value.videoId = 0;
                                                        mainService.userVideoObj.value.name = '';
                                                        mainService.userVideoObj.value.hashTag = '';
                                                        mainService.userVideoObj.refresh();
                                                        if (!dashboardService.showFollowingPage.value) {
                                                          dashboardController.stopController(dashboardService.pageIndex.value);
                                                        } else {}
                                                        // await dashboardController.getFollowingUserVideos();
                                                        dashboardService.postIds = [];
                                                        Get.offNamed('/home');
                                                        dashboardController.getVideos();
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Transform.translate(
                                                    offset: Offset(-10, 0),
                                                    child: Text(
                                                      mainService.userVideoObj.value.name != ""
                                                          ? mainService.userVideoObj.value.name + " Videos"
                                                          : mainService.userVideoObj.value.userId != 0
                                                              ? "My Videos"
                                                              : "",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                }),
                              ],
                            );
                          },
                        );
                      })),
            )
          : Container(
              decoration: BoxDecoration(color: Colors.black87),
              height: Get.height,
              width: Get.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  (!dashboardController.isLoading.value && dashboardService.showFollowingPage.value)
                      ? Container(
                          decoration: BoxDecoration(color: Colors.black87),
                          height: Get.mediaQuery.size.height,
                          width: Get.mediaQuery.size.width,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                if (authService.currentUser.value.accessToken != '') {
                                  dashboardService.postIds = [];
                                  Get.offNamed(
                                    '/users',
                                  );
                                } else {
                                  dashboardService.postIds = [];
                                  Get.offNamed(
                                    '/login',
                                  );
                                }
                              },
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(width: 2, color: Colors.white)),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "This is your feed of user you follow.",
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "You can follow people or subscribe to hashtags.",
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Icon(Icons.person_add, color: Colors.white, size: 45),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : dashboardController.isLoading.value
                          ? Center(
                              child: Center(
                                child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(color: Colors.black87),
                              height: Get.mediaQuery.size.height,
                              width: Get.mediaQuery.size.width,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "No Videos yet.",
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  Container(
                    height: 111,
                    width: Get.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Following",
                            style: TextStyle(
                              color: dashboardService.showFollowingPage.value ? Colors.white : Colors.white.withOpacity(0.8),
                              fontWeight: dashboardService.showFollowingPage.value ? FontWeight.w500 : FontWeight.w400,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 18,
                            width: 2,
                            color: mainService.setting.value.dividerColor != null ? mainService.setting.value.dividerColor : Colors.grey[400],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            child: Text(
                              "Featured",
                              style: TextStyle(
                                color: !dashboardService.showFollowingPage.value ? Colors.white : Colors.white.withOpacity(0.8),
                                fontWeight: !dashboardService.showFollowingPage.value ? FontWeight.w500 : FontWeight.w400,
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () async {
                              if (!dashboardService.showFollowingPage.value) {
                                dashboardController.stopController(dashboardService.pageIndex.value);
                              } else {
                                dashboardService.showFollowingPage.value = false;
                                dashboardService.showFollowingPage.refresh();
                              }
                              dashboardService.postIds = [];
                              Get.offNamed('/home');
                              dashboardController.getVideos();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
    }
  }

  Widget topSection() {
    return SafeArea(
      top: true,
      maintainBottomViewPadding: false,
      bottom: false,
      child: Container(
        color: Colors.black12,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 0),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Obx(() {
                      return Text("Following",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: dashboardService.showFollowingPage.value ? FontWeight.bold : FontWeight.w400,
                            fontSize: 16.0,
                          ));
                    }),
                    onTap: () async {
                      dashboardController.stopController(dashboardService.pageIndex.value);
                      dashboardService.showFollowingPage.value = true;
                      dashboardService.showFollowingPage.refresh();
                      dashboardService.postIds = [];
                      Get.offNamed('/home');
                      dashboardController.getVideos();
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 18,
                    width: 1,
                    color: mainService.setting.value.dividerColor != null ? mainService.setting.value.dividerColor : Colors.grey[400],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Obx(() {
                      return Text(
                        "Featured",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: dashboardService.showFollowingPage.value ? FontWeight.w400 : FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      );
                    }),
                    onTap: () async {
                      dashboardController.stopController(dashboardService.pageIndex.value);
                      dashboardService.showFollowingPage.value = false;
                      dashboardService.showFollowingPage.refresh();
                      dashboardService.postIds = [];
                      Get.offNamed('/home');
                      dashboardController.getVideos();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMusicPlayerAction(index) {
    return GestureDetector(
      onTap: () async {
        if (authService.currentUser.value.accessToken != '') {
          if (!dashboardService.showFollowingPage.value) {
            dashboardController.stopController(dashboardService.pageIndex.value);
          } else {}
          dashboardController.soundShowLoader.value = true;
          dashboardController.soundShowLoader.refresh();
          SoundController soundController = Get.find();
          SoundData sound = await soundController.getSound(dashboardController.videoObj.value.soundId);
          await soundController.selectSound(sound);
          dashboardController.soundShowLoader.value = false;
          dashboardController.soundShowLoader.refresh();
          videoRecorderService.isOnRecordingPage.value = true;
          videoRecorderService.isOnRecordingPage.refresh();
          dashboardService.postIds = [];
          Get.put(VideoRecorderController(), permanent: true);
          Get.offNamed("/video-recorder");
        } else {
          dashboardController.stopController(dashboardService.pageIndex.value);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => PasswordLoginView(userId: 0),
          //   ),
          // );
        }
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(musicAnimationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 50,
          height: 50,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
                child: Obx(() {
                  return (!dashboardController.soundShowLoader.value)
                      ? Container(
                          height: 45.0,
                          width: 45.0,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: dashboardController.videoObj.value.soundImageUrl != ""
                                ? CachedNetworkImage(
                                    imageUrl: dashboardController.videoObj.value.soundImageUrl,
                                    memCacheHeight: 50,
                                    memCacheWidth: 50,
                                    errorWidget: (a, b, c) {
                                      return Image.asset(
                                        "assets/images/splash.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/splash.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )
                      : CommonHelper.showLoaderSpinner(Colors.white);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sidebar(index) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    dashboardController.encodedVideoId = stringToBase64.encode(dashboardController.encKey + dashboardController.videoObj.value.videoId.toString());
    return Obx(
      () => Container(
        // padding: new EdgeInsets.only(bottom: dashboardService.paddingBottom.value - 30 > 0 ? dashboardService.paddingBottom.value - 30 : 0),
        width: 70.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(
            children: [
              LikeButton(
                size: 25,
                circleColor: CircleColor(start: Colors.transparent, end: Colors.transparent),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                  dotSecondaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                ),
                likeBuilder: (bool isLiked) {
                  return SvgPicture.asset(
                    'assets/icons/liked.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Colors.white, BlendMode.srcIn),
                  );
                },
                onTap: dashboardController.onLikeButtonTapped,
              ),
              Text(
                CommonHelper.formatter(dashboardController.videoObj.value.totalLikes.toString()),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 50.0,
                    width: 50.0,
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/comments.svg',
                        width: 25.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () {
                        if (dashboardController.bannerShowOn.indexOf("1") > -1) {
                          setState(() {
                            dashboardService.bottomPadding.value = 0;
                          });
                        }
                        dashboardController.hideBottomBar.value = true;
                        dashboardController.hideBottomBar.refresh();
                        dashboardController.videoIndex = index;
                        dashboardController.showBannerAd.value = false;
                        dashboardController.showBannerAd.refresh();
                        dashboardController.pc.open();
                        if (dashboardController.videoObj.value.totalComments > 0) {
                          dashboardController.getComments(dashboardController.videoObj.value).whenComplete(() {
                            Timer(Duration(seconds: 1), () => setState(() {}));
                          });
                        }
                      },
                    ),
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController.videoObj.value.totalComments.toString()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 35.0,
                    width: 50.0,
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(top: 0, bottom: 0, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/views.svg',
                        width: 25.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController.videoObj.value.totalViews.toString()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 50.0,
                width: 50.0,
                child: Obx(() {
                  return (!dashboardController.shareShowLoader.value)
                      ? IconButton(
                          alignment: Alignment.topCenter,
                          icon: SvgPicture.asset(
                            'assets/icons/share.svg',
                            width: 25.0,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          onPressed: () async {
                            Codec<String, String> stringToBase64 = utf8.fuse(base64);
                            String vId = stringToBase64.encode(dashboardController.videoObj.value.videoId.toString());
                            Share.share('$baseUrl$vId');
                          },
                        )
                      : CommonHelper.showLoaderSpinner(Colors.white);
                }),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 50.0,
                width: 50.0,
                child: IconButton(
                  alignment: Alignment.topCenter,
                  icon: SvgPicture.asset(
                    'assets/icons/report.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  onPressed: () async {
                    if (authService.currentUser.value.accessToken != '') {
                      dashboardController.showReportMsg.value = false;
                      dashboardController.showReportMsg.refresh();
                      reportLayout(context, dashboardController.videoObj.value);
                    } else {
                      dashboardController.stopController(dashboardService.pageIndex.value);
                      Get.offNamed("/login");
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          (dashboardController.videoObj.value.soundId > 0)
              ? _getMusicPlayerAction(index)
              : SizedBox(
                  height: 0,
                ),
          (dashboardController.videoObj.value.soundId > 0)
              ? Divider(
                  color: Colors.transparent,
                  height: 5.0,
                )
              : SizedBox(
                  height: 0,
                ),
        ]),
      ),
    );
  }
}
