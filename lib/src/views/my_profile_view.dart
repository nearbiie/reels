import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class MyProfileView extends StatelessWidget {
  final MainService mainService = Get.find();
  final AuthService authService = Get.find();
  final UserService userService = Get.find();
  final UserController userController = Get.find();
  final DashboardController dashboardController = Get.find();
  final DashboardService dashboardService = Get.find();
  final UserProfileController userProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Get.theme.primaryColor,
          key: userController.myProfileScaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Get.theme.primaryColor,
            title: authService.currentUser.value.name.text.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
            centerTitle: true,
            leading: InkWell(
              onTap: () async {
                await dashboardController.getVideos();
                dashboardService.currentPage.value = 0;
                dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                dashboardService.currentPage.refresh();
                dashboardService.pageController.refresh();
              },
              child: Icon(
                Icons.arrow_back,
                color: Get.theme.iconTheme.color,
              ),
            ),
            actions: [
              authService.currentUser.value.accessToken != ''
                  ? IconButton(
                      onPressed: () async {
                        userController.myProfileScaffoldKey.currentState!.openDrawer();
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Get.theme.iconTheme.color,
                        size: 25.0,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await userController.getMyProfile();
            },
            child: WillPopScope(
              onWillPop: () async {
                userController.activeTab.value = 1;
                userController.activeTab.refresh();
                await dashboardController.getVideos();
                dashboardService.currentPage.value = 0;
                dashboardService.currentPage.refresh();
                dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                // dashboardController.dashboardBottomBarController.value!.animateTo(0);

                dashboardService.pageController.refresh();
                return Future.value(true);
              },
              child: Obx(() {
                return !userController.showLoader.value
                    ? Container(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          controller: userController.scrollController1,
                          child: Column(
                            children: [
                              Container(
                                // height: config.App(context).appHeight(50),
                                width: Get.width,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Scaffold(
                                                backgroundColor: Get.theme.primaryColor,
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
                                                      color: Get.theme.iconTheme.color,
                                                    ),
                                                    backgroundColor: Get.theme.primaryColor,
                                                    title: "Profile Picture".text.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
                                                    centerTitle: true,
                                                  ),
                                                ),
                                                body: Obx(
                                                  () => Center(
                                                    child: PhotoView(
                                                      enableRotation: true,
                                                      imageProvider: CachedNetworkImageProvider((authService.currentUser.value.userDP.toLowerCase().contains(".jpg") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains(".jpeg") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains(".png") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains(".gif") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains(".bmp") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains("fbsbx.com") ||
                                                              authService.currentUser.value.userDP.toLowerCase().contains("googleusercontent.com"))
                                                          ? authService.currentUser.value.userDP.replaceAll("s96", "s800")
                                                          : '${baseUrl}default/user-dummy-pic.png'),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: Get.width * (0.30),
                                        width: Get.width * (0.30),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Get.theme.shadowColor.withOpacity(0.5),
                                              blurRadius: 3.0, // soften the shadow
                                              spreadRadius: 0.5, //extend the shadow
                                              offset: Offset(
                                                1.0, // Move to right 10  horizontally
                                                1.0, // Move to bottom 5 Vertically
                                              ),
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: authService.currentUser.value.userDP != ""
                                              ? CachedNetworkImage(
                                                  imageUrl: (authService.currentUser.value.userDP.toLowerCase().contains(".jpg") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains(".jpeg") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains(".png") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains(".gif") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains(".bmp") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains("fbsbx.com") ||
                                                          authService.currentUser.value.userDP.toLowerCase().contains("googleusercontent.com"))
                                                      ? authService.currentUser.value.userDP
                                                      : '${baseUrl}default/user-dummy-pic.png',
                                                  placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                                  fit: BoxFit.fill,
                                                  width: 50,
                                                  height: 50,
                                                  errorWidget: (a, b, c) {
                                                    return Image.asset(
                                                      "assets/images/user.png",
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset('assets/images/user.png'),
                                        ),
                                      ),
                                    ).centered().pOnly(bottom: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        authService.currentUser.value.username.text.textStyle(Get.theme.textTheme.bodyLarge).make(),
                                        authService.currentUser.value.isVerified == true
                                            ? Icon(
                                                Icons.verified,
                                                color: Get.theme.highlightColor,
                                                size: 22,
                                              ).pOnly(left: 5)
                                            : Container()
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Obx(
                                      () => Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              "${authService.currentUser.value.totalVideos}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                                              "Posts".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              "${authService.currentUser.value.totalVideosLike}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                                              "Likes".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (authService.currentUser.value.totalFollowings != '0') {
                                                userService.followListUserId = authService.currentUser.value.id;
                                                userService.followListType.value = 0;
                                                Get.toNamed("/followers", preventDuplicates: false);
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                "${authService.currentUser.value.totalFollowings}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                                                "Following".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (authService.currentUser.value.totalFollowers != '0') {
                                                userService.followListUserId = authService.currentUser.value.id;
                                                userService.followListType.value = 1;
                                                Get.toNamed("/followers", preventDuplicates: false);
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                "${authService.currentUser.value.totalFollowers}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                                                "Followers".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                                              ],
                                            ),
                                          )
                                        ],
                                      ).pSymmetric(h: 20, v: 10),
                                    ),
                                    authService.currentUser.value.bio.isNotEmpty
                                        ? "${authService.currentUser.value.bio}".text.textStyle(Get.theme.textTheme.bodyMedium).make().pSymmetric(v: 5)
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Container(
                                  child: userController.activeTab.value == 1
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Get.theme.iconTheme.color,
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/videos.svg',
                                                  width: 20.0,
                                                  colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                ).pSymmetric(h: 30, v: 9),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  userController.activeTab.value = 2;
                                                  userController.activeTab.refresh();
                                                  userController.getLikedVideos();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Get.theme.shadowColor.withOpacity(0.3),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/liked.svg',
                                                    width: 20.0,
                                                    colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!.withOpacity(0.2), BlendMode.srcIn),
                                                  ).pSymmetric(h: 30, v: 10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  userController.activeTab.value = 1;
                                                  userController.activeTab.refresh();
                                                  if (authService.currentUser.value.userVideos.length == 0) {
                                                    userController.getMyProfile();
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Get.theme.shadowColor.withOpacity(0.3),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/videos.svg',
                                                    width: 20.0,
                                                    colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!.withOpacity(0.2), BlendMode.srcIn),
                                                  ).pSymmetric(h: 30, v: 10),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Get.theme.iconTheme.color,
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/liked.svg',
                                                  width: 20.0,
                                                  colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                ).pSymmetric(h: 30, v: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                ).centered(),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Obx(() {
                                return userController.activeTab.value == 1
                                    ? authService.currentUser.value.userVideos.isNotEmpty
                                        ? Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: GridView.builder(
                                                    padding: EdgeInsets.all(0),
                                                    shrinkWrap: true,
                                                    primary: false,
                                                    physics: BouncingScrollPhysics(),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                      height: 150,
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 2,
                                                      mainAxisSpacing: 2,
                                                    ),
                                                    itemCount: authService.currentUser.value.userVideos.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      final item = authService.currentUser.value.userVideos.elementAt(index);
                                                      return InkWell(
                                                        onTap: () async {
                                                          mainService.userVideoObj.value.userId = authService.currentUser.value.id;
                                                          mainService.userVideoObj.value.videoId = item.videoId;
                                                          mainService.userVideoObj.refresh();
                                                          dashboardService.showFollowingPage.value = false;
                                                          dashboardService.showFollowingPage.refresh();
                                                          dashboardService.currentPage.value = 0;
                                                          dashboardService.currentPage.refresh();
                                                          dashboardService.postIds = [];
                                                          dashboardController.getVideos();
                                                          dashboardService.pageController.value
                                                              .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                          dashboardService.pageController.refresh();
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(0.5),
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Get.theme.shadowColor,
                                                                blurRadius: 3.0, // soften the shadow
                                                                spreadRadius: 0.0, //extend the shadow
                                                                offset: Offset(
                                                                  0.0, // Move to right 10  horizontally
                                                                  0.0, // Move to bottom 5 Vertically
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: Get.width * 0.40,
                                                                child: item.videoGif != ""
                                                                    ? CachedNetworkImage(
                                                                        height: 150,
                                                                        memCacheWidth: 200,
                                                                        width: Get.width * 0.40,
                                                                        imageUrl: item.videoGif,
                                                                        placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                        errorWidget: (context, url, error) => CachedNetworkImage(
                                                                          height: 150,
                                                                          memCacheWidth: 200,
                                                                          width: Get.width * 0.40,
                                                                          imageUrl: item.videoThumbnail,
                                                                          placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                        fit: BoxFit.cover,
                                                                      )
                                                                    : item.videoThumbnail != ""
                                                                        ? CachedNetworkImage(
                                                                            height: 150,
                                                                            memCacheWidth: 200,
                                                                            width: Get.width * 0.40,
                                                                            imageUrl: item.videoThumbnail,
                                                                            placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                            fit: BoxFit.cover,
                                                                          )
                                                                        : Image.asset(
                                                                            'assets/images/noVideo.jpg',
                                                                            height: 150,
                                                                            width: Get.width * 0.40,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                              ),
                                                              Positioned(
                                                                bottom: 10,
                                                                child: Container(
                                                                  width: Get.width * 0.3,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              'assets/icons/liked.svg',
                                                                              width: 15.0,
                                                                              colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            "${item.totalLikes}".text.color(Get.theme.primaryColor).size(13).make(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              'assets/icons/views.svg',
                                                                              width: 15.0,
                                                                              colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            "${CommonHelper.formatter(item.totalViews.toString())}".text.color(Get.theme.primaryColor).size(13).make(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            showCupertinoModalPopup(
                                                                              context: context,
                                                                              builder: (BuildContext context) => CupertinoActionSheet(
                                                                                actions: [
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Edit"),
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                      userService.currentEditVideo = item;
                                                                                      Get.lazyPut(() => VideoRecorderController());
                                                                                      Get.toNamed("/edit-video");
                                                                                    },
                                                                                  ),
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Delete"),
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                      userController.showDeleteAlert(
                                                                                          "Delete Confirmation".tr, "Do you really want to delete the video".tr, item.videoId);
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                                cancelButton: CupertinoActionSheetAction(
                                                                                  child: Text("Cancel".tr),
                                                                                  onPressed: () {
                                                                                    Get.back();
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            Icons.more_vert,
                                                                            size: 18,
                                                                            color: Get.theme.primaryColor,
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
                                                    }),
                                              ).paddingSymmetric(horizontal: 2),
                                              userController.videosLoader.value
                                                  ? Container(
                                                      width: Get.width,
                                                      height: Get.width * 0.4,
                                                      child: Center(
                                                        child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    )
                                            ],
                                          )
                                        : !userController.videosLoader.value
                                            ? Container(
                                                height: Get.width * 0.4,
                                                child: "No video yet!".text.textStyle(Get.theme.textTheme.bodySmall).center.wide.make().centered(),
                                              )
                                            : Container(
                                                width: Get.width,
                                                height: Get.width * 0.4,
                                                child: Center(
                                                  child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                ),
                                              )
                                    : authService.currentUser.value.userFavoriteVideos.isNotEmpty
                                        ? Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: GridView.builder(
                                                    padding: EdgeInsets.all(0),
                                                    shrinkWrap: true,
                                                    primary: false,
                                                    physics: BouncingScrollPhysics(),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                      height: 150,
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 2,
                                                      mainAxisSpacing: 2,
                                                    ),
                                                    itemCount: authService.currentUser.value.userFavoriteVideos.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      final item = authService.currentUser.value.userFavoriteVideos.elementAt(index);
                                                      return InkWell(
                                                        onTap: () async {
                                                          dashboardService.postIds = [];
                                                          mainService.userVideoObj.value.searchType = 'L';
                                                          mainService.userVideoObj.value.userId = 0;
                                                          mainService.userVideoObj.value.videoId = item.videoId;
                                                          dashboardService.showFollowingPage.value = false;
                                                          dashboardService.showFollowingPage.refresh();
                                                          dashboardService.currentPage.value = 0;
                                                          dashboardController.getVideos();
                                                          dashboardService.pageController.value
                                                              .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                          dashboardService.pageController.refresh();
                                                          dashboardService.currentPage.refresh();
                                                          mainService.userVideoObj.refresh();
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(0.1),
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Get.theme.shadowColor,
                                                                blurRadius: 3.0, // soften the shadow
                                                                spreadRadius: 0.0, //extend the shadow
                                                                offset: Offset(
                                                                  0.0, // Move to right 10  horizontally
                                                                  0.0, // Move to bottom 5 Vertically
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: Get.width * 0.40,
                                                                child: item.videoGif != ""
                                                                    ? CachedNetworkImage(
                                                                        height: 150,
                                                                        memCacheWidth: 150,
                                                                        width: Get.width * 0.40,
                                                                        imageUrl: item.videoGif,
                                                                        placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                        errorWidget: (context, url, error) => CachedNetworkImage(
                                                                          height: 150,
                                                                          memCacheWidth: 150,
                                                                          width: Get.width * 0.40,
                                                                          imageUrl: item.videoThumbnail,
                                                                          placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                        fit: BoxFit.cover,
                                                                      )
                                                                    : item.videoThumbnail != ""
                                                                        ? CachedNetworkImage(
                                                                            height: 150,
                                                                            memCacheWidth: 250,
                                                                            width: Get.width * 0.40,
                                                                            imageUrl: item.videoThumbnail,
                                                                            placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                            fit: BoxFit.cover,
                                                                          )
                                                                        : Image.asset(
                                                                            'assets/images/noVideo.jpg',
                                                                            height: 150,
                                                                            width: Get.width * 0.40,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                              ),
                                                              Container(
                                                                width: Get.width * 0.40,
                                                                height: 150,
                                                                color: Colors.black12,
                                                              ),
                                                              Positioned(
                                                                bottom: 10,
                                                                child: Container(
                                                                  width: Get.width * 0.3,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              'assets/icons/liked.svg',
                                                                              width: 15.0,
                                                                              colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            "${item.totalLikes}".text.color(Get.theme.primaryColor).size(13).make(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              'assets/icons/views.svg',
                                                                              width: 15.0,
                                                                              colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            "${CommonHelper.formatter(item.totalViews.toString())}".text.color(Get.theme.primaryColor).size(13).make(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      /*Expanded(
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            showCupertinoModalPopup(
                                                                              context: context,
                                                                              builder: (BuildContext context) => CupertinoActionSheet(
                                                                                actions: [
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Edit"),
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => EditVideo(video: item),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Delete"),
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                      userController.showDeleteAlert("Delete Confirmation".tr, "Do you realy want to delete the video".tr, item.videoId);
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                                cancelButton: CupertinoActionSheetAction(
                                                                                  child: Text("Cancel".tr),
                                                                                  onPressed: () {
                                                                                    Get.back();
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            Icons.more_vert,
                                                                            size: 18,
                                                                            color: Get.theme.primaryColor,
                                                                          ),
                                                                        ),
                                                                      ),*/
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ).paddingSymmetric(horizontal: 2),
                                              userController.videosLoader.value
                                                  ? Container(
                                                      width: Get.width,
                                                      height: Get.width * 0.4,
                                                      child: Center(
                                                        child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    )
                                            ],
                                          )
                                        : !userController.videosLoader.value
                                            ? Container(
                                                height: Get.width * 0.4,
                                                child: "No video yet!".text.textStyle(Get.theme.textTheme.bodySmall).center.wide.make().centered(),
                                              )
                                            : Container(
                                                width: Get.width,
                                                height: Get.width * 0.4,
                                                child: Center(
                                                  child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                ),
                                              );
                              })
                            ],
                          ),
                        ),
                      )
                    : Container();
              }),
            ),
          ),
          drawer: Container(
            width: Get.mediaQuery.size.width * 0.8,
            child: Drawer(
              child: Stack(
                children: [
                  Container(
                    color: Get.theme.primaryColor,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                          // height: 130,
                          child: DrawerHeader(
                            child: Row(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Get.theme.primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Get.theme.iconTheme.color!.withOpacity(0.3),
                                        blurRadius: 3.0, // soften the shadow
                                        spreadRadius: 1.0, //extend the shadow
                                        offset: Offset(
                                          1.0, // Move to right 10  horizontally
                                          1.0, // Move to bottom 5 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: authService.currentUser.value.userDP != ""
                                        ? CachedNetworkImage(
                                            imageUrl: (authService.currentUser.value.userDP.toLowerCase().contains(".jpg") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains(".jpeg") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains(".png") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains(".gif") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains(".bmp") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains("fbsbx.com") ||
                                                    authService.currentUser.value.userDP.toLowerCase().contains("googleusercontent.com"))
                                                ? authService.currentUser.value.userDP
                                                : '${baseUrl}default/user-dummy-pic.png',
                                            placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                            fit: BoxFit.fill,
                                            width: 60,
                                            height: 60,
                                          )
                                        : Image.asset(
                                            'assets/images/default-user.png',
                                            fit: BoxFit.fill,
                                            width: 60,
                                            height: 60,
                                          ),
                                  ),
                                ).objectCenterLeft().pOnly(right: 20),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      "${authService.currentUser.value.name}".text.color(Get.theme.highlightColor).ellipsis.bold.size(18).make(),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      "(${authService.currentUser.value.username})".text.color(Get.theme.indicatorColor).ellipsis.size(14).make(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              // color: Color(0XFF15161a).withOpacity(0.1),
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Get.theme.dividerColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                            margin: EdgeInsets.all(0.0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                          ),
                        ),
                        ListTile(
                          // contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.person,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: 'Edit Profile'.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () async {
                            await userProfileController.fetchLoggedInUserInformation();

                            Get.toNamed('/edit-profile');
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.verified_user,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: 'Verification'.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.toNamed("/verify-profile");
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.block,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: 'Blocked User'.tr.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.toNamed('/blocked-users');
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.lock,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: 'Change Password'.tr.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.toNamed('/change-password');
                          },
                        ),
                        /*ListTile(
                              leading: Icon(
                                Icons.delete_forever,
                                color: Get.theme.iconTheme.color,
                                textDirection: TextDirection.rtl,
                                size: 25,
                              ),
                              title: 'Delete Profile Instruction'.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                              onTap: () {
                                String url = GlobalConfiguration().get('base_url') + "data-delete";
                                userController.launchURL(url);
                              },
                            ),*/
                        ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: Get.theme.iconTheme.color,
                            textDirection: ui.TextDirection.rtl,
                            size: 25,
                          ),
                          title: 'Notifications'.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.toNamed('/notification-settings');
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.chat,
                            color: Get.theme.iconTheme.color,
                            textDirection: ui.TextDirection.rtl,
                            size: 25,
                          ),
                          title: 'Chat Setting'.tr.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.toNamed("/chat-settings");
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.delete_forever,
                            color: Get.theme.iconTheme.color,
                            textDirection: ui.TextDirection.rtl,
                            size: 25,
                          ),
                          title: 'Delete Profile'.tr.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Get.back();
                            userController.deleteProfileConfirmation().whenComplete(() async {
                              dashboardService.showFollowingPage.value = false;
                              dashboardService.showFollowingPage.refresh();
                              dashboardController.getVideos();
                              Get.offNamed('/home');
                            });
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: Get.theme.iconTheme.color,
                            textDirection: ui.TextDirection.rtl,
                            size: 25,
                          ),
                          title: 'Logout'.text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () async {
                            Get.back();
                            await userController.logout();
                            dashboardService.showFollowingPage.value = false;
                            dashboardService.showFollowingPage.refresh();
                            dashboardService.currentPage.value = 0;
                            dashboardService.currentPage.refresh();
                            dashboardController.getVideos();

                            dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                            dashboardService.pageController.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                  /*Positioned(
                    bottom: 0,
                    left: 10,
                    child: Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${'App Version'.tr}:  ${authService.currentUser.value.appVersion}",
                            style: TextStyle(
                              color: Get.theme.indicatorColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
