import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class StoresEditorView extends StatefulWidget {
  const StoresEditorView({Key? key}) : super(key: key);

  @override
  State<StoresEditorView> createState() => _StoresEditorViewState();
}

class _StoresEditorViewState extends State<StoresEditorView> {
  VideoRecorderController videoRecorderController = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
/*  @override
  void initState() {
    videoRecorderController.previewVideoController = VideoPlayerController.file(File(videoRecorderService.outputVideoAfter1StepPath.value));
    videoRecorderController.previewVideoController!.initialize().whenComplete(() {
      setState(() {});
      videoRecorderController.previewVideoController!.play();
      videoRecorderController.previewVideoController!.setLooping(true);
    });
    // TODO: implement initState
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          minimum: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                width: videoRecorderController.previewVideoController!.value.size.width,
                height: videoRecorderController.previewVideoController!.value.size.height,
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
    );
  }
}
