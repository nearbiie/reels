import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:helpers/helpers.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
class VideoEditor extends StatefulWidget {
  VideoEditor({
    Key? key,
  }) : super(key: key);

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  VideoRecorderController controller = Get.find();
  MainService mainService = Get.find();
  VideoRecorderService videoRecorderService = Get.find();

  @override
  void initState() {
    print("sdfsdfsdfsdf");
    controller.isVideoRecorded = true;
    try {
      controller.videoEditorController =
          VideoEditorController.file(File(videoRecorderService.outputVideoPath.value), maxDuration: Duration(seconds: videoRecorderService.selectedVideoLength.value.toInt()))
            ..initialize().whenComplete(() {
              print("IsINinstialized");
              setState(() {});
            });
      print("sdfsdfsdfsdf2");
      controller.videoEditorController!.addListener(() {
        if (controller.videoEditorController!.minTrim > 0.0 ||
            controller.videoEditorController!.maxTrim < 0.99 ||
            controller.videoEditorController!.minCrop != Offset.zero ||
            controller.videoEditorController!.maxCrop != Offset(1.0, 1.0) ||
            controller.videoEditorController!.rotation > 0) {
          controller.showEditorDone.value = true;
          controller.showEditorDone.refresh();
        } else {
          controller.showEditorDone.value = false;
          controller.showEditorDone.refresh();
        }
      });
    } catch (e, s) {
      print("videoEditorController error $e $s");
    }
    super.initState();
  }

  @override
  void dispose() {
    print("videoEditorController dispose");
    // controller.videoEditorController!.dispose();
    // controller.videoEditorController!.video.dispose();
    // if (controller.previewVideoController != null) controller.previewVideoController!.dispose();
    super.dispose();
  }

  void openCropScreen() => Get.to(CropScreen(controller: controller.videoEditorController!));

