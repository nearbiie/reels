import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class DashboardService extends GetxService {
  var currentPage = 0.obs;
  var dataLoaded = false.obs;
  var firstLoad = true.obs;
  var randomString = "".obs;
  var videosData = VideoModel().obs;
  var watchedVideos = [].obs;
  var pageIndex = 0.obs;
  var commentsLoaded = false.obs;
  var unreadMessageCount = 0.obs;
  var selectedVideoLength = 15.0.obs;
  var outputVideoAfter1StepPath = "".obs;
  var outputVideoPath = "".obs;
  var watermarkUri = "".obs;
  var thumbImageUri = "".obs;
  var videoControllers = {}.obs;
  var descriptionHeight = 35.0.obs;
  var bottomPadding = 0.0.obs;
  var showFollowingPage = false.obs;
  List postIds = [];
  String videoReportDescription = "";
  var videoReportBlocked = false.obs;
  int currentVideoId = 0;
  var prevPage = "".obs;
  var pageController = PageController().obs;
  var videoPaused = false.obs;
  var eulaData;

  AndroidDeviceInfo? androidDeviceInfo;

  IosDeviceInfo? iosDeviceInfo;
  var currentVideoPlayer = VideoPlayerController.networkUrl(Uri.parse("")).obs;
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;
  @override
  void onInit() async {
    super.onInit();
  }
}
