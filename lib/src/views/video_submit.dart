import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class VideoSubmit extends StatefulWidget {
  VideoSubmit();
  @override
  _VideoSubmitState createState() => _VideoSubmitState();
}

class _VideoSubmitState extends State<VideoSubmit> with SingleTickerProviderStateMixin {
  VideoRecorderController videoRecorderController = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
  MainService mainService = Get.find();
  DashboardController dashboardController = Get.find();
  DashboardService dashboardService = Get.find();

  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    getImageWidth();
    super.initState();
  }

  bool fitHeight = false;
  getImageWidth() async {
    File image = new File(videoRecorderService.thumbImageUri.value); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    if (decodedImage.width > decodedImage.height) {
      setState(() {
        fitHeight = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );
    return WillPopScope(
      onWillPop: () {
        videoRecorderService.videoProgressPercent.value = 0;
        videoRecorderService.videoProgressPercent.refresh();
        videoRecorderController.isVideoRecorded = false;
        videoRecorderController.showProgressBar.value = false;
        videoRecorderController.showProgressBar.refresh();
        Get.delete<VideoRecorderController>(force: true);
        Get.put(VideoRecorderController(), permanent: true);
        Get.offAllNamed('/video-recorder');
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 16,
            color: Get.theme.indicatorColor, //change your color here
          ),
          backgroundColor: Get.theme.primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Get.theme.iconTheme.color,
              size: 25,
            ),
            onPressed: () {
              Get.delete<VideoRecorderController>(force: true);
              videoRecorderService.videoProgressPercent.value = 0;
              videoRecorderService.videoProgressPercent.refresh();
              videoRecorderController.isVideoRecorded = false;
              videoRecorderController.showProgressBar.value = false;
              videoRecorderController.showProgressBar.refresh();
              Get.put(VideoRecorderController(), permanent: true);
              Get.offAllNamed('/video-recorder');
            },
          ),
          title: "Post".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
          centerTitle: true,
        ),
        backgroundColor: Get.theme.primaryColor,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: SingleChildScrollView(
            child: publishPanel(),
          ),
        ),
      ),
    );
  }

  Widget publishPanel() {
    return Stack(
      children: [
        Container(
          color: Get.theme.primaryColor,
          // height: Get.height,
          child: Form(
            key: videoRecorderController.key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    if (videoRecorderService.thumbImageUri.value != '')
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Scaffold(
                              appBar: PreferredSize(
                                preferredSize: Size.fromHeight(45.0),
                                child: AppBar(
                                  leading: InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                      color: Get.theme.iconTheme.color,
                                    ),
                                  ),
                                  iconTheme: IconThemeData(
                                    color: Colors.black, //change your color here
                                  ),
                                  backgroundColor: Get.theme.primaryColor,
                                  centerTitle: true,
                                ),
                              ),
                              backgroundColor: Get.theme.primaryColor,
                              body: Center(
                                child: PhotoView(
                                  enableRotation: true,
                                  imageProvider: FileImage(File(videoRecorderService.thumbImageUri.value)),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.1,
                      vertical: Get.height * 0.01,
                    ),
                    child: Container(
                      height: Get.height * (0.4),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: mainService.setting.value.dividerColor!,
                            blurRadius: 5.0,
                          ),
                        ],
                        color: Get.theme.shadowColor,
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: videoRecorderService.thumbImageUri.value != ''
                              ? new FileImage(
                                  File(
                                    videoRecorderService.thumbImageUri.value,
                                  ),
                                )
                              : AssetImage("assets/images/splash.png") as ImageProvider,
                          fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: Get.height / 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .1, vertical: 0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: VideoDescriptionWidget(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: Get.width,
                          child: Container(
                            child: Theme(
                              data: Get.theme.copyWith(
                                canvasColor: Colors.black,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        color: Get.theme.iconTheme.color,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Privacy Setting",
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            videoRecorderController.privacy = 0;
                                          });
                                        },
                                        child: Container(
                                          decoration:
                                              BoxDecoration(borderRadius: BorderRadius.circular(4), color: videoRecorderController.privacy == 0 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                          child: "Public"
                                              .text
                                              .size(13)
                                              .color(videoRecorderController.privacy == 0 ? Get.theme.indicatorColor : Get.theme.primaryColor)
                                              .center
                                              .make()
                                              .centered()
                                              .pSymmetric(h: 15, v: 8),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            videoRecorderController.privacy = 1;
                                          });
                                        },
                                        child: Container(
                                          decoration:
                                              BoxDecoration(borderRadius: BorderRadius.circular(4), color: videoRecorderController.privacy == 1 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                          child: "Private"
                                              .text
                                              .size(13)
                                              .color(videoRecorderController.privacy == 1 ? Get.theme.indicatorColor : Get.theme.primaryColor)
                                              .center
                                              .make()
                                              .centered()
                                              .pSymmetric(h: 15, v: 8),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            videoRecorderController.privacy = 2;
                                          });
                                        },
                                        child: Container(
                                          decoration:
                                              BoxDecoration(borderRadius: BorderRadius.circular(4), color: videoRecorderController.privacy == 2 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                          child: "Followers"
                                              .text
                                              .size(13)
                                              .color(videoRecorderController.privacy == 2 ? Get.theme.indicatorColor : Get.theme.primaryColor)
                                              .center
                                              .make()
                                              .centered()
                                              .pSymmetric(h: 15, v: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  Get.offNamed("/home");
                                },
                                child: Container(
                                  height: 45,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Get.theme.highlightColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Get.theme.primaryColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        fontFamily: 'RockWellStd',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () async {
                                  videoRecorderController.submitUploadVideo();
                                },
                                child: Container(
                                  height: 45,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Get.theme.highlightColor,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Submit",
                                          style: TextStyle(
                                            color: Get.theme.primaryColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20,
                                            fontFamily: 'RockWellStd',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
        /*Obx(() {
          return (videoRecorderController.isUploading.value == true)
              ? Container(
                  width: Get.width,
                  height: Get.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: new ColorFilter.mode(Get.theme.highlightColor.withOpacity(1), BlendMode.dstATop),
                      image: videoRecorderService.thumbImageUri.value != ''
                          ? new FileImage(
                              File(
                                videoRecorderService.thumbImageUri.value,
                              ),
                            )
                          : AssetImage("assets/images/splash.png") as ImageProvider,
                      fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                    ),
                    color: Colors.black26,
                  ),
                  child: Obx(() {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        videoRecorderController.uploadProgress.value >= 1
                            ? Container(
                                width: Get.width * 0.45,
                                height: Get.width * 0.45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: Get.theme.highlightColor, width: 10),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/checked.svg',
                                  color: Get.theme.highlightColor,
                                ).pSymmetric(h: 45, v: 45),
                              )
                            : Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Get.theme.shadowColor,
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        videoRecorderController.uploadProgress.value >= 1
                                            ? SvgPicture.asset(
                                                'assets/icons/checked.svg',
                                                width: Get.width * 0.3,
                                                color: Get.theme.highlightColor,
                                              )
                                            : Center(
                                                child: CircularPercentIndicator(
                                                  progressColor: Get.theme.highlightColor,
                                                  percent: videoRecorderController.uploadProgress.value,
                                                  radius: 60.0,
                                                  lineWidth: 8.0,
                                                  circularStrokeCap: CircularStrokeCap.round,
                                                  center: Text(
                                                    (videoRecorderController.uploadProgress.value * 100).toStringAsFixed(2) + "%",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 20.0,
                        ),
                        videoRecorderController.uploadProgress.value >= 1
                            ? Column(
                                children: [
                                  Center(
                                    child: Container(
                                      child: Text(
                                        "Yay!!",
                                        style: TextStyle(
                                          color: Get.theme.highlightColor,
                                          fontSize: 45,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  "Your video is posted".text.color(Get.theme.indicatorColor).wide.size(22).make(),
                                ],
                              )
                            : Container(),
                      ],
                    );
                  }),
                )
              : Container();
        }),*/
      ],
    );
  }
}