  void exportVideo() async {
    controller.isExporting.value = true;
    bool _firstStat = true;
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    await controller.videoEditorController!.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",

      onProgress: (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          // controller.exportingProgress.value = statics.getTime() / videoRecorderController.videoEditorController!.video.value.duration.inMilliseconds;
          controller.exportingProgress.value = statics.getTime() / videoRecorderService.selectedVideoLength.value * 1000;
        }
      },
      onCompleted: (file) {
        controller.isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          final VideoPlayerController _videoController = VideoPlayerController.file(file);
          _videoController.initialize().then((value) async {
            setState(() {});
            _videoController.play();
            _videoController.setLooping(true);
            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.black54,
              builder: (_) => AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            );
            await _videoController.pause();
            _videoController.dispose();
          });
          controller.exportText = "Video success export!";
          setState(() {
            controller.videoPath = file.path;
            controller.watermark = controller.watermark;
          });
        } else {
          controller.exportText = "Error on export video :(";
        }
      },
    );
  }

  /*void exportCover() async {
    setState(() => _exported = false);
    await videoRecorderController.videoEditorController.extractCover(
      onCompleted: (cover) {
        if (!mounted) return;

        if (cover != null) {
          _exportText = "Cover exported! ${cover.path}";
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.black54,
            builder: (BuildContext context) => Image.memory(cover.readAsBytesSync()),
          );
        } else
          _exportText = "Error on cover exportation :(";

        setState(() => _exported = true);
        Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => controller.willPopScope(),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: false,
        /* appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: SizedBox(
            height: 10,
          ),
        ),*/
        extendBody: false,
        body: SafeArea(
          child: controller.videoEditorController!.initialized
              ? Stack(
                  children: [
                    Obx(
                      () => Column(
                        children: [
                          !controller.showTextFilter.value ? _topNavBar(context) : Container(),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CropGridViewer(
                                        controller: controller.videoEditorController!,
                                        showGrid: false,
                                      ),
                                      AnimatedBuilder(
                                        animation: controller.videoEditorController!.video,
                                        builder: (_, __) => OpacityTransition(
                                          visible: !controller.videoEditorController!.isPlaying,
                                          child: GestureDetector(
                                            onTap: controller.videoEditorController!.video.play,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.play_arrow, color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 135,
                                  margin: EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: _trimSlider(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // _customSnackBar(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => OpacityTransition(
                        visible: controller.isExporting.value,
                        child: AlertDialog(backgroundColor: Colors.white, title: "Exporting video ${(controller.exportingProgress.value * 100).ceil()}%".text.bold.color(Colors.white).make()),
                      ),
                    )
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _topNavBar(BuildContext context) {
    return SafeArea(
      child: Container(
        height: controller.height,
        child: Row(
          children: [
            Expanded(
              child:

                  /// close button
                  InkWell(
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        controller.willPopScope();
                      }),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.videoEditorController!.rotate90Degrees(RotateDirection.left),
                child: Icon(Icons.rotate_left, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.videoEditorController!.rotate90Degrees(RotateDirection.right),
                child: Icon(Icons.rotate_right, color: Colors.white),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: openCropScreen,
                child: Icon(
                  Icons.crop,
                  color: Colors.white,
                ),
              ),
            ),
            Obx(
              () => controller.showEditorDone.value
                  ? Expanded(
                      child: InkWell(
                        onTap: () {
                          print(
                              "videoRecorderController.videoEditorController!.minTrim ${controller.videoEditorController!.minTrim} ||  videoRecorderController.videoEditorController!.maxTrim ${controller.videoEditorController!.maxTrim} || videoRecorderController.videoEditorController!.minCrop ${controller.videoEditorController!.minCrop} || videoRecorderController.videoEditorController!.maxCrop ${controller.videoEditorController!.maxCrop} || videoRecorderController.videoEditorController!.rotation ${controller.videoEditorController!.rotation}");
                          if (controller.videoEditorController!.minTrim > 0.0 ||
                              controller.videoEditorController!.maxTrim < 0.99 ||
                              controller.videoEditorController!.minCrop != Offset.zero ||
                              controller.videoEditorController!.maxCrop != Offset(1.0, 1.0) ||
                              controller.videoEditorController!.rotation > 0) {
                            controller.nextStep(context);
                          } else {
                            Fluttertoast.showToast(msg: "First make few changes to save");
                          }
                        },
                        child: "Skip".text.color(Colors.white).make().centered(),
                      ),
                    )
                  : Container(),
            ),
            /*videoRecorderController.videoEditorController!.video.value.duration.inSeconds <= videoRecorderService.selectedVideoLength.value
                ? */
            Expanded(
              child: InkWell(
                onTap: () async {
                  print("videoRecorderController.videoEditorController.video.dataSource ${controller.videoEditorController!.video.dataSource} ${videoRecorderService.selectedVideoLength.value}");
                  String filePath = "";
                  if (controller.videoEditorController!.video.value.duration.inSeconds > videoRecorderService.selectedVideoLength.value) {
                    print("abc1");
                    controller.trimVideoToMaxLength(controller.videoEditorController!.video.dataSource, onComplete: () async {
                      filePath = videoRecorderService.outputVideoPath.value;
                      controller.previewVideoController = VideoPlayerController.file(File(filePath));
                      await controller.previewVideoController!.initialize();
                      controller.videoEditorController!.video.dispose();
                      videoRecorderService.outputVideoDurationInMilliSeconds.value = controller.previewVideoController!.value.duration.inMilliseconds;
                      controller.previewVideoController!.play();
                      controller.previewVideoController!.setLooping(true);
                      print("abc31");
                      setState(() {});

                      controller.showTextFilter.value = true;
                      controller.showTextFilter.refresh();
                      controller.openStoriesEditor();
                    });
                  } else {
                    print("abc2 ${controller.videoEditorController!.video.dataSource}");
                    controller.previewVideoController = controller.videoEditorController!.video;
                    videoRecorderService.outputVideoDurationInMilliSeconds.value = controller.videoEditorController!.video.value.duration.inMilliseconds;
                    print("abc32");
                    setState(() {});

                    controller.showTextFilter.value = true;
                    controller.showTextFilter.refresh();
                    /*videoRecorderService.outputVideoPath.value = File(videoRecorderController.videoEditorController.video.dataSource).path;
                    videoRecorderService.outputVideoPath.refresh();*/
                    controller.openStoriesEditor();
                  }
                },
                child: "Done".text.color(Colors.white).make().centered(),
              ),
            ) /*: Container()*/,
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [duration.inMinutes.remainder(60).toString().padLeft(2, '0'), duration.inSeconds.remainder(60).toString().padLeft(2, '0')].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: controller.videoEditorController!.video,
        builder: (_, __) {
          final duration = controller.videoEditorController!.video.value.duration.inSeconds;
          final pos = controller.videoEditorController!.trimPosition * duration;
          final start = controller.videoEditorController!.minTrim * duration;
          final end = controller.videoEditorController!.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: controller.height / 4),
            child: Row(
              children: [
                formatter(Duration(seconds: pos.toInt())).text.bold.color(Colors.white).make(),
                Expanded(child: SizedBox()),
                OpacityTransition(
                  visible: !controller.videoEditorController!.isTrimming,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      "Start:".text.color(Colors.white).make(),
                      SizedBox(width: 2),
                      formatter(
                        Duration(
                          seconds: start.toInt(),
                        ),
                      ).text.color(Colors.white).make(),
                      SizedBox(width: 10),
                      "End:".text.bold.color(Colors.white).make(),
                      SizedBox(width: 2),
                      formatter(Duration(
                        seconds: end.toInt(),
                      )).text.bold.color(Colors.white).make(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      Container(
        width: Get.width,
        margin: EdgeInsets.symmetric(vertical: controller.height / 5),
        child: TrimSlider(
            child: TrimTimeline(controller: controller.videoEditorController!, margin: EdgeInsets.only(top: 10)),
            controller: controller.videoEditorController!,
            height: controller.height,
            horizontalMargin: controller.height / 5),
      )
    ];
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatefulWidget {
  final VideoEditorController controller;
  CropScreen({Key? key, required this.controller}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  VideoRecorderController videoRecorderController = Get.find();
  MainService mainService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: videoRecorderController.videoEditorViewKey,
      body: SafeArea(
        child: Column(children: [
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => widget.controller.rotate90Degrees(RotateDirection.left),
                child: Icon(Icons.rotate_left),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => widget.controller.rotate90Degrees(RotateDirection.right),
                child: Icon(Icons.rotate_right),
              ),
            )
          ]),
          SizedBox(height: 5),
          Expanded(
            child: AnimatedInteractiveViewer(
              maxScale: 2.4,
              child: CropGridViewer(
                controller: widget.controller,
                horizontalMargin: 0,
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Center(
                  child: "CANCEL".text.bold.color(Colors.white).make(),
                ),
              ),
            ),
            buildSplashTap("16:9", 16 / 9, padding: EdgeInsets.symmetric(horizontal: 10)),
            buildSplashTap("1:1", 1 / 1),
            buildSplashTap("4:5", 4 / 5, padding: EdgeInsets.symmetric(horizontal: 10)),
            buildSplashTap("NO", null, padding: EdgeInsets.only(right: 10)),
            Expanded(
              child: InkWell(
                onTap: () {
                  //2 WAYS TO UPDATE CROP
                  //WAY 1:
                  widget.controller.updateCrop();
                  /*WAY 2:
                  controller.minCrop = controller.cacheMinCrop;
                  controller.maxCrop = controller.cacheMaxCrop;
                  */
                  Get.back();
                },
                child: Center(
                  child: "OK".text.color(Colors.white).make(),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget buildSplashTap(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
  }) {
    return SplashTap(
      onTap: () => widget.controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.aspect_ratio, color: Colors.white),
            title.text.color(Colors.white).make(),
          ],
        ),
      ),
    );
  }
}
