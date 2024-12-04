import 'package:get/get.dart';

import '../core.dart';

class VideoRecorderService extends GetxService {
  var setting = Setting().obs;

  var outputVideoAfter1StepPath = "".obs;
  var outputVideoPath = "".obs;
  var watermarkUri = "".obs;

  var thumbImageUri = "".obs;
  var isOnRecordingPage = false.obs;

  var selectedVideoLength = 300.0.obs;

  var videoProgressPercent = 0.0.obs;
  var outputVideoDurationInMilliSeconds = 0.obs;

  get previewVideoController => null;

  @override
  void onInit() async {
    super.onInit();
  }
}
