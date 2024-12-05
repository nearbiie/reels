import 'dart:io';

// import 'package:animate_icons/animate_icons.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marqueer/marqueer.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../core.dart';

class VideoDescription extends StatefulWidget {
  final Video video;
  final PanelController pc3;
  VideoDescription(this.video, this.pc3);
  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription>
    with SingleTickerProviderStateMixin {
  String username = "";
  String description = "";
  String appToken = "";
  int soundId = 0;
  int loginId = 0;
  bool isLogin = false;

  // static const double ActionWidgetSize = 60.0;
  // static const double ProfileImageSize = 50.0;

  String soundImageUrl = "";

  String profileImageUrl = "";

  bool showFollowLoader = false;
  bool isVerified = false;
  MainService mainService = Get.find();
  DashboardService dashboardService = Get.find();
  AuthService authService = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.video.username;
    isVerified = widget.video.isVerified;
    // isVerified = true;
    description = widget.video.description;
    profileImageUrl = widget.video.userDP;

    print("CheckVerified $username ${widget.video.isVerified};");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // constraints: BoxConstraints(
        //   maxHeight: Get.height * (dashboardService.descriptionHeight.value / 100) + Get.mediaQuery.padding.bottom + dashboardService.paddingBottom,
        // ),
        padding: EdgeInsets.only(
            left: 15.0, bottom: Get.mediaQuery.viewPadding.bottom > 0 ? 10 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    mainService.isOnHomePage.value = false;
                    mainService.isOnHomePage.refresh();
                    if (widget.video.userId ==
                        authService.currentUser.value.id) {
                      dashboardService.currentPage.value = 4;
                      dashboardService.currentPage.refresh();
                      dashboardService.pageController.value.animateToPage(
                          dashboardService.currentPage.value,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.linear);
                      dashboardService.pageController.refresh();
                    } else {
                      UserController userCon = Get.find();
                      userCon.openUserProfile(widget.video.userId);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        // color: mainService.setting.value.dpBorderColor!,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: profileImageUrl != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              imageUrl: profileImageUrl,
                              placeholder: (context, url) =>
                                  CommonHelper.showLoaderSpinner(
                                      Get.theme.iconTheme.color!),
                              height: 45.0 * (Platform.isIOS ? 1.2 : 1),
                              width: 45.0 * (Platform.isIOS ? 1.2 : 1),
                              fit: BoxFit.fitHeight,
                              errorWidget: (a, b, c) {
                                return Image.asset(
                                  "assets/images/video-logo.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.asset(
                              "assets/images/splash.png",
                              height: 45.0,
                              width: 45.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                username != ''
                    ? GestureDetector(
                        onTap: () async {
                          mainService.isOnHomePage.value = false;
                          mainService.isOnHomePage.refresh();

                          if (widget.video.userId ==
                              authService.currentUser.value.id) {
                            dashboardService.currentPage.value = 4;
                            dashboardService.currentPage.refresh();
                            dashboardService.pageController.value.animateToPage(
                                dashboardService.currentPage.value,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.linear);
                            dashboardService.pageController.refresh();
                          } else {
                            UserController userCon = Get.find();
                            userCon.openUserProfile(widget.video.userId);
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: mainService.setting.value.headingColor,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            isVerified == true
                                ? Icon(
                                    Icons.verified,
                                    color: Colors.blueAccent,
                                    size: 16,
                                  )
                                : Container(),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            (widget.video.userId != authService.currentUser.value.id)
                ? Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        dashboardController.showFollowLoader.value
                            ? Container(
                                height: 25,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: Get.theme.highlightColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: showLoaderSpinner(),
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  if (authService
                                          .currentUser.value.accessToken !=
                                      "") {
                                    await dashboardController
                                        .followUnfollowUser();
                                  } else {
                                    mainService.isOnHomePage.value = false;

                                    dashboardController.stopController(
                                        dashboardService.pageIndex.value);
                                    Get.offNamed('/login');
                                  }
                                },
                                child: Container(
                                  height: 25,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Get.theme.highlightColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    child: !dashboardController
                                            .showFollowLoader.value
                                        ? Text(
                                            (dashboardService
                                                        .videosData.value.videos
                                                        .elementAt(
                                                            dashboardService
                                                                .pageIndex
                                                                .value)
                                                        .isFollowing ==
                                                    0)
                                                ? "Follow".tr
                                                : "Unfollow".tr,
                                            style: TextStyle(
                                              color: mainService.setting.value
                                                  .buttonTextColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                          )
                                        : showLoaderSpinner(),
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 10,
                        ),
                        widget.video.totalFollowers > 0
                            ? Text(
                                "${CommonHelper.formatter(widget.video.totalFollowers.toString())} " +
                                    (widget.video.totalFollowers > 1
                                        ? "Followers".tr
                                        : "Follower".tr),
                                style: TextStyle(
                                  color: Get.theme.primaryColor,
                                  fontSize: 12,
                                ),
                              )
                            : Container(),
                        description.length > 55
                            ? InkWell(
                                onTap: () {
                                  dashboardService.descriptionHeight.value =
                                      dashboardService
                                                  .descriptionHeight.value ==
                                              18.0
                                          ? 40.0
                                          : 18.0;
                                  dashboardService.descriptionHeight.refresh();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, left: 3, right: 3),
                                  child: Icon(
                                    dashboardService.descriptionHeight.value ==
                                            18.0
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Get.theme.indicatorColor,
                                    size: 18,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  })
                : Container(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: description != ''
                  ? ExpandableNotifier(
                      controller: dashboardController.expandController,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: (Get.height *
                              (dashboardService.descriptionHeight.value / 100)),
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect rect) {
                            return const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black87,
                                Colors.black,
                                Colors.black,
                                Colors.black87,
                                Colors.black54,
                                Colors.black45,
                                Colors.black38
                              ],
                              stops: [
                                0.0,
                                0.03,
                                0.09,
                                0.7,
                                0.8,
                                0.9,
                                0.95,
                                1.0
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, //.horizontal
                            child: Builder(builder: (context) {
                              dashboardController.expandController =
                                  ExpandableController.of(context,
                                      required: true)!;
                              return ExpandablePanel(
                                controller:
                                    dashboardController.expandController,
                                collapsed: DetectableText(
                                  trimMode: TrimMode.Length,
                                  trimExpandedText: " " + "show less".tr,
                                  trimCollapsedText: " " + "read more".tr,
                                  text: "$description",
                                  detectedStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.highlightColor,
                                  ),
                                  basicStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.primaryColor
                                        .withOpacity(0.85),
                                  ),
                                  onTap: (text) {
                                    dashboardController.onLinkTap(text);
                                  },
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  detectionRegExp: detectionRegExp(url: false)!,
                                ),
                                expanded: DetectableText(
                                  detectionRegExp: detectionRegExp(url: false)!,
                                  text: "$description",
                                  detectedStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.highlightColor,
                                  ),
                                  basicStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.primaryColor,
                                  ),
                                  onTap: (text) {
                                    dashboardController.onLinkTap(text);
                                  },
                                  softWrap: true,
                                ),
                              ).onInkTap(() {
                                dashboardController.expandController!.toggle();
                              });
                            }),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
            // description.text.make(),
            SizedBox(
              height: 10.0,
            ),
            Container(
              height: 35,
              margin: EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () async {
                  if (authService.currentUser.value.accessToken != "") {
                    // dashboardController.videoController(dashboardController.swiperIndex).pause();
                    SoundController soundController = Get.find();
                    dashboardController.soundShowLoader.value = true;
                    dashboardController.soundShowLoader.refresh();
                    SoundData sound =
                        await soundController.getSound(widget.video.soundId);
                    soundController.selectSound(sound);
                    dashboardController.soundShowLoader.value = false;
                    dashboardController.soundShowLoader.refresh();
                    mainService.isOnRecordingPage.value = true;
                    mainService.isOnRecordingPage.refresh();
                    Get.put(VideoRecorderController(), permanent: true);
                    Get.offNamed("/video-recorder");
                  } else {
                    // dashboardController.videoController(dashboardController.swiperIndex).pause();
                    Get.offNamed("/login");
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    /*Image.asset(
                            "assets/icons/music-icon.png",
                            height: 10,
                          ),*/
                    SvgPicture.asset(
                      'assets/icons/music.svg',
                      height: 12.0,
                      colorFilter: ColorFilter.mode(
                          Get.theme.primaryColor, BlendMode.srcIn),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: 140.0,
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                      child: Marqueer(
                        child: (CommonHelper.isNumeric(
                                      widget.video.soundTitle.replaceAll(
                                        '.mp3',
                                        '',
                                      ),
                                    ) ||
                                    widget.video.soundTitle == ""
                                ? " - ${'Original Sound'.tr} " +
                                    (widget.video.soundUsername != ""
                                        ? "@${widget.video.soundUsername}"
                                        : "") +
                                    "       "
                                : " - @" +
                                    (widget.video.soundUsername == ""
                                        ? "NoUser"
                                        : widget.video.soundUsername) +
                                    " " +
                                    widget.video.soundTitle
                                        .replaceAll('.mp3', '') +
                                    "       ")
                            .text
                            .textStyle(
                              TextStyle(
                                color: mainService
                                    .setting.value.dashboardIconColor!
                                    .withOpacity(0.8),
                                fontSize: 14,
                              ),
                            )
                            .make(),
                        direction: MarqueerDirection.rtl,

                        /// optional

                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // blankSpace: 5.0,
                        // velocity: 100.0,
                        // pauseAfterRound: Duration(milliseconds: 30),
                        // startPadding: 0.0,
                        // accelerationDuration: Duration(seconds: 1),
                        // accelerationCurve: Curves.linear,
                        // decelerationDuration: Duration(milliseconds: 500),
                        // decelerationCurve: Curves.linear,
                        // padding: EdgeInsets.zero,
                        infinity: true,
                        separatorBuilder: (context, i) => SizedBox(
                          width: 5,
                        ),
                        interaction: true,
                        // pps: ,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  Widget _getMusicPlayerAction() {
    return GestureDetector(
      onTap: () {
        print(soundId);
        (isLogin)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRecorder(soundId),
                ),
              )
            : widget.pc3.open();
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: ActionWidgetSize,
          height: ActionWidgetSize,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: ProfileImageSize,
                width: ProfileImageSize,
                decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(ProfileImageSize / 2),
                ),
                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: mainService.setting.value.dashboardIconColor30,
                    borderRadius: BorderRadius.circular(50),
                    image: new DecorationImage(
                      image: new CachedNetworkImageProvider(soundImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  showLoaderSpinner() {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(
              mainService.setting.value.dashboardIconColor!),
        ),
      ),
    );
  }

  LinearGradient get musicGradient => LinearGradient(colors: [
        Colors.grey[800]!,
        Colors.grey[900]!,
        Colors.grey[900]!,
        Colors.grey[800]!
      ], stops: [
        0.0,
        0.4,
        0.6,
        1.0
      ], begin: Alignment.bottomLeft, end: Alignment.topRight);
}
