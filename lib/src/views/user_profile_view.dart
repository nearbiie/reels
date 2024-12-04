import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class UsersProfileView extends StatelessWidget {
  UsersProfileView({Key? key}) : super(key: key);
  final UserController userController = Get.find();
  final MainService mainService = Get.find();
  final UserService userService = Get.find();
  final DashboardService dashboardService = Get.find();
  final DashboardController dashboardController = Get.find();
  final AuthService authService = Get.find();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.primaryColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Get.theme.primaryColor,
            leading: InkWell(
              onTap: () {
                dashboardService.showFollowingPage.value = false;
                dashboardService.showFollowingPage.refresh();
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
                color: Get.theme.iconTheme.color,
              ),
            ),
            actions: [
              authService.currentUser.value.accessToken != ''
                  ? PopupMenuButton<int>(
                      color: Get.theme.shadowColor,
                      icon: SvgPicture.asset(
                        'assets/icons/setting.svg',
                        width: 25.0,
                        colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                      ),
                      onSelected: (int) {
                        userController.blockUser(report: int == 0 ? false : true);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          height: 20,
                          value: 1,
                          child: Text(
                            userService.userProfile.value.blocked == 'yes' ? 'Unblock' : 'Block',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontFamily: 'RockWellStd',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          height: 20,
                          value: 1,
                          child: Text(
                            userService.userProfile.value.blocked == 'yes' ? 'Unblock' : 'Report & Block',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontFamily: 'RockWellStd',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
          body: WillPopScope(
            onWillPop: () async {
              // dashboardController.getVideos();

              return Future.value(true);
            },
            child: Obx(() {
              return SingleChildScrollView(
                controller: userController.scrollController1,
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
                                        color: Get.theme.primaryColor, //change your color here
                                      ),
                                      // backgroundColor: Color(0xff15161a),
                                      backgroundColor: Get.theme.primaryColor,
                                      title: "Profile Picture".text.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
                                      centerTitle: true,
                                    ),
                                  ),
                                  body: Center(
                                    child: PhotoView(
                                      enableRotation: true,
                                      imageProvider: CachedNetworkImageProvider((userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains(".png") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                              userService.userProfile.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                          ? userService.userProfile.value.largeProfilePic
                                          : '$baseUrl' + "default/user-dummy-pic.png"),
                                    ),
                                  ));
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: Get.width * 0.30,
                        width: Get.width * 0.30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          //color: Get.theme.indicatorColor,
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
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: userService.userProfile.value.smallProfilePic != ""
                              ? CachedNetworkImage(
                                  imageUrl: (userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains(".png") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                          userService.userProfile.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                      ? userService.userProfile.value.smallProfilePic
                                      : '$baseUrl' + "default/user-dummy-pic.png",
                                  placeholder: (context, url) => CommonHelper.showLoaderSpinner(Colors.white),
                                  fit: BoxFit.fill,
                                  width: 50,
                                  height: 50,
                                  errorWidget: (a, b, c) {
                                    return Image.asset(
                                      "assets/images/default-user.png",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset('assets/images/default-user.png'),
                        ).pLTRB(4, 4, 4, 4),
                      ),
                    ).centered().pOnly(bottom: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        userService.userProfile.value.username.text.textStyle(Get.theme.textTheme.bodyLarge).make(),
                        userService.userProfile.value.isVerified == true
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              userController.followUnfollowUserFromUserProfile(userService.userProfile.value.id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: userService.userProfile.value.followText != "Follow" ? Colors.grey[400] : Colors.red,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: (userService.userProfile.value.followText != "Follow" ? Colors.grey[400] : Colors.transparent)!,
                                ),
                              ),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 14.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    userService.userProfile.value.followText != "Follow" ? Icons.check : Icons.add,
                                    color: userService.userProfile.value.followText != "Follow" ? Colors.black : Colors.white,
                                  ),
                                  SizedBox(width: 2.0),
                                  Text(
                                    userService.userProfile.value.followText,
                                    style: TextStyle(
                                      color: userService.userProfile.value.followText != "Follow" ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            "${userService.userProfile.value.totalVideos}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                            "Posts".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                          ],
                        ),
                        Column(
                          children: [
                            "${userService.userProfile.value.totalVideosLike}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                            "Likes".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (userService.userProfile.value.totalFollowings != '0') {
                              userService.followListUserId = userService.userProfile.value.id;
                              userService.followListType.value = 0;
                              Get.toNamed("/followers", preventDuplicates: false);
                            }
                          },
                          child: Column(
                            children: [
                              "${userService.userProfile.value.totalFollowings}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                              "Following".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (userService.userProfile.value.totalFollowers != '0') {
                              userService.followListUserId = userService.userProfile.value.id;
                              userService.followListType.value = 1;
                              Get.toNamed("/followers", preventDuplicates: false);
                            }
                          },
                          child: Column(
                            children: [
                              "${userService.userProfile.value.totalFollowers}".text.textStyle(Get.theme.textTheme.bodyLarge).make().pOnly(bottom: 1),
                              "Followers".tr.text.textStyle(Get.theme.textTheme.bodyMedium).make(),
                            ],
                          ),
                        )
                      ],
                    ).pSymmetric(h: 20, v: 10),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/videos.svg',
                          width: 20.0,
                          colorFilter: ColorFilter.mode(Get.theme.indicatorColor, BlendMode.srcIn),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        "Videos".text.color(Get.theme.indicatorColor).size(16).make(),
                      ],
                    ).centered(),
                    SizedBox(
                      height: 20,
                    ),
                    Obx(
                      () => (userService.userProfile.value.userVideos.length > 0)
                          ? Container(
                              child: GridView.builder(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: BouncingScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                    height: 150,
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: userService.userProfile.value.userVideos.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final item = userService.userProfile.value.userVideos.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        mainService.userVideoObj.value.userId = item.userId;
                                        mainService.userVideoObj.value.videoId = item.videoId;
                                        mainService.userVideoObj.value.name = userService.userProfile.value.name.split(" ").first + "'s";
                                        dashboardService.showFollowingPage.value = false;
                                        dashboardService.showFollowingPage.refresh();
                                        dashboardService.postIds = [];
                                        dashboardController.getVideos().whenComplete(() {
                                          Get.back();
                                        });
                                      },
                                      child: Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: Get.width * 0.3,
                                              child: item.videoThumbnail != ""
                                                  ? CachedNetworkImage(
                                                      imageUrl: item.videoThumbnail,
                                                      placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/noVideo.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Container(
                                              width: Get.width * 0.3,
                                              height: 150,
                                              color: Colors.black12,
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              child: Container(
                                                width: Get.width * 0.3,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ).pSymmetric(h: 10)
                          : Container(
                              height: Get.height * (0.40),
                              child: "No video yet!".text.textStyle(Get.theme.textTheme.bodySmall).center.wide.make().centered(),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        Positioned(
          // bottom: Platform.isAndroid ? 0 : 15,
          bottom: 0,
          child: Obx(
            () {
              return userController.showBannerAd.value ? Center(child: Container(width: Get.width, child: BannerAdWidget())) : Container();
            },
          ),
        ),
      ],
    );
  }
}
