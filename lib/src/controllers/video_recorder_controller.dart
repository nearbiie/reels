import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as HTTP;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:stories_editor/stories_editor.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class VideoRecorderController extends GetxController {
  DashboardController homeCon = DashboardController();
  CameraController? mainCameraController;
  String videoPath = "";
  String audioFile = "";
  var description = "".obs;
  List<CameraDescription> cameras = [];
  int selectedCameraIdx = 0;
  bool videoRecorded = false;
  GlobalKey<FormState> key = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> videoEditorViewKey =
      GlobalKey<ScaffoldState>();
  // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  bool showRecordingButton = false;

  var disableFlipButton = false.obs;
  var isProcessing = false.obs;
  var videoText = Text("").obs;
  bool saveLocally = true;
  VideoPlayerController? videoController;
  VoidCallback videoPlayerListener = () {};
  String thumbFile = "";
  String gifFile = "";
  String watermark = "";
  int userId = 0;
  PanelController pc1 = new PanelController();
  String appToken = "";
  final audioPlayer = AudioPlayer();

  String audioFileName = "";
  int audioId = 0;
  int videoId = 0;
  bool showLoader = false;
  bool isPublishPanelOpen = false;
  bool isVideoRecorded = false;
  var showProgressBar = false.obs;
  double progress = 0.0;
  late GlobalKey textOverlayKey;
  String aiPrompt = "";
  var isCountDownTimerShown = false.obs;
  late Timer timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
    videoRecorderService.videoProgressPercent.value +=
        1 / (videoRecorderService.selectedVideoLength.value * 10);
    videoRecorderService.videoProgressPercent.refresh();
    if (videoRecorderService.videoProgressPercent.value >= 1) {
      isProcessing.value = true;
      isProcessing.refresh();
      videoRecorderService.videoProgressPercent.value = 1;
      videoRecorderService.videoProgressPercent.refresh();
      timer.cancel();
      onStopButtonPressed();
    }
  });
  String responsePath = "";
  // double videoLength = 15.0;
  bool cameraCrash = false;
  AnimationController? animationController;
  late Animation sizeAnimation;
  bool reverse = false;
  bool isRecordingPaused = false;
  int seconds = 1;
  int privacy = 0;
  String thumbPath = "";
  String gifPath = "";
  var endShift = DateTime.now().obs;
  DateTime pauseTime = DateTime.now();
  DateTime playTime = DateTime.now();
  var videoTimerLimit = [].obs;
  var cameraPreview = false.obs;
  int pointers = 0;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  double currentExposureOffset = 0.0;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;
  double textWidgetHeight = 0.0;
  double textWidgetWidth = 0.0;
  var cropWidgetKey = GlobalKey();
  String textFilterImagePath = "";
  TransformationController? transformationController;
  var showTextFilter = false.obs;

  bool _firstStat = true;

  var showTimerTimings = false.obs;
  var startTimerTiming = 0.obs;
  var startTimerLimits = [0, 3, 10].obs;

  late Timer waitTimer;

  VideoEditorController? videoEditorController;

  String exportText = "";

  bool exported = false;

  var startTime;

  var diff;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  final double height = 60;
  // VideoPlayerController? previewVideoController;
  var showEditorDone = false.obs;
  VideoRecorderService videoRecorderService = Get.find();
  SoundService soundService = Get.find();
  MainService mainService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();
  // video editor
  final exportingProgress = 0.0.obs;
  final isExporting = false.obs;
  var videoEditorFile = File("").obs;
  VideoPlayerController? previewVideoController;
  bool downloading = false;
  bool isDownloaded = false;
  final detectableTextVideoDescriptionController =
      DetectableTextEditingController(
    regExp: detectionRegExp(url: false)!,
    detectedStyle: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      wordSpacing: 2.0,
      color: Get.theme.highlightColor,
    ),
  ).obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void dispose() {
    print("Video Recorder Controller Dispose");
    if (animationController != null) animationController!.dispose();
    if (videoController != null) videoController!.dispose();
    if (mainCameraController != null) mainCameraController!.dispose();

    if (videoEditorController != null) {
      videoEditorController!.dispose();
      videoEditorController!.video.dispose();
    }
    if (previewVideoController != null) previewVideoController!.dispose();
    super.dispose();
  }

  initCamera() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        selectedCameraIdx = 0;
        print(1111);

        onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(Get.context!)
        .showSnackBar(SnackBar(content: Text(message)));
  }

