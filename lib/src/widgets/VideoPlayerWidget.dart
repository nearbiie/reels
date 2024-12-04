import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core.dart';

class VideoPlayerWidgetV2 extends StatefulWidget {
  final Video videoObj;
  VideoPlayerWidgetV2({
    Key? key,
    required this.videoObj,
  }) : super(key: key);
  @override
  _VideoPlayerWidgetV2State createState() => _VideoPlayerWidgetV2State();
}

class _VideoPlayerWidgetV2State extends State<VideoPlayerWidgetV2> with SingleTickerProviderStateMixin {
  late VideoPlayerController? _controller;
  // var muted = true.obs;
  MainService mainService = Get.find();
  /*Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context).loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(fileContents); // For vtt files, use WebVTTCaptionFile
  }*/
  late VoidCallback listener;
  DashboardController dashboardController = Get.find();
  DashboardService dashboardService = Get.find();
  @override
  void initState() {
    super.initState();
    dashboardController.onTap.value = false;
    dashboardController.onTap.refresh();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoObj.url),
      // closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    listener = () {
      if (mounted) setState(() {});
      // double trackPercentage = (_controller!.value.position.inMilliseconds / _controller!.value.duration.inMilliseconds) * 100;
      // print("trackPercentage $trackPercentage ${_controller!.value.position.inMilliseconds}");
      if (_controller!.value.position.inSeconds == 5) {
        // chkVideo = 1;
        dashboardController.incrementVideoViews(widget.videoObj);
      } else if (dashboardService.currentVideoId == widget.videoObj.videoId && _controller!.value.position == _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
        _controller!.removeListener(listener);
        // Future.delayed(Duration(seconds: 1));
        _controller!.addListener(listener);

        _controller!.play();

        dashboardController.incrementVideoViews(widget.videoObj);
        return;
      }
    };
    _controller!.setLooping(false);
    _controller!.initialize();
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    print("dispose VideoController");
    if (dashboardService.videoControllers.containsKey(widget.videoObj.videoId)) {
      dashboardService.videoControllers[widget.videoObj.videoId]!.videoCon!.dispose();
      dashboardService.videoControllers.removeWhere((key, value) => key == widget.videoObj.videoId);
    }
    _controller!.removeListener(listener);
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: dashboardService.bottomPadding.value),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Center(
            child: widget.videoObj.aspectRatio > 0.8
                ? VisibilityDetector(
                    key: Key("${widget.videoObj.videoId}"),
                    onVisibilityChanged: (info) {
                      print("onVisibilityChanged1 ${info.visibleFraction} ${widget.videoObj.videoId}");
                      setState(() {
                        dashboardService.currentVideoId = widget.videoObj.videoId;
                      });

                      if (info.visibleFraction >= 0.4) {
                        print("_controller $_controller");
                        setState(() {
                          dashboardService.currentVideoId = widget.videoObj.videoId;
                        });
                        if (!dashboardService.videoPaused.value) {
                          _controller!.play();
                        }
                        dashboardService.currentVideoPlayer.value = _controller!;
                        dashboardService.currentVideoPlayer.refresh();
                      } else {
                        _controller!.pause();
                      }
                      if (mounted) setState(() {});
                    },
                    child: VideoPlayer(_controller!),
                  )
                : SizedBox.expand(
                    child: FittedBox(
                      fit: _controller!.value.size.height > _controller!.value.size.width ? BoxFit.fitHeight : BoxFit.fitWidth,
                      // fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VisibilityDetector(
                          key: Key("${widget.videoObj.videoId}"),
                          onVisibilityChanged: (info) {
                            print("onVisibilityChanged2 ${info.visibleFraction} ${widget.videoObj.videoId} ${widget.videoObj.aspectRatio} ${dashboardService.videoPaused.value}");
                            if (_controller != null) {
                              if (info.visibleFraction >= 0.4) {
                                print("_controller $_controller");
                                setState(() {
                                  dashboardService.currentVideoId = widget.videoObj.videoId;
                                });
                                if (!dashboardService.videoPaused.value) {
                                  _controller!.play();
                                }
                                dashboardService.currentVideoPlayer.value = _controller!;
                                dashboardService.currentVideoPlayer.refresh();
                              } else {
                                _controller!.pause();
                              }
                              if (mounted) setState(() {});
                            }
                          },
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  ),
          ),
          AnimatedOpacity(
            opacity: !_controller!.value.isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 3000),
            curve: Curves.easeInOut,
            child: widget.videoObj.aspectRatio > 0.8
                ? Center(
                    child: AspectRatio(
                      aspectRatio: widget.videoObj.aspectRatio.toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: _controller!.value.position.inMilliseconds < 1
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.videoObj.videoThumbnail,
                                    cacheManager: CustomCacheManager.instance,
                                  ),
                                  // fit: widget.videoObj.isWide ? BoxFit.fitWidth : BoxFit.fitHeight,
                                  fit: BoxFit.fitWidth,
                                )
                              : null,
                        ),
                        child: CommonHelper.showLoaderSpinner(Colors.transparent),
                      ),
                    ),
                  )
                : Center(
                    child: SizedBox.expand(
                      child: _controller!.value.position.inMilliseconds < 1
                          ? CachedNetworkImage(
                              imageUrl: widget.videoObj.videoThumbnail,
                              cacheManager: CustomCacheManager.instance,
                              fit: widget.videoObj.aspectRatio > 1 ? BoxFit.fitWidth : BoxFit.fitHeight,
                            )
                          : Container(),
                    ),
                  ),
          ),
          _ControlsOverlay(controller: _controller!),
          Positioned(
            bottom: 0,
            child: Container(
              height: Get.height * (0.40),
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black38,
                    Colors.black26,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: Get.mediaQuery.viewPadding.bottom + 50,
            width: Get.width,
            height: 10,
            child: SliderTheme(
              data: SliderThemeData(
                overlayShape: SliderComponentShape.noOverlay,
                // activeTrackColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                // disabledActiveTrackColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                // inactiveTrackColor: Get.theme.colorScheme.primary,
                // inactiveTickMarkColor: Get.theme.colorScheme.primary,
                // disabledActiveTickMarkColor: Get.theme.colorScheme.primary,
                // disabledInactiveTickMarkColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                disabledInactiveTrackColor: Get.theme.colorScheme.primary,
                disabledThumbColor: Get.theme.colorScheme.primary,
                trackHeight: 0.1,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1.50),
              ),
              child: SmoothVideoProgress(
                controller: _controller!,
                builder: (context, position, duration, child) => Slider(
                  onChangeStart: (_) => _controller!.pause(),
                  onChangeEnd: (_) => _controller!.play(),
                  onChanged: (value) => _controller!.seekTo(Duration(milliseconds: value.toInt())),
                  value: position.inMilliseconds.toDouble(),
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  activeColor: mainService.setting.value.dashboardIconColor!,
                  inactiveColor: mainService.setting.value.dashboardIconColor!.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
        // ),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> with TickerProviderStateMixin {
  DashboardController dashboardController = Get.find();
  DashboardService dashboardService = Get.find();
  MainService mainService = Get.find();
  // static const List<Duration> _exampleCaptionOffsets = <Duration>[
  //   Duration(seconds: -10),
  //   Duration(seconds: -3),
  //   Duration(seconds: -1, milliseconds: -500),
  //   Duration(milliseconds: -250),
  //   Duration.zero,
  //   Duration(milliseconds: 250),
  //   Duration(seconds: 1, milliseconds: 500),
  //   Duration(seconds: 3),
  //   Duration(seconds: 10),
  // ];
  // static const List<double> _examplePlaybackRates = <double>[
  //   0.25,
  //   0.5,
  //   1.0,
  //   1.5,
  //   2.0,
  //   3.0,
  //   5.0,
  //   10.0,
  // ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: !widget.controller.value.isPlaying
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.controller.value.isPlaying
                              ? Colors.transparent
                              : (!dashboardController.onTap.value)
                                  ? Colors.transparent
                                  : mainService.setting.value.dashboardIconColor!,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: AnimationController(duration: const Duration(milliseconds: 300), vsync: this),
                      size: 50,
                      color: widget.controller.value.isPlaying
                          ? Colors.transparent
                          : (!dashboardController.onTap.value)
                              ? Colors.transparent
                              : mainService.setting.value.dashboardIconColor,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: () {
            dashboardController.onTap.value = true;

            dashboardService.videoPaused.value = !dashboardService.videoPaused.value;
            dashboardService.videoPaused.refresh();
            print("GestureDetector ${dashboardService.videoPaused.value}");
            if (widget.controller.value.isPlaying) {
              print(2222);
              widget.controller.pause();
            } else {
              print(33333);
              widget.controller.play();
            }
            setState(() {});
          },
        ),

        /*Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),*/
      ],
    );
  }
}
