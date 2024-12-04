import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class ProfileController extends GetxController {
  ChatService chatService = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();

  var loadMoreUpdateView = false.obs;
  var showLoader = false.obs;
  var emojiShowing = false.obs;

  String amPm = "";
  bool showChatLoader = true;
  int page = 1;
  int userId = 0;
  bool showLoad = false;
  String msg = "";
  String message = "";
  VoidCallback listener = () {};
  double scrollPos = 0.0;
  OnlineUsersModel userObj = OnlineUsersModel();
  ScrollController chatScrollController = new ScrollController();
  var showFloatingScrollToBottom = false.obs;

  @override
  void onInit() {
    scrollController = new ScrollController();
    scaffoldKey = new GlobalKey<ScaffoldState>();

    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
