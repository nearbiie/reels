import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class ChatSetting extends StatefulWidget {
  ChatSetting({
    Key? key,
  }) : super(key: key);
  @override
  _ChatSettingState createState() => _ChatSettingState();
}

class _ChatSettingState extends State<ChatSetting> {
  ChatController chatController = Get.find();
  MainService mainService = Get.find();
  ChatService chatService = Get.find();

  bool isEdit = false;

  @override
  void initState() {
    chatController.getChatSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Obx(
      () => Scaffold(
        backgroundColor: Get.theme.primaryColor,
        key: chatController.scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Get.theme.iconTheme.color, //change your color here
            ),
            backgroundColor: Get.theme.primaryColor,
            title: Text(
              "Chat Setting",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: Get.theme.indicatorColor,
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  chatController.updateChatSetting();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: mainService.setting.value.buttonColor,
                  ),
                  child: "Update".text.size(10).uppercase.center.color(mainService.setting.value.buttonTextColor!).make().centered().pSymmetric(h: 8, v: 0),
                ).pSymmetric(h: 15, v: 8),
              )
            ],
            centerTitle: true,
          ),
        ),
        body: SafeArea(
          child: (!chatController.showLoader.value)
              ? Container(
                  color: Get.theme.primaryColor,
                  height: Get.height,
                  width: Get.width,
                  child: SingleChildScrollView(
                    controller: chatController.scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 0.8,
                        ),
                        Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                color: Get.theme.primaryColor,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        children: [
                                          "My followers only".text.color(Get.theme.indicatorColor).make(),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 0.6,
                                        child: CupertinoSwitch(
                                          activeColor: mainService.setting.value.buttonColor,
                                          value: chatService.chatSettings.value == "FW" ? true : false,
                                          onChanged: (value) {
                                            chatService.chatSettings.value = value ? "FW" : "";
                                            chatService.chatSettings.refresh();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                color: Get.theme.primaryColor,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        children: [
                                          "Two way followings".text.color(Get.theme.indicatorColor).make(),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 0.6,
                                        child: CupertinoSwitch(
                                          activeColor: mainService.setting.value.buttonColor,
                                          value: chatService.chatSettings.value == "FL" ? true : false,
                                          onChanged: (value) {
                                            chatService.chatSettings.value = value ? "FL" : "";
                                            chatService.chatSettings.refresh();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: Get.theme.primaryColor,
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                  ),
                ),
        ),
      ),
    );
  }
}
