import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class VideoPreview extends StatefulWidget {
  VideoPreview({Key? key}) : super(key: key);
  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoRecorderService videoRecorderService = Get.find();
  VideoRecorderController videoRecorderController = Get.find();
  MainService mainService = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: Get.width,
        height: Get.height,
        child: videoRecorderController.previewVideoController == null
            ? Container()
            : InkWell(
                onTap: () {
                  if (videoRecorderController.previewVideoController!.value.isPlaying) {
                    videoRecorderController.previewVideoController!.pause();
                  } else {
                    videoRecorderController.previewVideoController!.play();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    SizedBox.expand(
                      child: (videoRecorderController.previewVideoController == null)
                          ? Container()
                          : Container(
                              color: Colors.black,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: SizedBox(
                                    width: videoRecorderController.previewVideoController!.value.size.width,
                                    height: videoRecorderController.previewVideoController!.value.size.height,
                                    child: Center(
                                      child: Container(
                                        child: Center(
                                          child: AspectRatio(
                                            aspectRatio: videoRecorderController.previewVideoController!.value.aspectRatio,
                                            child: VideoPlayer(
                                              videoRecorderController.previewVideoController!,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.play_circle_outline,
                          color: videoRecorderController.previewVideoController!.value.isPlaying ? Colors.transparent : mainService.setting.value.dashboardIconColor,
                          size: 80,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      right: 20,
                      child: RawMaterialButton(
                        onPressed: () {
                          videoRecorderController.previewVideoController!.dispose();
                          print("video-preview-page");
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
                        onPressed: () async {
                          videoRecorderService.outputVideoPath.value = videoRecorderService.outputVideoAfter1StepPath.value;
                          videoRecorderService.outputVideoPath.refresh();
                          VideoRecorderController videoRecorderController = Get.find();
                          videoRecorderController.previewVideoController!.pause();
                          var ret = await videoRecorderController.willPopScope();
                          if (ret == Future.value(true)) {
                            videoRecorderController.previewVideoController!.dispose();
                          }
                        },
                        /*onPressed: () {
                                    videoRecorderController.outputVideoPath.value = videoRecorderController.outputVideoAfter1StepPath.value;
                                    videoRecorderController.outputVideoPath.refresh();
                                    _videoController.dispose();
                                    videoRecorderController.previewVideoController!.pause();
                                    Get.back();
                                  },*/
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
                  ],
                ),
              ),
      ),
    );
  }
}
