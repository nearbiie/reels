import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class HashVideosView extends StatelessWidget {
  HashVideosView({Key? key}) : super(key: key);

final  SearchViewController searchController = Get.find();
 final SearchService searchService = Get.find();
 final AuthService authService = Get.find();
 final MainService mainService = Get.find();
final  DashboardService dashboardService = Get.find();
 final DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        searchService.currentHashTag.value = BannerModel.fromJSON({});
        searchService.currentHashTag.refresh();
        print("searchService.currentHashTag.value ${searchService.currentHashTag.value.tag}");
        if (searchService.navigatedToHashVideoPage.value) {
          dashboardService.showFollowingPage.value = false;
          dashboardService.showFollowingPage.refresh();
          Get.offNamed('/home');
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        backgroundColor: Get.theme.primaryColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Get.theme.primaryColor,
          leadingWidth: 50,
          leading: GestureDetector(
            onTap: () async {
              searchService.currentHashTag.value = BannerModel.fromJSON({});
              searchService.currentHashTag.refresh();
              print("searchService.currentHashTag.value ${searchService.currentHashTag.value.tag}");
              if (searchService.navigatedToHashVideoPage.value) {
                dashboardService.showFollowingPage.value = false;
                dashboardService.showFollowingPage.refresh();
                Get.offNamed('/home');
                return Future.value(false);
              }
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Get.theme.iconTheme.color,
            ),
          ),
          title: ((searchService.currentHashTag.value.tag.contains("#") ? "" : "#") + '${searchService.currentHashTag.value.tag}').text.make(),
        ),
        body: Container(
          height: Get.height - (dashboardService.bottomPadding.value + Get.mediaQuery.viewPadding.bottom + 50),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: searchController.hashScrollController,
                child: Container(
                  width: Get.width,
                  color: Get.theme.primaryColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      searchService.currentHashTag.value.tag != ""
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  child: Text(
                                    (searchService.currentHashTag.value.tag.contains("#") ? "" : "#") + '${searchService.currentHashTag.value.tag}',
                                    style: TextStyle(
                                      color: Get.theme.highlightColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      searchService.currentHashTag.value.banner != ""
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              height: 180,
                              width: Get.width,
                              child: CachedNetworkImage(
                                imageUrl: searchService.currentHashTag.value.banner,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Text(
                              "Top Videos",
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          return (searchService.hashVideoData.value.videos.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 3, right: 3),
                                  child: Container(
                                    width: Get.width,
                                    child: GridView.builder(
                                      primary: false,
                                      padding: const EdgeInsets.all(2),
                                      shrinkWrap: true,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                        height: 150,
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                      ),
                                      // itemCount: searchService.hashData.value.videos.length,
                                      itemCount: searchService.hashVideoData.value.videos.length,
                                      itemBuilder: (BuildContext context, int i) {
                                        return GestureDetector(
                                          onTap: () async {
                                            print("searchService.currentHashTag.value.id");
                                            print(searchService.currentHashTag.value.id.toString() + mainService.userVideoObj.value.hashTag + searchService.currentHashTag.value.tag);
                                            if (searchService.currentHashTag.value.id > 0) {
                                              mainService.userVideoObj.value.hashTag = searchService.currentHashTag.value.tag;
                                              mainService.userVideoObj.value.name = "#${searchService.currentHashTag.value.tag}";
                                            } else {
                                              mainService.userVideoObj.value.userId = searchService.hashVideoData.value.videos[i].userId;
                                              mainService.userVideoObj.value.name = searchService.hashVideoData.value.videos[i].username + "'s";
                                            }
                                            mainService.userVideoObj.value.videoId = searchService.hashVideoData.value.videos[i].id;
                                            searchService.currentHashTag.value = BannerModel.fromJSON({});
                                            searchService.currentHashTag.refresh();
                                            dashboardController.getVideos().whenComplete(() {
                                              dashboardService.currentPage.value = 0;
                                              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                              dashboardService.pageController.refresh();
                                            });
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              Container(
                                                  height: Get.height,
                                                  width: Get.width,
                                                  child: searchService.hashVideoData.value.videos[i].thumb != ""
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(mainService.setting.value.gridBorderRadius),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Get.theme.shadowColor.withOpacity(0.5),
                                                                blurRadius: 3.0, // soften the shadow
                                                                spreadRadius: 0.0, //extend the shadow
                                                                offset: Offset(
                                                                  0.0, // Move to right 10  horizontally
                                                                  0.0, // Move to bottom 5 Vertically
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          // padding: const EdgeInsets.all(1),
                                                          child: CachedNetworkImage(
                                                            imageUrl: searchService.hashVideoData.value.videos[i].thumb,
                                                            placeholder: (context, url) => Center(
                                                              child: CommonHelper.showLoaderSpinner(Get.theme.highlightColor),
                                                            ),
                                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          child: Image.asset(
                                                            'assets/images/noVideo.jpg',
                                                            fit: BoxFit.fill,
                                                          ),
                                                        )),
                                              Positioned(
                                                bottom: 20,
                                                child: Container(
                                                  width: 35.0,
                                                  height: 35.0,
                                                  decoration: new BoxDecoration(
                                                    borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                    border: new Border.all(
                                                      color: Get.theme.shadowColor.withOpacity(0.5),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    width: 35.0,
                                                    height: 35.0,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(50.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: searchService.hashVideoData.value.videos[i].dp,
                                                        placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                        height: 60.0,
                                                        width: 60.0,
                                                        fit: BoxFit.fitHeight,
                                                        errorWidget: (a, b, c) {
                                                          return Image.asset(
                                                            "assets/images/video-logo.png",
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 5,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      searchService.hashVideoData.value.videos[i].username,
                                                      style: TextStyle(
                                                        color: Get.theme.primaryColor,
                                                        fontSize: 11,
                                                        fontFamily: 'RockWellStd',
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    searchService.hashVideoData.value.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                    searchService.hashVideoData.value.videos[i].isVerified == true
                                                        ? Icon(
                                                            Icons.verified,
                                                            color: Colors.blueAccent,
                                                            size: 16,
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : (!searchController.showLoader.value)
                                  ? Center(
                                      child: Container(
                                        height: Get.height - 360,
                                        width: Get.width,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.videocam,
                                              size: 30,
                                              color: Get.theme.iconTheme.color,
                                            ),
                                            Text(
                                              "No Videos Found",
                                              style: TextStyle(
                                                color: Get.theme.indicatorColor.withOpacity(0.6),
                                                fontSize: 15,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
