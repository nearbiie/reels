import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class CommentController extends GetxController {
  AuthService authService = Get.find();
  PostService postService = Get.find();

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  // OverlayEntry loader;
  CommentData commentObj = new CommentData();
  ScrollController scrollController1 = new ScrollController();
  ScrollController scrollController2 = new ScrollController();
  int page = 1;
  bool showLoadMore = true;
  CommentController() {
    scrollController1 = new ScrollController();
    scrollController2 = new ScrollController();
  }
  @override
  void onInit() {
    // TODO: implement onInit
    scaffoldKey = new GlobalKey<ScaffoldState>();
    super.onInit();
  }

/*  Future<void> getComments(int videoId) async {
    print("getComments $videoId");

    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'fetch-video-comments',
        requestData: {
          "page": page.toString(),
          "video_id": videoId.toString(),
        },
        method: "post");

    print("comments response.body ${response.body}");
    List<CommentData> newComments = parseComments(json.decode(response.body)['data']);
    postService.commentsObj.value.comments.addAll(newComments);
    scrollController2.addListener(() {
      if (scrollController2.position.pixels == scrollController2.position.maxScrollExtent) {
        if (postService.commentsObj.value.comments.length != 20 && showLoadMore) {
          loadMore(videoId);
        }
      }
    });
    scrollController1.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadMore(int videoId) async {
    page = page + 1;

    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'fetch-video-comments',
        requestData: {
          "page": page.toString(),
          "video_id": videoId.toString(),
        },
        method: "post");

    print("comments response.body ${response.body}");
    List<CommentData> newComments = parseComments(json.decode(response.body)['data']);
    postService.commentsObj.value.comments.addAll(newComments);
    scrollController2.addListener(() {
      if (scrollController2.position.pixels == scrollController2.position.maxScrollExtent) {
        if (postService.commentsObj.value.comments.length != 20 && showLoadMore) {
          loadMore(videoId);
        }
      }
    });
    scrollController1.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }*/

  Future<void> addComment(int videoId) async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    commentObj.videoId = videoId;
    commentObj.userId = authService.currentUser.value.id;
    commentObj.accessToken = authService.currentUser.value.accessToken;
    commentObj.userDp = authService.currentUser.value.userDP;
    commentObj.username = authService.currentUser.value.username;
    commentObj.time = 'just now';

    try {
      var response =
          await CommonHelper.sendRequestToServer(endPoint: 'add-comment', requestData: {"video_id": commentObj.videoId.toString(), "comment": commentObj.comment.toString()}, method: "post");
      int commentId = json.decode(response.body)['comment_id'];
      commentObj.commentId = commentId;
      postService.commentsObj.value.comments.add(commentObj);
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "There's some issue with the server");
    }
  }

  List<CommentData> parseComments(attributesJson) {
    List list = attributesJson;
    List<CommentData> attrList = list.map((data) => CommentData.fromJSON(data)).toList();
    return attrList;
  }
}
