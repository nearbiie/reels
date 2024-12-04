import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class VideoRecorder extends StatefulWidget {
  VideoRecorder({
    Key? key,
  }) {}
  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends State<VideoRecorder> with TickerProviderStateMixin {
  VideoRecorderController videoRecorderController = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
  SoundService soundService = Get.find();
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  DashboardService dashboardService = Get.find();

  @override
  void dispose() {
    print("Video Recorder Dispose");
    videoRecorderService.isOnRecordingPage.value = false;
    videoRecorderController.mainCameraController!.dispose();
    try {
      if (videoRecorderController.animationController != null) videoRecorderController.animationController!.dispose();
      if (videoRecorderController.videoController != null) videoRecorderController.videoController!.dispose();
    } catch (e) {}

    /*if (videoRecorderController.videoEditorController != null) {
      videoRecorderController.videoEditorController!.dispose();
      videoRecorderController.videoEditorController!.video.dispose();
    }*/
    videoRecorderController.mainCameraController!.dispose();
    // if (videoRecorderController.previewVideoController != null) videoRecorderController.previewVideoController!.dispose();
    videoRecorderService.videoProgressPercent.value = 0;
    videoRecorderService.videoProgressPercent.refresh();
    // videoRecorderController.isVideoRecorded = false;
    videoRecorderController.showProgressBar.value = false;
    videoRecorderController.showProgressBar.refresh();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState");
    // App state changed before we got the chance to initialize.
    if (!videoRecorderController.mainCameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      videoRecorderController.mainCameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (videoRecorderController.mainCameraController != null) {
        videoRecorderController.onCameraSwitched(videoRecorderController.mainCameraController!.description);
      }
    }
    // super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    videoRecorderController.getTimeLimits();
    videoRecorderController.initCamera();
    if (soundService.currentSound.value.soundId > 0) {
      videoRecorderController.saveAudio(soundService.currentSound.value.url);
    }
    videoRecorderService.isOnRecordingPage.value = true;
    super.initState();
    videoRecorderController.animationController = AnimationController(vsync: this, duration: Duration(seconds: videoRecorderController.seconds))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          videoRecorderController.animationController!.repeat(reverse: !videoRecorderController.reverse);
          setState(() {
            videoRecorderController.reverse = !videoRecorderController.reverse;
          });
        }
      });

    videoRecorderController.sizeAnimation = Tween<double>(begin: 70.0, end: 80.0).animate(videoRecorderController.animationController!);
    videoRecorderController.animationController!.forward();

    // unawaited(videoRecorderController.loadWatermark());
  }

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoRecorderController.videoController;

    return Container(
      width: Get.width,
      height: Get.height,
      child: videoRecorderController.videoController == null
          ? Container()
          : Stack(children: <Widget>[
              SizedBox.expand(
                child: (videoRecorderController.videoController == null)
                    ? Container()
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: videoRecorderController.videoController!.value.size.width,
                              height: videoRecorderController.videoController!.value.size.height,
                              child: Center(
                                child: Container(
                                  child: Center(
                                    child: AspectRatio(aspectRatio: localVideoController != null ? localVideoController.value.aspectRatio : 1.0, child: VideoPlayer(localVideoController!)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 50,
                right: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    videoRecorderController.videoController!.pause();
                    videoRecorderController.videoController!.dispose();
                    super.dispose();
                    videoRecorderController.mainCameraController!.dispose();
                    try {
                      if (videoRecorderController.animationController != null) videoRecorderController.animationController!.dispose();
                    } catch (e) {}
                    if (videoRecorderController.videoController != null) videoRecorderController.videoController!.dispose();
                    if (videoRecorderController.videoEditorController != null) {
                      videoRecorderController.videoEditorController!.dispose();
                      videoRecorderController.videoEditorController!.video.dispose();
                    }
                    if (videoRecorderController.previewVideoController != null) videoRecorderController.previewVideoController!.dispose();
                    videoRecorderService.outputVideoPath.value = videoRecorderController.thumbPath;
                    videoRecorderService.thumbImageUri.value = videoRecorderController.videoPath;
                    print("video-recorder");
                    Get.offNamed('/video-submit');
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    videoRecorderController.videoController!.pause();
                    soundService.currentSound.value = SoundData(soundId: 0, title: "");
                    soundService.currentSound.refresh();
                    dashboardService.showFollowingPage.value = false;
                    dashboardService.showFollowingPage.refresh();
                    dashboardController.getVideos();
                    Get.offNamed("/home");
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
            ]),
    );
  }

  Widget build(BuildContext context) {
    // var size = Get.mediaQuery.size;
    // if (size != null) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black54),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      // key: videoRecorderController.scaffoldKey,
      body: WillPopScope(
        onWillPop: () async => videoRecorderController.willPopScope(),
        child: SafeArea(
          child: videoRecorderController.mainCameraController == null
              ? Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    GestureDetector(
                      child: Center(
                        child: _cameraPreviewWidget(),
                      ),
                      onDoubleTap: () {
                        // _con.onSwitchCamera();
                      },
                    ),
                    Obx(
                      () {
                        return videoRecorderController.startTimerTiming.value > 0
                            ? Center(
                                child: Container(
                                  height: Get.height,
                                  width: Get.width,
                                  color: Get.theme.indicatorColor.withOpacity(0.3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${videoRecorderController.startTimerTiming.value}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 60,
                                          color: Get.theme.highlightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                    Positioned(
                      bottom: 35,
                      left: 85,
                      child: _cameraFlashRowWidget(),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: Get.width,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _captureControlRowWidget(),
                        ),
                      ),
                    ),
                    Obx(
                      () => videoRecorderController.cameraPreview.value &&
                              videoRecorderController.mainCameraController != null &&
                              videoRecorderController.mainCameraController!.value.isInitialized &&
                              !videoRecorderController.mainCameraController!.value.isRecordingVideo &&
                              !videoRecorderController.isCountDownTimerShown.value
                          ? Positioned(
                              bottom: 35,
                              left: 0,
                              child: _cameraTogglesRowWidget(),
                            )
                          : Container(),
                    ),
                    Obx(
                      () => videoRecorderController.cameraPreview.value &&
                              videoRecorderController.mainCameraController != null &&
                              videoRecorderController.mainCameraController!.value.isInitialized &&
                              !videoRecorderController.mainCameraController!.value.isRecordingVideo &&
                              !videoRecorderController.isCountDownTimerShown.value
                          ? Positioned(
                              bottom: 35,
                              right: 20,
                              child: InkWell(
                                child: SvgPicture.asset(
                                  'assets/icons/add_photo.svg',
                                  width: 35,
                                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                                onTap: () {
                                  videoRecorderController.uploadGalleryVideo();
                                },
                              ),
                            )
                          : Container(),
                    ),
                    Obx(
                      () => videoRecorderController.cameraPreview.value &&
                              (videoRecorderController.mainCameraController == null ||
                                  !videoRecorderController.mainCameraController!.value.isInitialized ||
                                  !videoRecorderController.mainCameraController!.value.isRecordingVideo) &&
                              !videoRecorderController.isCountDownTimerShown.value
                          ? Positioned(
                              bottom: 110,
                              child: Container(
                                width: Get.width,
                                child: Center(
                                  child: getTimerLimit(),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    ((videoRecorderController.mainCameraController != null || videoRecorderController.mainCameraController!.value.isInitialized) &&
                                !videoRecorderController.mainCameraController!.value.isRecordingVideo) &&
                            !videoRecorderController.isCountDownTimerShown.value
                        ? Positioned(
                            top: 80,
                            right: 15,
                            child: Container(
                              child: Center(
                                child: getStartTimer(),
                              ),
                            ),
                          )
                        : Container(),
                    Obx(
                      () => (videoRecorderController.showProgressBar.value)
                          ? Positioned(
                              top: 10,
                              child: Obx(() {
                                return LinearPercentIndicator(
                                  width: Get.width,
                                  lineHeight: 5.0,
                                  animationDuration: 100,
                                  percent: videoRecorderService.videoProgressPercent.value,
                                  progressColor: Colors.pink,
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  // progressColor: Colors.black,
                                );
                              }),
                            )
                          : Container(),
                    ),
                    Obx(
                      () => videoRecorderController.cameraPreview.value &&
                              (videoRecorderController.mainCameraController == null ||
                                  !videoRecorderController.mainCameraController!.value.isInitialized ||
                                  !videoRecorderController.mainCameraController!.value.isRecordingVideo) &&
                              !videoRecorderController.isCountDownTimerShown.value
                          ? Positioned(
                              top: 30,
                              child: Container(
                                width: Get.width,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    child: SizedBox(
                                      width: 140.0,
                                      child: MarqueeWidget(
                                        direction: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              soundService.currentSound.value.title == "" ? "Select Sound " : soundService.currentSound.value.title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Icon(
                                              Icons.queue_music,
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Get.offNamed("/sound-list");
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => SoundList(),
                                      //   ),
                                      // );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    (videoRecorderController.mainCameraController != null &&
                                videoRecorderController.mainCameraController!.value.isInitialized &&
                                videoRecorderController.mainCameraController!.value.isRecordingVideo) &&
                            !videoRecorderController.isCountDownTimerShown.value
                        ? Positioned(
                            bottom: 42,
                            right: 90,
                            child: Container(
                              width: Get.width,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox.fromSize(
                                  size: Size(
                                    30,
                                    30,
                                  ), // button width and height
                                  child: ClipOval(
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.pinkAccent, // splash color
                                          onTap: () {
                                            setState(() {
                                              videoRecorderController.reverse = videoRecorderController.reverse;
                                            });
                                            if (!videoRecorderController.videoRecorded) {
                                              videoRecorderController.onResumeButtonPressed(context);
                                              videoRecorderController.animationController!.forward();
                                            } else {
                                              videoRecorderController.onPauseButtonPressed(context);
                                              videoRecorderController.animationController!.stop();
                                            }
                                          },
                                          child: Container(
                                              color: Colors.white,
                                              width: 30,
                                              height: 30,
                                              child: SvgPicture.asset(
                                                !videoRecorderController.videoRecorded ? 'assets/icons/play.svg' : 'assets/icons/pause.svg',
                                                width: 30,
                                                height: 30,
                                                colorFilter: ColorFilter.mode(Get.theme.highlightColor, BlendMode.srcIn),
                                              ).centered()),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    /*(dashboardService.isUploading.value == true)
                            ? Container(
                                width: Get.width,
                                height: Get.height,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                ),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black87,
                                    ),
                                    width: 200,
                                    height: 170,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: <Widget>[
                                          Center(
                                            child: CircularPercentIndicator(
                                              progressColor: Colors.pink,
                                              percent: dashboardService.uploadProgress.value,
                                              radius: 120.0,
                                              lineWidth: 8.0,
                                              circularStrokeCap: CircularStrokeCap.round,
                                              center: Text(
                                                (dashboardService.uploadProgress.value * 100).toStringAsFixed(2) + "%",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),*/
                    Obx(() => videoRecorderController.cameraPreview.value &&
                            videoRecorderController.mainCameraController != null &&
                            videoRecorderController.mainCameraController!.value.isInitialized &&
                            !videoRecorderController.mainCameraController!.value.isRecordingVideo &&
                            !videoRecorderController.isCountDownTimerShown.value
                        ? Positioned(
                            top: 30,
                            left: 10,
                            child: Container(
                              width: Get.width,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: SizedBox(
                                  width: 35,
                                  child: Obx(() {
                                    return InkWell(
                                      child: SizedBox(
                                        width: 35,
                                        child: soundService.mic.value
                                            ? Image.asset(
                                                "assets/icons/microphone.png",
                                                height: 30,
                                              )
                                            : Image.asset(
                                                "assets/icons/microphone-mute.png",
                                                height: 30,
                                              ),
                                      ),
                                      onTap: () {
                                        soundService.mic.value = !soundService.mic.value;
                                        soundService.mic.refresh();
                                        videoRecorderController.onCameraSwitched(videoRecorderController.cameras[videoRecorderController.selectedCameraIdx]).then((void v) {});
                                      },
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container()),
                    _thumbnailWidget(),
                    videoRecorderController.videoController == null
                        ? Positioned(
                            top: 30,
                            right: 20,
                            child: GestureDetector(
                              onTap: () {
                                videoRecorderController.willPopScope();
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ],
                ),
        ),
      ),
    ); /*
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }*/
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = videoRecorderController.mainCameraController;
    return Obx(() => videoRecorderController.cameraPreview.value
        ? (cameraController == null || !cameraController.value.isInitialized)
            ? const Text(
                'Loading..',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w900,
                ),
              )
            : Listener(
                onPointerDown: (_) => videoRecorderController.pointers++,
                onPointerUp: (_) => videoRecorderController.pointers--,
                child: CameraPreview(
                  videoRecorderController.mainCameraController!,
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: videoRecorderController.handleScaleStart,
                      onScaleUpdate: videoRecorderController.handleScaleUpdate,
                      onTapDown: (details) => videoRecorderController.onViewFinderTap(details, constraints),
                    );
                  }),
                ),
              )
        : Container());
  }

  Widget _cameraTogglesRowWidget() {
    if (videoRecorderController.cameras.isEmpty) {
      return Row();
    }
    return Obx(
      () {
        return (!videoRecorderController.disableFlipButton.value)
            ? InkWell(
                child: SvgPicture.asset(
                  'assets/icons/flip.svg',
                  width: 30,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ).pOnly(left: 25),
                onTap: () {
                  videoRecorderController.onSwitchCamera();
                },
              )
            : Container();
      },
    );
  }

  Widget _cameraFlashRowWidget() {
    return Row();
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = videoRecorderController.mainCameraController;
    if (cameraController == null) {
      return Container();
    }
    return Obx(
      () => videoRecorderController.cameraPreview.value && cameraController.value.isInitialized
          ? !cameraController.value.isRecordingVideo && !videoRecorderController.isProcessing.value
              ? ClipOval(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {});
                                videoRecorderController.onRecordButtonPressed(context);
                                // videoRecorderController.controller!.refresh();
                              },
                              onDoubleTap: () {
                                if (cameraController.value.isInitialized && !cameraController.value.isRecordingVideo) {
                                  print("Camera Testing");
                                } else {
                                  print("else Camera Testing");
                                }
                              },
                              child: SvgPicture.asset(
                                "assets/icons/create-video.svg",
                                width: 70,
                                height: 70,
                                colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                              ),
                            ),
                          ), // icon
                        ],
                      ),
                    ),
                  ),
                )
              : AnimatedBuilder(
                  animation: videoRecorderController.sizeAnimation,
                  builder: (context, child) => SizedBox.fromSize(
                    size: Size(videoRecorderController.sizeAnimation.value, videoRecorderController.sizeAnimation.value), // button width and height
                    child: GestureDetector(
                      onTap: () {
                        setState(() {});
                        videoRecorderController.onStopButtonPressed();
                      },
                      onDoubleTap: () {
                        if (cameraController.value.isInitialized && !cameraController.value.isRecordingVideo) {
                          print("Camera Testing");
                        } else {
                          print("else Camera Testing");
                        }
                      },
                      child: SvgPicture.asset(
                        "assets/icons/video-stop.svg",
                        width: 50,
                        height: 50,
                        colorFilter: ColorFilter.mode(Colors.redAccent, BlendMode.srcIn),
                      ),
                    ),
                  ),
                )
          : Container(),
    );
  }

  Widget getTimerLimit() {
    List<Widget> list = <Widget>[];
    return Obx(() {
      videoRecorderController.videoTimerLimit.length = videoRecorderController.videoTimerLimit.length > 5 ? 5 : videoRecorderController.videoTimerLimit.length;
      list = <Widget>[];
      if (videoRecorderController.videoTimerLimit.length > 0) {
        for (var i = 0; i < videoRecorderController.videoTimerLimit.length; i++) {
          list.add(
            InkWell(
              onTap: () {
                if (videoRecorderService.selectedVideoLength.value != videoRecorderController.videoTimerLimit[i].toDouble()) {
                  videoRecorderService.selectedVideoLength.value = videoRecorderController.videoTimerLimit[i] > 300 ? 300 : videoRecorderController.videoTimerLimit[i];
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 9),
                height: 30,
                constraints: BoxConstraints(
                  minWidth: 30,
                ),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: (videoRecorderService.selectedVideoLength.value == videoRecorderController.videoTimerLimit[i]) ? Get.theme.highlightColor : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: (videoRecorderService.selectedVideoLength.value == videoRecorderController.videoTimerLimit[i])
                      ? Border.all(color: Colors.white, width: 2)
                      : Border.all(color: Colors.white70, width: 0),
                ),
                child: Center(
                  child: Text(
                    "${videoRecorderController.videoTimerLimit[i].toInt() > 300 ? 300 : videoRecorderController.videoTimerLimit[i].toInt()}s",
                    style: TextStyle(
                      color: (videoRecorderService.selectedVideoLength.value == videoRecorderController.videoTimerLimit[i]) ? mainService.setting.value.buttonTextColor : Colors.black,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Center(
          child: Container(
            width: Get.width,
            height: 70,
            child: videoRecorderController.videoTimerLimit.length > 0
                ? list.length > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: list,
                      )
                    : Container()
                : Container(),
          ),
        );
      } else {
        list.add(Container());
        return Container();
      }
    });
  }

  Widget getStartTimer() {
    List<Widget> list = <Widget>[];
    return !videoRecorderController.videoRecorded
        ? Obx(() {
            return (!videoRecorderController.showTimerTimings.value)
                ? Stack(
                    children: [
                      InkWell(
                        child: SvgPicture.asset(
                          'assets/icons/timer.svg',
                          width: 35,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                        onTap: () {
                          videoRecorderController.showTimerTimings.value = true;
                          videoRecorderController.showTimerTimings.refresh();
                        },
                      ),
                      videoRecorderController.startTimerTiming.value > 0
                          ? Positioned(
                              bottom: 0,
                              left: 0,
                              // width: 15,
                              child: Container(
                                  height: 15,
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: mainService.setting.value.buttonColor,
                                    borderRadius: BorderRadius.circular(6),
                                    // border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: "${videoRecorderController.startTimerTiming.value}s"
                                      .text
                                      .textStyle(TextStyle(fontSize: 8, color: mainService.setting.value.buttonTextColor, fontWeight: FontWeight.bold))
                                      .make()
                                      .centered()),
                            )
                          : SizedBox(),
                    ],
                  )
                : Obx(() {
                    videoRecorderController.startTimerLimits.length = videoRecorderController.startTimerLimits.length > 5 ? 5 : videoRecorderController.startTimerLimits.length;
                    list = <Widget>[];
                    if (videoRecorderController.startTimerLimits.length > 0) {
                      for (var i = 0; i < videoRecorderController.startTimerLimits.length; i++) {
                        list.add(
                          InkWell(
                            onTap: () {
                              videoRecorderController.startTimerTiming.value = videoRecorderController.startTimerLimits[i];
                              videoRecorderController.startTimerTiming.refresh();
                              videoRecorderController.showTimerTimings.value = false;
                              videoRecorderController.showTimerTimings.refresh();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 3),
                              height: 30,
                              width: 30,
                              constraints: BoxConstraints(
                                minWidth: 30,
                              ),
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: (videoRecorderService.selectedVideoLength.value == videoRecorderController.startTimerLimits[i]) ? Get.theme.highlightColor : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: (videoRecorderService.selectedVideoLength.value == videoRecorderController.startTimerLimits[i])
                                    ? Border.all(color: Colors.white, width: 2)
                                    : Border.all(color: Colors.white70, width: 0),
                              ),
                              child: Center(
                                child: videoRecorderController.startTimerLimits[i] == 0
                                    ? Icon(
                                        Icons.close,
                                        size: 12,
                                      )
                                    : Text(
                                        "${videoRecorderController.startTimerLimits[i].toInt()}s",
                                        style: TextStyle(
                                          color: (videoRecorderService.selectedVideoLength.value == videoRecorderController.startTimerLimits[i])
                                              ? mainService.setting.value.buttonTextColor
                                              : Colors.black,
                                          fontSize: 11,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              // height: 100,
                              child: videoRecorderController.startTimerLimits.length > 0
                                  ? list.length > 0
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: list,
                                        )
                                      : Container()
                                  : Container(),
                            ),
                            Stack(
                              children: [
                                InkWell(
                                  child: SvgPicture.asset(
                                    'assets/icons/timer.svg',
                                    width: 35,
                                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                  onTap: () {
                                    videoRecorderController.showTimerTimings.value = false;
                                    videoRecorderController.showTimerTimings.refresh();
                                  },
                                ),
                                videoRecorderController.startTimerTiming.value > 0
                                    ? Positioned(
                                        bottom: 0,
                                        left: 0,
                                        // width: 15,
                                        child: Container(
                                            height: 15,
                                            padding: EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: mainService.setting.value.buttonColor,
                                              borderRadius: BorderRadius.circular(6),
                                              // border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: "${videoRecorderController.startTimerTiming.value}s"
                                                .text
                                                .textStyle(
                                                  TextStyle(
                                                    fontSize: 8,
                                                    color: mainService.setting.value.buttonTextColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                                .make()
                                                .centered()),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          ],
                        ),
                      );
                    } else {
                      list.add(Container());
                      return Container();
                    }
                  });
          })
        : SizedBox();
  }
}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: VideoRecorder(),
    );
  }
}

Future<void> main() async {
  runApp(VideoRecorderApp());
}
