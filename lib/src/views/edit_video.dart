import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class EditVideo extends StatefulWidget {
  EditVideo({
    Key? key,
  }) : super(key: key);

  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> with SingleTickerProviderStateMixin {
  UserController userController = Get.find();
  MainService mainService = Get.find();
  late AnimationController animationController;
  VideoRecorderController videoRecorderController = Get.find();
  UserService userService = Get.find();
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    setState(() {
      videoRecorderController.detectableTextVideoDescriptionController.value.text = userService.currentEditVideo.description;
      userController.privacy = userService.currentEditVideo.privacy;
      userController.descriptionTextController = new TextEditingController(text: CommonHelper.removeAllHtmlTags(userService.currentEditVideo.description));
    });

    super.initState();
  }

  bool fitHeight = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Get.theme.primaryColor,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Get.theme.iconTheme.color,
            size: 25,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Post',
          style: TextStyle(color: Get.theme.indicatorColor),
        ),
      ),
      key: userController.editVideoScaffoldKey,
      body: SingleChildScrollView(
        child: publishPanel(),
      ),
    );
  }

  Widget publishPanel() {
    // const Map<String, int> privacies = {'Public': 0, 'Private': 1, 'Only Followers': 2};
    return Stack(
      children: [
        Column(
          children: [
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                color: Get.theme.primaryColor,
                height: Get.height,
                child: Form(
                  key: userController.editVideoFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: Get.height / 7.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          height: 1,
                          child: Container(
                            color: Get.theme.indicatorColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Container(
                        height: Get.height / 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Get.width * .05, vertical: 0),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: VideoDescriptionWidget().paddingOnly(top: 15),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: Get.width,
                                child: Container(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
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
                                                  userController.privacy = 0;
                                                });
                                              },
                                              child: Container(
                                                decoration:
                                                    BoxDecoration(borderRadius: BorderRadius.circular(4), color: userController.privacy == 0 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                                child: "Public"
                                                    .text
                                                    .size(13)
                                                    .color(userController.privacy == 0 ? Get.theme.indicatorColor : Get.theme.primaryColor)
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
                                                  userController.privacy = 1;
                                                });
                                              },
                                              child: Container(
                                                decoration:
                                                    BoxDecoration(borderRadius: BorderRadius.circular(4), color: userController.privacy == 1 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                                child: "Private"
                                                    .text
                                                    .size(13)
                                                    .color(userController.privacy == 1 ? Get.theme.indicatorColor : Get.theme.primaryColor)
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
                                                  userController.privacy = 2;
                                                });
                                              },
                                              child: Container(
                                                decoration:
                                                    BoxDecoration(borderRadius: BorderRadius.circular(4), color: userController.privacy == 2 ? Get.theme.highlightColor : Get.theme.iconTheme.color),
                                                child: "Followers"
                                                    .text
                                                    .size(13)
                                                    .color(userController.privacy == 2 ? Get.theme.indicatorColor : Get.theme.primaryColor)
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
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent, padding: EdgeInsets.all(10), shadowColor: Colors.transparent,
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(100.0),
                                        // ),
                                      ),
                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: Get.theme.highlightColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Get.theme.indicatorColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        padding: EdgeInsets.all(10), shadowColor: Colors.transparent,
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(100.0),
                                        // ),
                                      ),
                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: Get.theme.highlightColor,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Update",
                                                style: TextStyle(
                                                  color: Get.theme.indicatorColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 20,
                                                  fontFamily: 'RockWellStd',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Icon(
                                                  Icons.send,
                                                  color: Get.theme.iconTheme.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus!.unfocus();

                                        // Validate returns true if the form is valid, otherwise false.
                                        if (userController.editVideoFormKey.currentState!.validate() && videoRecorderController.detectableTextVideoDescriptionController.value.text!="") {
                                          userController.editVideo(
                                            userService.currentEditVideo.videoId,
                                            videoRecorderController.detectableTextVideoDescriptionController.value.text,
                                            userController.privacy,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              behavior: SnackBarBehavior.floating,
                                              content: Text("Enter Video Description"),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
