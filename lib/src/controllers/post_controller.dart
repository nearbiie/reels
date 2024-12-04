import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;

import '../core.dart';

class PostController extends GetxController {
  MainService mainService = Get.find();
  PostService postService = Get.find();
  DashboardService dashboardService = Get.find();

  var showLoader = false.obs;
  showDeleteAlert(parentContext, errorTitle, errorString, commentId, videoId) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          height: 200,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: AlertDialog(
            title: Center(
              child: Text(
                errorTitle,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'RockWellStd',
                ),
              ),
            ),
            insetPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/warning.jpg",
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    errorString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      //color: Color(0xff2e2f34),
                      borderRadius: BorderRadius.all(new Radius.circular(32.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () async {
                              deleteComment(commentId, videoId);
                              Get.back();
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.highlightColor,
                                borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                              ),
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RockWellStd'),
                                ),
                              ),
                            )),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Get.theme.highlightColor,
                              borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "No",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'RockWellStd',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  deleteComment(commentId, videoId) async {
    showLoader.value = true;
    showLoader.refresh();
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(
          endPoint: 'delete-comment',
          requestData: {
            "comment_id": commentId,
            "video_id": videoId,
          },
          method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          postService.commentsObj.value.comments.removeWhere((item) => item.commentId == commentId);
          DashboardController dashboardController = Get.find();
          dashboardController.videoObj.value.totalComments--;
          dashboardController.videoObj.refresh();
          dashboardService.videosData.value.videos[dashboardService.pageIndex.value] = dashboardController.videoObj.value;
          dashboardService.videosData.refresh();
          Fluttertoast.showToast(msg: "Comment deleted Successfully".tr);
        } else {
          // String msg = jsonData['msg'];
          Fluttertoast.showToast(msg: "Comment deleted Failed".tr);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