/*  void _handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }*/

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (mainCameraController == null || pointers != 2) {
      return;
    }

    currentScale =
        (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

    await mainCameraController!.setZoomLevel(currentScale);
  }

  void handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (mainCameraController == null) {
      return;
    }

    final CameraController cameraController = mainCameraController!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (mainCameraController != null) {
      await mainCameraController!.dispose();
    }

    mainCameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    mainCameraController!.addListener(() {
      if (mainCameraController!.value.hasError) {
        showInSnackBar(
            'Camera error ${mainCameraController!.value.errorDescription}');
      }
    });

    try {
      await mainCameraController!.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [
                mainCameraController!
                    .getMinExposureOffset()
                    .then((value) => minAvailableExposureOffset = value),
                mainCameraController!
                    .getMaxExposureOffset()
                    .then((value) => maxAvailableExposureOffset = value)
              ]
            : []),
        mainCameraController!
            .getMaxZoomLevel()
            .then((value) => maxAvailableZoom = value),
        mainCameraController!
            .getMinZoomLevel()
            .then((value) => minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void _showCameraException(CameraException e) {
    print("${e.code} ${e.description}");
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String? validateDescription(String? value) {
    if (value!.length == 0) {
      return "Description is required!";
    } else {
      return null;
    }
  }

  loadWatermark() {
    getWatermark().then((value) async {
      if (value != '') {
        var file = await DefaultCacheManager().getSingleFile(value);
        watermark = file.path;
        videoRecorderService.watermarkUri.value = watermark;
        videoRecorderService.watermarkUri.refresh();
      }
    });
  }

  Future<String> getWatermark() async {
    HTTP.Response response = await CommonHelper.sendRequestToServer(
        endPoint: 'get-watermark', requestData: {"data_var": "data"});
    String watermark = "";

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        watermark = jsonData['watermark'];
      }
    }

    return watermark;
  }

  Future<void> onCameraSwitched(CameraDescription cameraDescription) async {
    if (mainCameraController != null) {
      await mainCameraController!.dispose();
    }

    if (audioFileName == "") {
      mainCameraController = CameraController(
        cameraDescription,
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: soundService.mic.value ? true : false,

        // enableAudio: true,
      );
    } else {
      mainCameraController = CameraController(
        cameraDescription,
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: soundService.mic.value ? true : false,
        // enableAudio: true,
      );
    }
    try {
      await mainCameraController!.initialize();
      // await controller!.setFlashMode(FlashMode.off);
      await mainCameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      cameraPreview.value = true;
      cameraPreview.refresh();
    } catch (e) {
      print("Expdddd:" + e.toString());

      // showCameraException(e, Get.context);
    }
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: new Text("Camera Error",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Get.theme.indicatorColor,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: new Text(
                      "Camera Stopped Working !!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Get.theme.indicatorColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Get.theme.highlightColor,
                    ),
                    child: Center(
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          color: Get.theme.indicatorColor,
                          fontSize: 20,
                          fontFamily: 'RockWellStd',
                        ),
                      ),
                    ),
                  ),
                ).onTap(() {
                  Get.back(closeOverlays: true);
                  Get.back();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCameraException(CameraException e, BuildContext context) {
    cameraCrash = true;

    AwesomeDialog(
      dialogBackgroundColor: mainService.setting.value.buttonColor,
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      body: dialogContent(context),
      btnOkText: "Close",
      dismissOnBackKeyPress: false,
      onDismissCallback: (v) {
        print("onDismissCallback v $v");

        isVideoRecorded = false;
        completelyExitRecorder.call();
      },
    )..show();
  }

  Future<void> onSwitchCamera() async {
    cameraPreview.value = false;
    cameraPreview.refresh();
    disableFlipButton.value = true;
    disableFlipButton.refresh();
    selectedCameraIdx = selectedCameraIdx == 0 ? 1 : 0;
    print("selectedCameraIdx $selectedCameraIdx");
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    await onCameraSwitched(selectedCamera);
    selectedCameraIdx = selectedCameraIdx;
    cameraPreview.value = true;
    cameraPreview.refresh();
    Timer(Duration(seconds: 2), () {
      disableFlipButton.value = false;
      disableFlipButton.refresh();
    });
  }

  Future<String> enableVideo(BuildContext context) async {
    try {
      var response = await CommonHelper.sendRequestToServer(
          endPoint: 'video-enabled',
          requestData: {
            "video_id": videoId,
            "description": description,
            "privacy": privacy
          },
          method: "post");

      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          dashboardService.isUploading.value = true;
          dashboardService.isUploading.refresh();
          showLoader = false;

          Get.offAndToNamed('/my-profile');
        } else {
          var msg = response.data['msg'];
          Fluttertoast.showToast(msg: msg);
        }
      }

      showLoader = false;
    } catch (e) {
      var msg = e.toString();
      Fluttertoast.showToast(msg: msg);

      showLoader = false;
    }
    return responsePath;
  }

  Future saveAudio(audio) async {
    DefaultCacheManager().getSingleFile(audio).then((value) {
      // setState(() {
      audioFile = value.path;
      // });
      print("audioFile $audioFile");
      audioPlayer.setAudioSource(
        AudioSource.file(audioFile),
      );
      audioPlayer.setVolume(0.5);
    });
  }

  Future<String> downloadFile(uri, fileName) async {
    String progress = "";

    String savePath = await getFilePath(fileName);
    Dio dio = Dio();
    dio.download(
      uri.trim(),
      savePath,
      onReceiveProgress: (rcv, total) {
        progress = ((rcv / total) * 100).toStringAsFixed(0);
        if (progress == '100') {
          isDownloaded = true;
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      if (progress == '100') {
        isDownloaded = true;
      }
      downloading = false;
    });
    return savePath;
  }

  willPopScope() async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
      return Future.value(false);
    } else if (isVideoRecorded == true) {
      return exitConfirm();
    } else {
      completelyExitRecorder.call();
    }
  }

  void completelyExitRecorder() {
    print("completelyExitRecorder");
    videoRecorderService.outputVideoAfter1StepPath = "".obs;
    videoRecorderService.outputVideoPath = "".obs;
    videoRecorderService.watermarkUri = "".obs;
    videoRecorderService.thumbImageUri = "".obs;
    videoRecorderService.isOnRecordingPage.value = false;
    dashboardService.showFollowingPage.value = false;
    videoRecorderService.videoProgressPercent.value = 0;
    videoRecorderService.videoProgressPercent.refresh();
    timer.cancel();
    isVideoRecorded = false;
    showProgressBar.value = false;
    isProcessing.value = false;
    try {
      if (videoEditorController != null && videoEditorController!.initialized) {
        videoEditorController!.dispose();
      }
    } catch (e) {
      print(
          "completelyExitRecorder videoEditorController and mainCameraController error $e");
    }
    try {
      audioPlayer.stop();
      audioPlayer.dispose();
    } catch (e) {
      print("completelyExitRecorder audioPlayer error $e");
    }
    try {
      if (animationController != null) {
        animationController!.dispose();
        animationController = null;
      }
    } catch (e) {
      print("completelyExitRecorder animationController error $e");
    }
    try {
      if (videoController != null) {
        videoController!.dispose();
        videoController = null;
      }
    } catch (e) {
      print("completelyExitRecorder videoController error $e");
    }

    try {
      if (mainCameraController != null) {
        mainCameraController!.dispose();
        mainCameraController = null;
      }
    } catch (e) {
      print("completelyExitRecorder mainCameraController error $e");
    }

    try {
      if (videoEditorController != null) {
        videoEditorController!.dispose();
        videoEditorController!.video.dispose();
        videoEditorController = null;
      }
    } catch (e) {
      print("videoEditorController disposing exception $e");
    }
    try {
      previewVideoController!.dispose();
    } catch (e) {
      print("previewVideoController disposing exception $e");
    }
    dashboardController.getVideos();
    Get.delete<VideoRecorderController>(force: true);
    Get.offNamed("/home");
  }

  void exitConfirm() {
    AwesomeDialog(
      dialogBackgroundColor: mainService.setting.value.buttonColor,
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.question,
      body: Column(
        children: <Widget>[
          "Do you really want to discard "
                  "the video?"
              .text
              .color(Get.theme.primaryColor)
              .size(16)
              .center
              .make()
              .centered()
              .pSymmetric(v: 10),
          SizedBox(
            height: 10,
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(new Radius.circular(32.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      completelyExitRecorder();
                    },
                    child: Container(
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Get.theme.highlightColor,
                        borderRadius:
                            BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'RockWellStd'),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Get.theme.highlightColor,
                        borderRadius:
                            BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'RockWellStd',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    )..show();
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir;
    if (!Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = (await getExternalStorageDirectory())!;
    }
    path = '${dir.path}/$uniqueFileName';

    return path;
  }

  Future uploadGalleryVideo() async {
    File file = File("");
    final picker = ImagePicker();
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print(appDirectory);
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String thumbImg = '$outputDirectory/${currentTime}.jpg';
    // final String outputVideo = '$outputDirectory/${currentTime}.mp4';
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      file = File(pickedFile.path);
    } else {
      print('No image selected. ${file.path}');
    }
    if (file.path != "") {
      VideoPlayerController? _outputVideoController;
      try {
        _outputVideoController = VideoPlayerController.file(File(file.path));
        await _outputVideoController.initialize();
      } on CameraException catch (e) {
        EasyLoading.dismiss();
        showCameraException(
            "There's some error loading video $e" as CameraException,
            scaffoldKey.currentContext!);
        return;
      }
      print("_outputVideoController.value.duration.inSeconds");
      print(_outputVideoController.value.duration.inSeconds);
      print(videoRecorderService.selectedVideoLength.value.toInt());
      mainCameraController!.dispose();
      _outputVideoController.dispose();
      videoRecorderService.outputVideoPath.value = file.path;
      videoRecorderService.outputVideoPath.refresh();
      videoEditorFile.value = file;
      Get.offNamed("/video-editor");
    }
  }

  Future<bool> uploadVideo(videoFilePath, thumbFilePath) async {
    dashboardService.isUploading.value = true;
    dashboardService.isUploading.refresh();
    String videoFileName = videoFilePath.split('/').last;
    String thumbFileName = thumbFilePath.split('/').last;

    var formData = {
      "privacy": 1, //privacy,
      "description": detectableTextVideoDescriptionController.value.text,
      "sound_id": soundService.mic.value
          ? 0
          : soundService.currentSound.value.soundId > 0
              ? soundService.currentSound.value.soundId
              : audioId
    };
    List<UploadFile> files = [];
    UploadFile video = UploadFile(
        fileName: videoFileName,
        filePath: videoFilePath,
        variableName: "video");
    UploadFile thumb = UploadFile(
        fileName: thumbFileName,
        filePath: thumbFilePath,
        variableName: "thumbnail_file");
    files.add(video);
    files.add(thumb);

    var response = await CommonHelper.sendRequestToServer(
      endPoint: 'upload-video',
      method: "post",
      requestData: formData,
      files: files,
      onSendProgress: (int sent, int total) {
        dashboardService.uploadProgress.value = sent / total;
        dashboardService.uploadProgress.refresh();
        if (dashboardService.uploadProgress.value >= 100) {
          // dashboardService.isUploading.value = false;
          // dashboardService.isUploading.refresh();
          videoRecorderService.thumbImageUri.value = "";
          videoRecorderService.thumbImageUri.refresh();
          videoRecorderService.outputVideoPath.value = "";
          videoRecorderService.outputVideoPath.refresh();
        }
      },
    );
    soundService.currentSound = SoundData(soundId: 0, title: "").obs;
    soundService.currentSound.refresh();
    print("uploading response.data ${response.data}");

    if (response.statusCode == 200) {
      // call upload-videos
      AuthService authService = Get.find();
      UserController userController = Get.find();
      var user_id = authService.currentUser.value.id;
      await uploadClientVideo(response.data['video_id'], user_id);
      dashboardService.isUploading.value = false;
      dashboardService.isUploading.refresh();
      if (response.data['status'] == 'success') {
        showLoader = false;
        return true;
      } else {
        var msg = response.data['msg'];
        AwesomeDialog(
          dialogBackgroundColor: mainService.setting.value.buttonColor,
          context: Get.context!,
          animType: AnimType.scale,
          dialogType: DialogType.warning,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Video Flagged",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Get.theme.highlightColor,
                    ),
                    child: "Close"
                        .text
                        .size(18)
                        .center
                        .color(Get.theme.indicatorColor)
                        .make()
                        .centered()
                        .pSymmetric(h: 10, v: 10),
                  ),
                )
              ],
            ),
          ),
        )..show();
        return false;
      }
    } else {
      showLoader = false;
      dashboardService.isUploading.value = false;
      dashboardService.isUploading.refresh();
      return false;
    }
  }

  Future<bool> uploadClientVideo(videoId, user_id) async {
    Map<String, dynamic> retrieved = jsonDecode(SharedData().sharedValue);
    var formData = {
      "user_id": user_id, //privacy,
      "owner_id": retrieved['id'],
      "video_id": videoId,
      "video_status": 'approved',
      "store_id": retrieved['id'],
      "store_logo": retrieved['logo_full_url'],
      "store_name": retrieved['name'],
      "video_amount": 0,
      "balance": 0,
      "payout": 0,
      "user_hire_status": 1,
      "payment_link": "",
      "payment_status": "unpaid",
    };

    print("create video data: $formData");

    await CommonHelper.sendRequestToServer(
      endPoint: 'client-videos',
      method: "post",
      requestData: formData,
      onSendProgress: (int sent, int total) {
        print("pushing data in progress");
      },
    );
    return true;
  }

  convertToBase(file) async {
    List<int> vidBytes = await File(file).readAsBytes();
    String base64Video = base64Encode(vidBytes);
    return base64Video;
  }

  void startWaitTimer() {
    /*if (waitTimer != null) {
      waitTimer.cancel();
    }*/
    waitTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (startTimerTiming.value > 0) {
        startTimerTiming.value--;
        startTimerTiming.refresh();
      } else {
        waitTimer.cancel();
      }
    });
  }

  Future<void> onRecordButtonPressed(BuildContext context) async {
    isVideoRecorded = true;
    videoRecorded = true;
    isRecordingPaused = false;
    if (!soundService.mic.value &&
        soundService.currentSound.value.soundId == 0) {
      Fluttertoast.showToast(
          msg: "Please select a sound from sound listing first".tr);
      isCountDownTimerShown.value = false;
      isCountDownTimerShown.refresh();
      return;
    }
    if (startTimerTiming.value > 0 && isCountDownTimerShown.value) {
      print("don't enter Recording");
      return;
    }
    if (startTimerTiming.value > 0) {
      isCountDownTimerShown.value = true;
      isCountDownTimerShown.refresh();
      Duration waitSeconds = Duration(seconds: startTimerTiming.value);
      startWaitTimer();
      await Future.delayed(waitSeconds);
    }
    startVideoRecording(context).whenComplete(() {
      isCountDownTimerShown.value = false;
      isCountDownTimerShown.refresh();
      showProgressBar.value = true;
      startTimer(context);
      if (soundService.mic.value) {
        audioPlayer.setVolume(0.2);
      } else {
        audioPlayer.setVolume(0.6);
      }
      audioPlayer.play();
      cameraPreview.value = true;
      cameraPreview.refresh();
      isCountDownTimerShown.value = false;
      isCountDownTimerShown.refresh();
    });
  }

  void onPauseButtonPressed(BuildContext context) {
    if (soundService.currentSound.value.soundId > 0) {
      audioPlayer.pause();
    }
    // setState(() {
    isRecordingPaused = true;
    pauseTime = DateTime.now();
    // });
    pauseVideoRecording(context).then((_) {
      // setState(() {
      videoRecorded = false;
      timer.cancel();
      // });
    });
  }

  void onResumeButtonPressed(BuildContext context) {
    audioPlayer.play();
    playTime = DateTime.now();
    isRecordingPaused = false;
    try {
      endShift.value.add(Duration(
          milliseconds: playTime.difference(pauseTime).inMilliseconds));
      endShift.refresh();
    } catch (e) {
      print("endShift.value error $e");
    }
    resumeVideoRecording(context).then((_) {
      videoRecorded = true;
      startTimer(context);
    });
  }

  Future<void> startVideoRecording(BuildContext context) async {
    if (!mainCameraController!.value.isInitialized) {
      return null;
    }
    if (mainCameraController!.value.isRecordingVideo) {
      return null;
    }
    Directory? appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDirectory = await getExternalStorageDirectory();
    }
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await mainCameraController!.startVideoRecording();
      endShift.value = DateTime.now().add(Duration(
          milliseconds: videoRecorderService.selectedVideoLength.value.toInt() *
                  1000 +
              int.parse(
                      (videoRecorderService.selectedVideoLength.value.toInt() /
                              15)
                          .toStringAsFixed(0)) *
                  104));
      endShift.refresh();
    } on CameraException catch (e) {
      showCameraException(e, context);
      return null;
    }
  }

  Future<void> pauseVideoRecording(BuildContext context) async {
    if (!mainCameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await mainCameraController!.pauseVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e, context);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording(BuildContext context) async {
    if (!mainCameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await mainCameraController!.resumeVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e, context);
      rethrow;
    }
  }

  Future<void> onStopButtonPressed() async {
    timer.cancel();
    if (soundService.currentSound.value.soundId > 0) {
      audioPlayer.pause();
    }

    videoRecorded = false;
    isProcessing.value = true;
    isProcessing.refresh();
    EasyLoading.show(
      status: "loading..",
      maskType: EasyLoadingMaskType.black,
    );
    try {
      await stopVideoRecording();
      print("stopVideoRecording");
    } catch (e, s) {
      print("stopVideoRecordingException $e $s");
    }
  }

  Future<String> stopVideoRecording() async {
    audioPlayer.pause();
    if (!mainCameraController!.value.isRecordingVideo) {
      print("abc");
      return "";
    }
    if (!videoRecorderService.isOnRecordingPage.value) {
      print("abc1");
      return "";
    }
    try {
      XFile recordedFile = await mainCameraController!.stopVideoRecording();
      videoPath = recordedFile.path;
    } on CameraException catch (e, s) {
      print("CameraException $e $s");
      showCameraException(e, scaffoldKey.currentContext!);
      return "";
    }
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print("appDirectory $appDirectory");
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    // VideoPlayerController? _outputVideoController;
    try {
      // _outputVideoController = VideoPlayerController.file(File(videoPath));
      // await _outputVideoController.initialize();
    } on CameraException catch (e) {
      EasyLoading.dismiss();
      showCameraException(
          "There's some error loading video $e" as CameraException,
          scaffoldKey.currentContext!);
      return "";
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    // final String thumbImg = '$outputDirectory/$currentTime.jpg';
    // String responseVideo = "";
    String audioFileArgs = '';
    // String audioFileArgs2 = '';
    String mergeAudioArgs = '';
    String mergeAudioArgs2 = '';
    String watermarkArgs = '';
    String presetString = '';
    if (watermark != '') {
      // watermark = " -i $watermark";
      // watermarkArgs = ",overlay=W-w-5:5";
    }
    if (soundService.mic.value && audioFile != '') {
      audioFile = "";
      presetString = '-preset ultrafast';
    }
    if (!soundService.mic.value && audioFile != '') {
      audioFile = " -i $audioFile";
      presetString = '-preset ultrafast -crf 28';
      mergeAudioArgs2 = "-map 0:v:0 -map 1:a:0";
      audioFileArgs = '-c:a aac -ac 2 -ar 22050 -shortest -b:a 64k';
    }
    try {
      print(
          'ffmpeg -i $videoPath $watermark $audioFile  -filter_complex "$mergeAudioArgs[0:v]scale=560:-2$watermarkArgs" -c libx265  $mergeAudioArgs2 $audioFileArgs  $presetString $outputVideo');

      FFmpegKit.executeAsync(
          // '-y -i $videoPath $audioFile  -filter_complex "$mergeAudioArgs[0:v]scale=560:-2$watermarkArgs" -c:v libx264 $mergeAudioArgs2 $audioFileArgs -preset ultrafast -crf 23  $outputVideo',
          '-y -i $videoPath $audioFile  -filter_complex "$mergeAudioArgs[0:v]scale=560:-2,setpts=PTS-STARTPTS,setsar=1:1$watermarkArgs" -c:v libx264 $mergeAudioArgs2 $audioFileArgs -pix_fmt yuv420p -r 24 -preset superfast  $outputVideo',
          (session) async {
            EasyLoading.dismiss(animation: true);
            print("FFmpegKit.executeAsync in Command");
            // Unique session id created for this execution
            final sessionId = session.getSessionId();
            print("FFmpegKit.executeAsync sessionId $sessionId");
            // Command arguments as a single string
            final command = session.getCommand();
            print("ffmpeg command $command");

            // The list of logs generated for this execution
            final logs = await session.getLogs();
            print("ffmpegLogs $logs");
            logs.forEach((element) {
              print("::");
              print(element.getMessage());
            });
            videoPath = outputVideo;
            videoRecorderService.outputVideoPath.value = outputVideo;
            videoRecorderService.outputVideoPath.refresh();
            try {
              mainCameraController!.dispose();
              isProcessing.value = false;
              isProcessing.refresh();
              _firstStat = true;
              EasyLoading.dismiss(animation: true);
              videoEditorFile.value = File(videoPath);
              Get.offNamed("/video-editor");
            } catch (e, s) {
              print("videoPath error : $e $s");
            }
          },
          null,
          (statics) {
            // First statistics is always wrong so if first one skip it
            if (_firstStat) {
              _firstStat = false;
            } else {
              print(
                  "Processing Video ${statics.getTime()} / ${((videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%");
              String stats =
                  "Processing Video ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
              EasyLoading.showProgress(
                ((statics.getTime() /
                    videoRecorderService
                        .outputVideoDurationInMilliSeconds.value)),
                status: stats,
                maskType: EasyLoadingMaskType.black,
              );
            }
          });
    } catch (e) {
      print("Error encoding video $e");
      print(e.toString());
    }
    return outputVideo;
  }

  final fonts = [
    'Alegreya',
    'B612',
    'TitilliumWeb',
    'Varela',
    'Vollkorn',
    'Rakkas',
    'ConcertOne',
    'YatraOne',
    'OldStandardTT',
    'Neonderthaw',
    'DancingScript',
    'SedgwickAve',
    'IndieFlower',
    'Sacramento',
    'PressStart2P',
    'FrederickatheGreat',
    'ReenieBeanie',
    'BungeeShade',
    'UnifrakturMaguntia'
  ];

  startTimer(BuildContext context) {
    startTime = DateTime.now();

    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      diff = DateTime.now().difference(startTime);
      videoRecorderService.videoProgressPercent.value +=
          1 / (videoRecorderService.selectedVideoLength.value * 10);
      videoRecorderService.videoProgressPercent.refresh();
      videoRecorderService.outputVideoDurationInMilliSeconds.value =
          diff.inMilliseconds;
      videoRecorderService.outputVideoDurationInMilliSeconds.refresh();
      if (videoRecorderService.videoProgressPercent.value >= 1) {
        isProcessing.value = true;
        isProcessing.refresh();
        cameraPreview.value = true;
        cameraPreview.refresh();
        videoRecorderService.videoProgressPercent.value = 1;
        videoRecorderService.videoProgressPercent.refresh();
        videoRecorderService.outputVideoDurationInMilliSeconds.value =
            diff.inMilliseconds;
        videoRecorderService.outputVideoDurationInMilliSeconds.refresh();

        timer.cancel();
        onStopButtonPressed();
      }
    });
  }

  void getTimeLimits() {
    videoTimerLimit.value = [];
    mainService.setting.value.videoTimeLimits.forEach((element) {
      videoTimerLimit.add(double.parse(element));
    });
    videoTimerLimit.refresh();
    videoRecorderService.selectedVideoLength.value = videoTimerLimit.first;
    videoRecorderService.selectedVideoLength.refresh();
    print(
        "videoRecorderService.selectedVideoLength.value ${videoRecorderService.selectedVideoLength.value}");
  }

  Future<void> processTextFilter(String uri, {bool skip = false}) async {
    print(
        "processTextFilter uri: $uri watermark: ${videoRecorderService.watermarkUri.value} outputVideoPath: ${videoRecorderService.outputVideoPath.value}");
    previewVideoController!.pause();
    EasyLoading.show(
      status: "loading..",
      maskType: EasyLoadingMaskType.black,
    );
    print(
        "processTextFilter $uri ${videoRecorderService.watermarkUri.value} ${videoRecorderService.outputVideoPath.value}");
    String loadingMessage = "";
    if (skip) {
      loadingMessage = "Adding watermark...";
    } else {
      loadingMessage = "Adding text filter and watermark...";
    }
    // final VideoPlayerController _outputVideoController = VideoPlayerController.file(File(videoRecorderService.outputVideoPath.value));
    // await _outputVideoController.initialize();
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print(appDirectory);
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    var watermarkArgs = "";
    var textFilterArgs = "";
    var textFilter = "";
    var mapVar = "";
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    // final String outputVideoWithWatermark = '$outputDirectory/$currentTime-watermarked.mp4';
    final String thumbImg = '$outputDirectory/$currentTime.jpg';
    if (uri != "") {
      File image = new File(uri); // Or any other way to get a File instance.
      var decodedImage = await decodeImageFromList(image.readAsBytesSync());
      print(decodedImage.width);
      print(decodedImage.height);
      int width = (decodedImage.width / 2).ceil() * 2;
      int height = (decodedImage.height / 2).ceil() * 2;
      textFilterArgs =
          "scale='min(iw*$height/ih,$width):min($height,ih*$width/iw)',pad=$width:$height:($width-iw)/2:($height-ih)/2[sc];[sc][1]overlay[vo]";
      // textFilterArgs = "scale='min(iw*$height/ih,$width):min($height,ih*$width/iw)',pad='max(" + '"min(iw*$height/ih,$width)"' + ",$width)':'max(" + '"min($height,ih*$width/iw)"' + ",$height)':'max((ow-iw)/2,($width-iw)/2)':'max((oh-ih)/2,($height-ih)/2)'[sc];[sc][1]overlay[vo]";
      /*textFilterArgs = "scale='min(iw*" +
            '("ceil($height/2)"*2)' +
            '/ih,' +
            '("ceil($width/2)"*2)):min' +
            '("ceil($height/2)"*2,ih*' +
            '("ceil($width/2)"' +
            "*2))/iw',pad=" +
            '("ceil($width/2)"*2):' +
            '("ceil($height/2)"*2):(' +
            '("ceil($width/2)"*2)-iw)/2:(' +
            '("ceil($height/2)"' +
            "*2)-ih)/2[sc];[sc][1]overlay[vo]";*/
      textFilter = "-i $uri";
      mapVar = "[vo]";

      if (videoRecorderService.watermarkUri.value != '') {
        watermarkArgs =
            ";[2][vo]scale2ref=w='iw*25/100':h='ow/mdar'[wm][vid];[vid][wm]overlay=W-w-55:40[final]";
        mapVar = "[final]";
        watermark = " -i ${videoRecorderService.watermarkUri.value}";
      }
    }
    EasyLoading.dismiss();
    try {
      if (skip) {
        print("Skipped Text Filter");
        if (videoRecorderService.outputVideoPath.value != "") {
          if (videoRecorderService.watermarkUri.value != '') {
            print("Entered Watewrmark Filter");

            watermark = " -i ${videoRecorderService.watermarkUri.value}";
            watermarkArgs =
                "[1][0]scale2ref=w='iw*25/100':h='ow/mdar'[wm][vid];[vid][wm]overlay=W-w-55:40";
            // watermarkArgs = "overlay=W-w-5:5";
            FFmpegKit.executeAsync(
                '-y -i ${videoRecorderService.outputVideoPath.value} $watermark -filter_complex "$watermarkArgs" -preset superfast -crf 23  $outputVideo',
                (session) async {
                  print("FFmpegKit.executeAsync in Command");
                  // Unique session id created for this execution
                  final sessionId = session.getSessionId();
                  print("FFmpegKit.executeAsync sessionId $sessionId");
                  // Command arguments as a single string
                  final command = session.getCommand();
                  print("ffmpeg command $command");
                  final logs = await session.getLogs();
                  print("ffmpegLogs $logs");
                  logs.forEach((element) {
                    print("::");
                    print(element.getMessage());
                  });
                  try {
                    videoPath = outputVideo;
                    videoRecorderService.outputVideoPath.value = videoPath;
                    videoRecorderService.outputVideoPath.refresh();
                    print("fail 1 1220 ");
                    print(
                        "-i $videoPath -ss 00:00:00.000 -vframes 1 -preset ultrafast $thumbImg");
                    FFmpegKit.executeAsync(
                        "-i $videoPath -ss 00:00:00.000 -vframes 1 -preset ultrafast $thumbImg",
                        (session) async {
                          print("FFmpegKit.executeAsync in Command");
                          // Unique session id created for this execution
                          final sessionId = session.getSessionId();
                          print("FFmpegKit.executeAsync sessionId $sessionId");
                          // Command arguments as a single string
                          final command = session.getCommand();
                          print("ffmpeg command $command");
                          // The list of logs generated for this execution
                          final logs = await session.getLogs();
                          print("ffmpegLogs $logs");
                          logs.forEach((element) {
                            print("::");
                            print(element.getMessage());
                          });
                          thumbPath = thumbImg;
                          videoRecorderService.thumbImageUri.value = thumbImg;

                          isProcessing.value = false;
                          isProcessing.refresh();
                          // _outputVideoController.dispose();
                          openPreviewWindow(skip: true);
                          EasyLoading.dismiss();
                        },
                        null,
                        (statics) {
                          // First statistics is always wrong so if first one skip it
                          if (_firstStat) {
                            _firstStat = false;
                          } else {
                            String stats =
                                "Generating cover image ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
                            EasyLoading.showProgress(
                              ((statics.getTime() /
                                  videoRecorderService
                                      .outputVideoDurationInMilliSeconds
                                      .value)),
                              status: stats,
                              maskType: EasyLoadingMaskType.black,
                            );
                          }
                        });
                  } catch (e) {
                    EasyLoading.dismiss();
                    print("videoPath error : $e");
                  }
                },
                null,
                (statics) {
                  // First statistics is always wrong so if first one skip it
                  if (_firstStat) {
                    _firstStat = false;
                  } else {
                    String stats =
                        "$loadingMessage ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
                    EasyLoading.showProgress(
                      ((statics.getTime() /
                          videoRecorderService
                              .outputVideoDurationInMilliSeconds.value)),
                      status: stats,
                      maskType: EasyLoadingMaskType.black,
                    );
                  }
                });
          } else {
            print("fail 2 1284");
            print(
                "-i ${videoRecorderService.outputVideoPath.value} -ss 00:00:00.000 -vframes 1 -preset ultrafast $thumbImg");
            FFmpegKit.executeAsync(
                "-i ${videoRecorderService.outputVideoPath.value} -ss 00:00:00.000 -vframes 1 -preset ultrafast $thumbImg",
                (session) async {
                  print("FFmpegKit.executeAsync in Command");
                  // Unique session id created for this execution
                  final sessionId = session.getSessionId();
                  print("FFmpegKit.executeAsync sessionId $sessionId");
                  // Command arguments as a single string
                  final command = session.getCommand();
                  print("ffmpeg command $command");

                  // The list of logs generated for this execution
                  final logs = await session.getLogs();
                  print("ffmpegLogs $logs");
                  logs.forEach((element) {
                    print("::");
                    print(element.getMessage());
                  });
                  thumbPath = thumbImg;
                  videoRecorderService.thumbImageUri.value = thumbImg;
                  // setState(() {
                  isProcessing.value = false;
                  isProcessing.refresh();
                  // });
                  if (videoRecorderService.outputVideoPath.value != "") {
                    // _outputVideoController.dispose();
                    openPreviewWindow(skip: true);
                  }
                },
                null,
                (statics) {
                  // First statistics is always wrong so if first one skip it
                  if (_firstStat) {
                    _firstStat = false;
                  } else {
                    String stats =
                        "Generating cover image ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
                    EasyLoading.showProgress(
                      ((statics.getTime() /
                          videoRecorderService
                              .outputVideoDurationInMilliSeconds.value)),
                      status: stats,
                      maskType: EasyLoadingMaskType.black,
                    );
                  }
                });
          }

          return null;
        }
      } else {
        print("Text Filter done");
        FFmpegKit.executeAsync(
            // '-y -i ${videoRecorderService.outputVideoPath.value} $textFilter $watermark -filter_complex "$textFilterArgs$watermarkArgs" -map "[final]" -map 0:a -preset ultrafast -crf 23  $outputVideo',
            '-y -i ${videoRecorderService.outputVideoPath.value} $textFilter $watermark -filter_complex "$textFilterArgs$watermarkArgs" -map "$mapVar" -map 0:a -preset superfast -crf 23  $outputVideo',
            (session) async {
              print("FFmpegKit.executeAsync in Command");
              // Unique session id created for this execution
              final sessionId = session.getSessionId();
              print("FFmpegKit.executeAsync sessionId $sessionId");
              // Command arguments as a single string
              final command = session.getCommand();
              print("ffmpeg command $command");

              // The list of logs generated for this execution
              final logs = await session.getLogs();
              print("ffmpegLogs $logs");
              logs.forEach((element) {
                print("::");
                print(element.getMessage());
              });

              // The list of statistics generated for this execution (only available on FFmpegSession)
              // final statistics = await (session).getStatistics();

              // setState(() {
              videoPath = outputVideo;
              videoRecorderService.outputVideoPath.value = outputVideo;
              videoPath = outputVideo;
              // _outputVideoController.dispose();
              print("fail 3 1363");
              print(
                  "-i $videoPath -ss 00:00:00.000 -vframes 1 -preset ultrafast $thumbImg");
              FFmpegKit.executeAsync(
                  "-i $videoPath -ss 00:00:00.000 -vframes 1 -preset ultrafast  $thumbImg",
                  (session) async {
                    print("FFmpegKit.executeAsync in Command");
                    // Unique session id created for this execution
                    final sessionId = session.getSessionId();
                    print("FFmpegKit.executeAsync sessionId $sessionId");
                    // Command arguments as a single string
                    final command = session.getCommand();
                    print("ffmpeg command $command");

                    // The list of logs generated for this execution
                    final logs = await session.getLogs();
                    print("ffmpegLogs $logs");
                    logs.forEach((element) {
                      print("::");
                      print(element.getMessage());
                    });
                    thumbPath = thumbImg;
                    videoRecorderService.thumbImageUri.value = thumbImg;

                    isProcessing.value = false;
                    isProcessing.refresh();
                    // _outputVideoController.dispose();
                    openPreviewWindow();
                  },
                  null,
                  (statics) {
                    // First statistics is always wrong so if first one skip it
                    if (_firstStat) {
                      _firstStat = false;
                    } else {
                      String stats =
                          "Generating cover image ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
                      EasyLoading.showProgress(
                        ((statics.getTime() /
                            videoRecorderService
                                .outputVideoDurationInMilliSeconds.value)),
                        status: stats,
                        maskType: EasyLoadingMaskType.black,
                      );
                    }
                  });
              // }

              return null;
              // });
            },
            null,
            (statics) {
              // First statistics is always wrong so if first one skip it
              if (_firstStat) {
                _firstStat = false;
              } else {
                String stats =
                    "Adding Text Filter ${((statics.getTime() / videoRecorderService.outputVideoDurationInMilliSeconds.value) * 100).ceil()}%";
                EasyLoading.showProgress(
                  ((statics.getTime() /
                      videoRecorderService
                          .outputVideoDurationInMilliSeconds.value)),
                  status: stats,
                  maskType: EasyLoadingMaskType.black,
                );
              }
            });
      }
    } catch (e) {
      print("error Text Filter exception $e");
      EasyLoading.dismiss();
    }
  }

  void openPreviewWindow({bool skip = false}) async {
    if (skip == true) {
      EasyLoading.dismiss(animation: true);
      Get.back();
      Get.offNamed("/video-preview");
      Get.offNamed("/video-submit");
    } else {
      final VideoPlayerController _videoController = VideoPlayerController.file(
        File(
          videoRecorderService.outputVideoPath.value,
        ),
      );
      await _videoController.initialize();
      _videoController.play();
      _videoController.setLooping(true);

      previewVideoController = _videoController;
      Get.back();
      Get.offNamed("/video-preview");
      EasyLoading.dismiss(animation: true);
      _firstStat = true;
    }
  }

  void nextStep(BuildContext context) async {
    bool _firstStat = true;
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    await videoEditorController!.exportVideo(
      preset: VideoExportPreset.ultrafast,
      onProgress: (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          int totalMillis = 0;
          if (videoEditorController!.video.value.duration.inMilliseconds <=
              videoRecorderService.selectedVideoLength.value * 1000) {
            totalMillis =
                videoEditorController!.video.value.duration.inMilliseconds;
          } else {
            totalMillis =
                (videoRecorderService.selectedVideoLength.value * 1000).toInt();
          }
          videoRecorderService.outputVideoDurationInMilliSeconds.value =
              totalMillis;
          videoRecorderService.outputVideoDurationInMilliSeconds.refresh();
          String stats =
              "Exporting video ${((statics.getTime() / totalMillis) * 100).ceil()}%";
          EasyLoading.showProgress(
            ((statics.getTime() / totalMillis)),
            status: stats,
            maskType: EasyLoadingMaskType.black,
          );
        }
      },
      onCompleted: (file) async {
        EasyLoading.dismiss(animation: true);
        // _isExporting.value = false;
        // if (!mounted) return;
        if (file != null) {
          previewVideoController = VideoPlayerController.file(file);
          await previewVideoController!.initialize();
          previewVideoController!.play();
          previewVideoController!.setLooping(true);
          showTextFilter.value = true;
          showTextFilter.refresh();
          videoRecorderService.outputVideoAfter1StepPath.value = file.path;
          videoRecorderService.outputVideoAfter1StepPath.refresh();
          videoRecorderService.outputVideoPath.value = file.path;
          videoRecorderService.outputVideoPath.refresh();
          videoEditorController!.video.pause();
          openStoriesEditor();
        }
        // setState(() => _exported = true);
        // Misc.delayed(2000, () => setState(() => _exported = false));
      },
    );
  }

  void openStoriesEditor() {
    /*Get.back(closeOverlays: true);
    videoEditorController!.dispose();
    videoEditorController!.video.dispose();
    */
    Get.offNamed("/stories-editor");
    videoEditorController = null;
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: false,
      transitionDuration: Duration(
        milliseconds: 400,
      ),
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: StoriesEditor(
                giphyKey: '[HERE YOUR API KEY]',
                onDone: (uri) {
                  processTextFilter(uri);
                },
                fontFamilyList: fonts,
                editorBackgroundColor: Colors.transparent,
                middleBottomWidget: Container(),
                onClose: () {
                  if (previewVideoController != null)
                    previewVideoController!.dispose();
                  print("onClose Called");
                  showTextFilter.value = false;
                  showTextFilter.refresh();
                  Get.back();
                  completelyExitRecorder.call();
                },
                onSkip: () {
                  processTextFilter("", skip: true);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  trimVideoToMaxLength(String dataSource, {VoidCallback? onComplete}) async {
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print(appDirectory);
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String thumbImg = '$outputDirectory/${currentTime}.jpg';
    final String outputVideo = '$outputDirectory/${currentTime}.mp4';
    File file = File(dataSource);
    String finalDuration = CommonHelper.getDurationString(Duration(
        seconds: videoRecorderService.selectedVideoLength.value.toInt()));
    String comm = '-i ${file.path} -ss 00:00:00 -to $finalDuration -vf "scale=' +
        "'min(560,iw)'" +
        ':-2,setsar=1:1" -pix_fmt yuv420p -r 24 -c:v libx264  -preset superfast -crf 23  $outputVideo';
    await FFmpegKit.executeAsync(
      // '-y -i $videoPath $audioFile  -filter_complex "$mergeAudioArgs[0:v]scale=560:-2$watermarkArgs" -c:v libx264 $mergeAudioArgs2 $audioFileArgs -preset ultrafast -crf 23  $outputVideo',
      '-y $comm',
      (session) async {
        EasyLoading.dismiss(animation: true);
        print("FFmpegKit.executeAsync in Command");

        // Unique session id created for this execution
        final sessionId = session.getSessionId();
        print("FFmpegKit.executeAsync sessionId $sessionId");
        // Command arguments as a single string
        final command = session.getCommand();
        print("ffmpeg command $command");

        // The list of logs generated for this execution
        final logs = await session.getLogs();
        print("ffmpegLogs $logs");
        logs.forEach((element) {
          print("::");
          print(element.getMessage());
        });

        // The list of statistics generated for this execution (only available on FFmpegSession)
        // final statistics = await (session).getStatistics();

        videoPath = outputVideo;
        videoRecorderService.outputVideoPath.value = outputVideo;
        videoRecorderService.outputVideoPath.refresh();
        onComplete!.call();
      },
      null,
      (statics) {
        // First statistics is always wrong so if first one skip it
        if (_firstStat) {
          _firstStat = false;
        } else {
          print(
              "${videoRecorderService.selectedVideoLength.value} statics.getTime() / videoRecorderService.selectedVideoLength.value * 1000   statics.getTime() ${statics.getTime()} ${((statics.getTime() / (videoRecorderService.selectedVideoLength.value * 1000)) * 100).ceil()}% ${statics.getTime() / videoRecorderService.selectedVideoLength.value * 1000} ${statics.getTime()} / ${videoRecorderService.selectedVideoLength.value * 1000}");
          String stats =
              "Trimming Video ${((statics.getTime() / (videoRecorderService.selectedVideoLength.value * 1000)) * 100).ceil()}%";
          EasyLoading.showProgress(
            ((statics.getTime() /
                (videoRecorderService.selectedVideoLength.value * 1000))),
            status: stats,
            maskType: EasyLoadingMaskType.black,
          );
        }
      },
    );
  }

  void submitUploadVideo() {
    if (dashboardService.isUploading.value == false) {
      FocusManager.instance.primaryFocus!.unfocus();
      if (key.currentState!.validate() &&
          detectableTextVideoDescriptionController.value.text != "") {
        uploadVideo(
          videoRecorderService.outputVideoPath.value,
          videoRecorderService.thumbImageUri.value,
        ).whenComplete(() {
          print("Video Uploaded successfully");
          Get.delete<VideoRecorderController>(force: true);
          AuthService authService = Get.find();
          UserController userController = Get.find();
          authService.currentUser.value.userVideos = [];
          authService.currentUser.refresh();
          userController.getMyProfile();
        });
        Get.offAllNamed('/home');
      } else {
        Fluttertoast.showToast(
            msg: "Enter Video Description", textColor: Get.theme.primaryColor);
      }
    }
  }

  Future<void> generateAIDescription() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: mainService.setting.value.geminiApiKey,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (aiPrompt.length > 15) {
      aiPrompt = aiPrompt + ". Do not add markdown in the content.";
      EasyLoading.show(status: "AI generating video description".tr + "...");
      final content = [Content.text(aiPrompt)];
      final response = await model.generateContent(content);
      print("AI response.text! ${response.text!}");
      detectableTextVideoDescriptionController.value.text = response.text!;
      detectableTextVideoDescriptionController.refresh();

      EasyLoading.dismiss();
      Get.back();
    } else {
      Fluttertoast.showToast(msg: "Provide a Prompt first".tr);
    }
  }
}
