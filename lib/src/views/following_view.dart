import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class FollowingView extends StatefulWidget {
  FollowingView({Key? key}) : super(key: key);

  @override
  _FollowingViewState createState() => _FollowingViewState();
}

class _FollowingViewState extends State<FollowingView> {
  FollowingController followingController = Get.find();
  FollowingService followingService = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  UserService userService = Get.find();
  int page = 1;
  @override
  void initState() {
    followingService.usersData = FollowingModel().obs;
    followingService.usersData.refresh();
    if (userService.followListType.value == 0) {
      followingController.curIndex = 0;
      followingController.followingUsers(userService.followListUserId, page);
    } else {
      followingController.curIndex = 1;
      followingController.getFollowers(userService.followListUserId, page);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Get.theme.primaryColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          size: 16,
          color: Get.theme.indicatorColor, //change your color here
        ),
        backgroundColor: Get.theme.primaryColor,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Get.theme.iconTheme.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SingleChildScrollView(
          child: DefaultTabController(
            initialIndex: followingController.curIndex,
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  color: Get.theme.primaryColor,
                  child: TabBar(
                    onTap: (index) async {
                      setState(() {
                        followingController.searchKeyword = '';
                        followingController.curIndex = index;
                        print("Indexxxx $index");
                      });
                      if (index == 0) {
                        await followingController.followingUsers(userService.followListUserId, 1);
                      } else {
                        await followingController.getFollowers(userService.followListUserId, 1);
                      }
                    },
                    unselectedLabelColor: Get.theme.shadowColor,
                    labelColor: Get.theme.indicatorColor,
                    indicatorColor: Get.theme.indicatorColor,
                    indicatorWeight: 1,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Following",
                            style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            child: Text(
                              "Followers",
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: Get.height - 125,
                  child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
                    Container(
                        child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: Get.width * 0.95,
                            child: TextField(
                              controller: followingController.searchController,
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontSize: 16.0,
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.text,
                              onChanged: (String val) {
                                print("val $val");
                                setState(() {
                                  followingController.searchKeyword = val;
                                  if (val == "") {
                                    print("asdasdasdasd");
                                    followingController.followingUsers(userService.followListUserId, 1);
                                  }
                                });
                              },
                              decoration: new InputDecoration(
                                fillColor: Get.theme.shadowColor.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                hintText: "Search",
                                hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor.withOpacity(0.6)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 10,
                                    height: 10,
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(Get.theme.indicatorColor.withOpacity(0.6), BlendMode.srcIn),
                                  ),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.only(bottom: 0, right: 0),
                                  onPressed: () {
                                    followingController.followingUsers(userService.followListUserId, 1);
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Get.theme.iconTheme.color,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: Get.width,
                              height: Get.height - 190,
                              child: Obx(() {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  controller: followingController.scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: followingService.usersData.value.users.length,
                                  itemBuilder: (context, i) {
                                    print(followingService.usersData.value.users[0].toString());
                                    var fullName = followingService.usersData.value.users[i].firstName + " " + followingService.usersData.value.users[i].lastName;
                                    return Container(
                                      decoration: new BoxDecoration(
                                        border: new Border(bottom: new BorderSide(width: 0.2, color: Get.theme.indicatorColor)),
                                      ),
                                      child: ListTile(
                                        leading: InkWell(
                                          onTap: () {
                                            if (followingService.usersData.value.users[i].id == authService.currentUser.value.id) {
                                              DashboardService dashboardService = Get.find();
                                              dashboardService.currentPage.value = 4;
                                              dashboardService.currentPage.refresh();
                                              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                              dashboardService.pageController.refresh();
                                            } else {
                                              UserController userController = Get.find();
                                              userController.openUserProfile(followingService.usersData.value.users[i].id);
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: mainService.setting.value.dpBorderColor!,
                                              ),
                                              borderRadius: BorderRadius.circular(50.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100.0),
                                              child: (followingService.usersData.value.users[i].dp != '')
                                                  ? CachedNetworkImage(
                                                      imageUrl: followingService.usersData.value.users[i].dp,
                                                      placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.indicatorColor),
                                                      fit: BoxFit.fill,
                                                      width: 50,
                                                      height: 50,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/default-user.png',
                                                      fit: BoxFit.fill,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        title: GestureDetector(
                                          onTap: () {
                                            if (followingService.usersData.value.users[i].id == authService.currentUser.value.id) {
                                              DashboardService dashboardService = Get.find();
                                              dashboardService.currentPage.value = 4;
                                              dashboardService.currentPage.refresh();
                                              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                              dashboardService.pageController.refresh();
                                            } else {
                                              UserController userController = Get.find();
                                              userController.openUserProfile(followingService.usersData.value.users[i].id);
                                            }
                                          },
                                          child: Text(
                                            followingService.usersData.value.users[i].id == authService.currentUser.value.id ? "You" : followingService.usersData.value.users[i].username,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Get.theme.indicatorColor, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        subtitle: Text(
                                          fullName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.8)),
                                        ),
                                        trailing: followingService.usersData.value.users[i].id == authService.currentUser.value.id
                                            ? null
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      followingController.followUnfollowUser(followingService.usersData.value.users[i].id, i);
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      height: 28,
                                                      decoration: (followingService.usersData.value.users[i].followText == 'Unfollow')
                                                          ? BoxDecoration(
                                                              color: Get.theme.highlightColor,
                                                              border: Border.all(color: Get.theme.highlightColor),
                                                              borderRadius: BorderRadius.circular(100),
                                                            )
                                                          : BoxDecoration(
                                                              color: Get.theme.highlightColor,
                                                              border: Border.all(color: Get.theme.highlightColor),
                                                              borderRadius: BorderRadius.all(
                                                                new Radius.circular(100),
                                                              ),
                                                            ),
                                                      child: Center(
                                                          child: "${followingService.usersData.value.users[i].followText}"
                                                              .text
                                                              .wide
                                                              .color((followingService.usersData.value.users[i].followText == 'Unfollow')
                                                                  ? mainService.setting.value.inactiveButtonTextColor!
                                                                  : mainService.setting.value.buttonTextColor!)
                                                              .size(14)
                                                              .make()),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: userService.followListUserId == authService.currentUser.value.id && followingController.curIndex == 1 ? 10 : 0,
                                                  ),
                                                  userService.followListUserId == authService.currentUser.value.id && followingController.curIndex == 1
                                                      ? InkWell(
                                                          onTap: () {
                                                            followingController.removeFollower(followingService.usersData.value.users[i].id, i);
                                                          },
                                                          child: SvgPicture.asset(
                                                            'assets/icons/delete.svg',
                                                            width: 20,
                                                            height: 20,
                                                            colorFilter: ColorFilter.mode(Get.theme.indicatorColor, BlendMode.srcIn),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0,
                                                        )
                                                ],
                                              ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    )),
                    Container(
                        child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: Get.width * 0.95,
                            child: TextField(
                              controller: followingController.searchController,
                              style: TextStyle(
                                color: Get.theme.indicatorColor.withOpacity(0.6),
                                fontSize: 16.0,
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.text,
                              onChanged: (String val) {
                                print("val $val");
                                setState(() {
                                  followingController.searchKeyword = val;
                                  if (val == "") {
                                    print("asdasdasdasd");
                                    followingController.followingUsers(userService.followListUserId, 1);
                                  }
                                });
                              },
                              decoration: new InputDecoration(
                                fillColor: Get.theme.shadowColor.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: mainService.setting.value.buttonColor!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: mainService.setting.value.buttonColor!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  color: Get.theme.indicatorColor.withOpacity(0.5),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 10,
                                    height: 10,
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(Get.theme.indicatorColor, BlendMode.srcIn),
                                  ),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.only(bottom: 0, right: 0),
                                  onPressed: () {
                                    followingController.followingUsers(userService.followListUserId, 1);
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Get.theme.iconTheme.color,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: Get.width,
                              height: Get.height - 190,
                              child: Obx(() {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  controller: followingController.scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: followingService.usersData.value.users.length,
                                  itemBuilder: (context, i) {
                                    print(followingService.usersData.value.users[0].toString());
                                    var fullName = followingService.usersData.value.users[i].firstName + " " + followingService.usersData.value.users[i].lastName;
                                    return Container(
                                      decoration: new BoxDecoration(
                                        border: new Border(bottom: new BorderSide(width: 0.2, color: Get.theme.indicatorColor)),
                                      ),
                                      child: ListTile(
                                        leading: GestureDetector(
                                          onTap: () {
                                            if (followingService.usersData.value.users[i].id == authService.currentUser.value.id) {
                                              DashboardService dashboardService = Get.find();
                                              dashboardService.currentPage.value = 4;
                                              dashboardService.currentPage.refresh();
                                              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                              dashboardService.pageController.refresh();
                                            } else {
                                              UserController userCon = Get.find();
                                              userCon.openUserProfile(followingService.usersData.value.users[i].id);
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: mainService.setting.value.dpBorderColor!,
                                              ),
                                              borderRadius: BorderRadius.circular(50.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100.0),
                                              child: (followingService.usersData.value.users[i].dp != '')
                                                  ? CachedNetworkImage(
                                                      imageUrl: followingService.usersData.value.users[i].dp,
                                                      placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.indicatorColor),
                                                      fit: BoxFit.fill,
                                                      width: 50,
                                                      height: 50,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/default-user.png',
                                                      fit: BoxFit.fill,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        title: GestureDetector(
                                          onTap: () {
                                            if (followingService.usersData.value.users[i].id == authService.currentUser.value.id) {
                                              DashboardService dashboardService = Get.find();
                                              dashboardService.currentPage.value = 4;
                                              dashboardService.currentPage.refresh();
                                              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                              dashboardService.pageController.refresh();
                                            } else {
                                              UserController userCon = Get.find();
                                              userCon.openUserProfile(followingService.usersData.value.users[i].id);
                                            }
                                          },
                                          child: Text(
                                            followingService.usersData.value.users[i].id == authService.currentUser.value.id ? "You" : followingService.usersData.value.users[i].username,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Get.theme.indicatorColor, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        subtitle: Text(
                                          fullName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.8)),
                                        ),
                                        trailing: followingService.usersData.value.users[i].id == authService.currentUser.value.id
                                            ? null
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      followingController.followUnfollowUser(followingService.usersData.value.users[i].id, i);
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      height: 28,
                                                      decoration: (followingService.usersData.value.users[i].followText == 'Unfollow')
                                                          ? BoxDecoration(
                                                              color: Get.theme.highlightColor,
                                                              border: Border.all(color: Get.theme.highlightColor),
                                                              borderRadius: BorderRadius.circular(100),
                                                            )
                                                          : BoxDecoration(
                                                              color: Get.theme.highlightColor,
                                                              border: Border.all(color: Get.theme.highlightColor),
                                                              borderRadius: BorderRadius.all(
                                                                new Radius.circular(100),
                                                              ),
                                                            ),
                                                      child: Center(
                                                          child: "${followingService.usersData.value.users[i].followText}"
                                                              .text
                                                              .wide
                                                              .color((followingService.usersData.value.users[i].followText == 'Unfollow')
                                                                  ? mainService.setting.value.inactiveButtonTextColor!
                                                                  : mainService.setting.value.buttonTextColor!)
                                                              .size(14)
                                                              .make()),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: userService.followListUserId == authService.currentUser.value.id && followingController.curIndex == 1 ? 10 : 0,
                                                  ),
                                                  userService.followListUserId == authService.currentUser.value.id && followingController.curIndex == 1
                                                      ? InkWell(
                                                          onTap: () {
                                                            followingController.removeFollower(followingService.usersData.value.users[i].id, i);
                                                          },
                                                          child: SvgPicture.asset(
                                                            'assets/icons/delete.svg',
                                                            width: 20,
                                                            height: 20,
                                                            colorFilter: ColorFilter.mode(Get.theme.indicatorColor, BlendMode.srcIn),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0,
                                                        )
                                                ],
                                              ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    )),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // });
  }
}
