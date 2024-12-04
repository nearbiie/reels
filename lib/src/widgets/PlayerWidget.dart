import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../core.dart';

class PlayerWidget extends StatefulWidget {
  final SoundData sound;

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();

  const PlayerWidget({
    required this.sound,
  });
}

class _PlayerWidgetState extends State<PlayerWidget> {
  int userId = 0;
  int videoId = 0;
  bool showLoader = true;

  SoundController soundController = Get.find();
  int isFav = 0;
  bool showLoading = false;
  MainService mainService = Get.find();

  @override
  void initState() {
    isFav = widget.sound.fav;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    soundController.audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: soundController.audioPlayer.playingStream,
      initialData: false,
      builder: (context, snapshotPlaying) {
        final bool isPlaying = snapshotPlaying.data as bool;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: mainService.setting.value.dividerColor!.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Container(
                padding: EdgeInsets.all(4),
                width: Get.width,
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: new DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.sound.imageUrl,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                // gradient: Gradients.blush,
                              ),
                              child: Center(
                                child: soundController.audioPlayer.sequenceState != null
                                    ? showLoading && soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url
                                        ? Container(width: 40, height: 40, child: CommonHelper.showLoaderSpinner(Colors.white))
                                        : IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              isPlaying && soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url
                                                  ? Icons.pause_circle_outline_rounded
                                                  : Icons.play_circle_outline,
                                              size: 40,
                                              color: Get.theme.iconTheme.color,
                                            ),
                                            onPressed: () async {
                                              print("aasdasd");
                                              if (soundController.audioPlayer.sequenceState != null)
                                              /*print(
                                                    "soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url ${soundController.audioPlayer.sequenceState!.currentSource!.tag} == ${widget.sound.url}");*/
                                              if (soundController.audioPlayer.sequenceState != null) {
                                                if (soundController.audioPlayer.sequenceState!.currentSource!.tag != widget.sound.url) {
                                                  print("asasdasd");
                                                  setState(() {
                                                    showLoading = true;
                                                  });
                                                  soundController.audioPlayer.stop();
                                                  soundController.audioPlayer = new AudioPlayer();
                                                  File file = await DefaultCacheManager().getSingleFile(widget.sound.url);
                                                  soundController.audioPlayer.setAudioSource(
                                                    AudioSource.file(file.path, tag: widget.sound.url),
                                                  );

                                                  soundController.audioPlayer.play();
                                                  setState(() {
                                                    showLoading = false;
                                                  });
                                                } else if (soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url) {
                                                  print(
                                                      "soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url ${soundController.audioPlayer.sequenceState!.currentSource!.tag} == ${widget.sound.url}");

                                                  if (isPlaying) {
                                                    print("isPlaying");
                                                    soundController.audioPlayer.pause();
                                                  } else {
                                                    print("isPaused");
                                                    try {
                                                      soundController.audioPlayer.play();
                                                    } catch (e) {
                                                      print("play Error $e");
                                                    }
                                                  }
                                                } else {
                                                  soundController.audioPlayer.play();
                                                }
                                              } else {
                                                setState(() {
                                                  showLoading = true;
                                                });
                                                File file = await DefaultCacheManager().getSingleFile(widget.sound.url);
                                                soundController.audioPlayer.setAudioSource(
                                                  AudioSource.file(file.path, tag: widget.sound.url),
                                                );
                                                soundController.audioPlayer.play();
                                                setState(() {
                                                  showLoading = false;
                                                });
                                              }
                                            },
                                          )
                                    : IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isPlaying && soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url
                                              ? Icons.pause_circle_outline_rounded
                                              : Icons.play_circle_outline,
                                          size: 40,
                                          color: Get.theme.iconTheme.color,
                                        ),
                                        onPressed: () async {
                                          print("aasdasd");
                                          if (soundController.audioPlayer.sequenceState != null)
                                            print(
                                                "soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url ${soundController.audioPlayer.sequenceState!.currentSource!.tag} == ${widget.sound.url}");
                                          if (soundController.audioPlayer.sequenceState != null) {
                                            if (soundController.audioPlayer.sequenceState!.currentSource!.tag != widget.sound.url) {
                                              print("asasdasd");
                                              setState(() {
                                                showLoading = true;
                                              });
                                              soundController.audioPlayer.stop();
                                              soundController.audioPlayer = new AudioPlayer();
                                              File file = await DefaultCacheManager().getSingleFile(widget.sound.url);
                                              soundController.audioPlayer.setAudioSource(
                                                AudioSource.file(file.path, tag: widget.sound.url),
                                              );
                                              soundController.audioPlayer.play();
                                              setState(() {
                                                showLoading = false;
                                              });
                                            } else if (soundController.audioPlayer.sequenceState!.currentSource!.tag == widget.sound.url) {
                                              if (isPlaying) {
                                                soundController.audioPlayer.pause();
                                              } else {
                                                soundController.audioPlayer.play();
                                              }
                                            } else {
                                              soundController.audioPlayer.play();
                                            }
                                          } else {
                                            setState(() {
                                              showLoading = true;
                                            });
                                            File file = await DefaultCacheManager().getSingleFile(widget.sound.url);
                                            soundController.audioPlayer.setAudioSource(
                                              AudioSource.file(file.path, tag: widget.sound.url),
                                            );
                                            soundController.audioPlayer.play();
                                            setState(() {
                                              showLoading = false;
                                            });
                                          }
                                        },
                                      ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: InkWell(
                                onTap: () async {
                                  await soundController.audioPlayer.pause();

                                  Get.defaultDialog(
                                    backgroundColor: Get.theme.highlightColor,
                                    title: "",
                                    content: Text(
                                      "${'Downloading'.tr}.. ${'Please wait'.tr}...".tr,
                                      style: TextStyle(color: Get.theme.primaryColor),
                                    ),
                                  );

                                  print("this.widget.sound");
                                  print(this.widget.sound.url);
                                  soundController.selectSound(this.widget.sound);
                                  mainService.isOnRecordingPage.value = true;
                                  mainService.isOnRecordingPage.refresh();
                                  await DefaultCacheManager().getSingleFile(widget.sound.url);
                                  if (Get.isDialogOpen!) {
                                    print("iitOpeneee");
                                    Get.back();
                                  }
                                  if (Get.currentRoute == "/sound-cat-list") {
                                    Get.back();
                                    mainService.isOnRecordingPage.value = true;
                                    Get.put(VideoRecorderController(), permanent: true);
                                    Get.offNamed('/video-recorder');
                                    // Get.back();
                                  } else {
                                    mainService.isOnRecordingPage.value = true;
                                    Get.put(VideoRecorderController(), permanent: true);
                                    Get.offNamed('/video-recorder');
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: Get.width,
                                        child: MarqueeWidget(
                                          child: Text(
                                            this.widget.sound.title,
                                            style: TextStyle(
                                              color: Get.theme.indicatorColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: MarqueeWidget(
                                            child: Text(
                                              widget.sound.album,
                                              style: TextStyle(
                                                color: Get.theme.indicatorColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          //width: config.App(context).appWidth(40),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.sound.duration.toString() + " " + "sec".tr,
                                                style: TextStyle(
                                                  color: Get.theme.indicatorColor,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              widget.sound.usedTimes > 0
                                                  ? Container(
                                                      child: Align(
                                                        alignment: Alignment.bottomCenter,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "Used".tr + " " + widget.sound.usedTimes.toString(),
                                                            style: TextStyle(
                                                              color: Get.theme.indicatorColor,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: SvgPicture.asset(
                              'assets/icons/liked.svg',
                              width: 25.0,
                              colorFilter: ColorFilter.mode(isFav > 0 ? Get.theme.highlightColor : Get.theme.iconTheme.color!, BlendMode.srcIn),
                            ),
                            onPressed: () async {
                              setState(() {
                                isFav = isFav == 1 ? 0 : 1;
                              });
                              String msg = await soundController.setFavSound(widget.sound.soundId, widget.sound.fav > 0 ? "false" : "true");
                              if (msg != "" && msg.contains('set')) {
                                setState(() {
                                  isFav = 1;
                                  widget.sound.fav = 1;
                                });
                              } else {
                                setState(() {
                                  isFav = 0;
                                  widget.sound.fav = 0;
                                });
                              }
                              ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(msg)));
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
