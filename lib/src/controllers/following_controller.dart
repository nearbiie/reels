import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;

import '../core.dart';

class FollowingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  FollowingService followingService = Get.find();

  ScrollController scrollController = ScrollController();
  var showLoader = false.obs;
  bool showLoadMore = true;
  int curIndex = 0;
  int followUserId = 0;
  String searchKeyword = '';
  bool followUnfollowLoader = false;
  var searchController = TextEditingController();
  DashboardController homeCon = DashboardController();
  UserController userCon = UserController();
  bool noRecord = false;
  VoidCallback? listener;

  Future followingUsers(userId, page) async {
    EasyLoading.show(
      status: "loading..",
      maskType: EasyLoadingMaskType.black,
    );
    scrollController = new ScrollController();
    if (page == 1) {
      followingService.usersData.value = FollowingModel.fromJSON({});
      followingService.usersData.refresh();
    }
    print("{'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword}");
    print({'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword});
    HTTP.Response response =
        await CommonHelper.sendRequestToServer(endPoint: 'following-users-list', requestData: {'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword}, method: "post");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          followingService.usersData.value.users.addAll(FollowingModel.fromJSON(json.decode(response.body)['data']).users);
        } else {
          followingService.usersData.value = FollowingModel.fromJSON(json.decode(response.body)['data']);
        }
        followingService.usersData.refresh();
        EasyLoading.dismiss();
        followingService.usersData.refresh();
        if (followingService.usersData.value.users.length == followingService.usersData.value.totalRecords) {
          showLoadMore = false;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if (followingService.usersData.value.users.length != followingService.usersData.value.totalRecords && showLoadMore) {
              page = page + 1;
              followingUsers(userId, page);
            }
          }
        });
      }
    }
  }

  Future<void> removeFollower(userId, i) async {
    UserController userCon = Get.find();
    followUnfollowLoader = true;
    HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'remove-follower', requestData: {'remove_to': userId.toString()}, method: "post");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        followUnfollowLoader = false;
        followingService.usersData.value.users.removeWhere((element) => element.id == userId);
        followingService.usersData.refresh();
        userCon.refreshMyProfile();
      } else {
        followUnfollowLoader = false;
      }
    } else {
      showLoader.value = false;
      showLoader.refresh();
      Fluttertoast.showToast(msg: "There is some error");

      throw new Exception(response.body);
    }
  }

  Future getFollowers(userId, page) async {
    EasyLoading.show(
      status: "loading..",
      maskType: EasyLoadingMaskType.black,
    );
    scrollController = new ScrollController();
    if (page == 1) {
      followingService.usersData.value = FollowingModel.fromJSON({});
      followingService.usersData.refresh();
    }

    try {
      HTTP.Response response =
          await CommonHelper.sendRequestToServer(endPoint: 'followers-list', requestData: {'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword}, method: "post");

      if (response.statusCode == 200) {
        print("response.body ${response.body}");
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            followingService.usersData.value.users.addAll(FollowingModel.fromJSON(jsonData['data']).users);
          } else {
            followingService.usersData.value = FollowingModel.fromJSON(jsonData['data']);
          }
          followingService.usersData.refresh();
        } else {
          Fluttertoast.showToast(msg: "Error Fetching Data");
        }
      } else {
        Fluttertoast.showToast(msg: "Error Fetching Data");
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Error Fetching Data");
    }

    EasyLoading.dismiss();
    if (followingService.usersData.value.users.length == followingService.usersData.value.totalRecords) {
      showLoadMore = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (followingService.usersData.value.users.length != followingService.usersData.value.totalRecords && showLoadMore) {
          page = page + 1;
          getFollowers(userId, page);
        }
      }
    });
  }

  Future<void> followUnfollowUser(userId, i) async {
    userCon = UserController();
    followUnfollowLoader = true;
    HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'follow-unfollow-user', requestData: {"follow_to": userId.toString()}, method: "post");

    if (response.statusCode == 200) {
      followUnfollowLoader = false;
      var responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        followingService.usersData.value.users[i].followText = responseBody['followText'];
        followingService.usersData.refresh();
        userCon.refreshMyProfile();
      }
    } else {
      print("Follow Error");
      showLoader.value = false;
      showLoader.refresh();

      EasyLoading.dismiss();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("There is some error"),
        ),
      );
    }
  }

  friendsList(page) async {
    // setState(() {});
    EasyLoading.show(status: "Loading".tr + "...");

    showLoader.value = true;
    showLoader.refresh();
    scrollController = new ScrollController();
    if (page == 1) {
      followingService.usersData.value = FollowingModel.fromJSON({});
      followingService.usersData.refresh();
    }
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'friends-list', requestData: {'page': page.toString(), 'search': searchKeyword}, method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            followingService.friendsData.value.users.addAll(FollowingModel.fromJSON(json.decode(response.body)['data']).users);
          } else {
            followingService.friendsData.value = FollowingModel.fromJSON(json.decode(response.body)['data']);
          }
          if (followingService.friendsData.value.totalRecords == 0 && searchKeyword != "") {
            noRecord = true;
          } else {
            noRecord = false;
          }
          showLoader.value = false;
          showLoader.refresh();
          EasyLoading.dismiss();
          if (followingService.friendsData.value.users.length == followingService.friendsData.value.totalRecords) {
            showLoadMore = false;
          }
          listener = () {
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              if (followingService.friendsData.value.users.length != followingService.friendsData.value.totalRecords && showLoadMore) {
                page = page + 1;
                friendsList(page);
              }
            }
          };
          scrollController.addListener(listener!);
          followingService.friendsData.refresh();
        } else {
          return FollowingModel.fromJSON({});
        }
      } else {
        return FollowingModel.fromJSON({});
      }
    } catch (e) {
      print(e.toString());
      return FollowingModel.fromJSON({});
    }
  }
}
