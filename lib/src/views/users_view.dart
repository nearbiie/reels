import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class UsersView extends StatefulWidget {
  UsersView({Key? key}) : super(key: key);

  @override
  _UsersViewState createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  UserController userController = Get.find();
  DashboardService dashboardService = Get.find();
  AuthService authService = Get.find();
  UserService userService = Get.find();
  MainService mainService = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  void initState() {
    userController.getUsers(1);
    super.initState();
  }

  Widget build(BuildContext context) {
    final double itemHeight = (Get.height - kToolbarHeight - 24) / 2;
    final double itemWidth = Get.width / 2;
    return Obx(() {
      return Scaffold(
        key: userController.userScaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.theme.primaryColor,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            height: Get.height,
            width: Get.width,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child: Container(
                    height: 24,
                    width: Get.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Get.theme.iconTheme.color,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            width: Get.width - 50,
                            child: TextField(
                              controller: userController.searchController,
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontSize: 16.0,
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.text,
                              onChanged: (String val) {
                                setState(() {
                                  userController.searchKeyword = val;
                                });
                                if (val.length > 2) {
                                  Timer(Duration(seconds: 1), () {
                                    userController.getUsers(1);
                                  });
                                }
                              },
                              decoration: new InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Get.theme.highlightColor, width: 0.3),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Get.theme.highlightColor, width: 0.3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Get.theme.highlightColor, width: 0.3),
                                ),
                                hintText: "Search",
                                hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor.withOpacity(0.5)),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.only(bottom: 12),
                                  onPressed: () {
                                    userController.searchController.clear();
                                    setState(() {
                                      userController.searchKeyword = "";
                                    });
                                    userController.getUsers(1);
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: (userController.searchKeyword.length > 0) ? Get.theme.iconTheme.color : Colors.transparent,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 13, bottom: 2, left: 15),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          color: Get.theme.indicatorColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                (userService.usersData.value.videos.length > 0)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: Get.width,
                          height: Get.height - 139,
                          margin: EdgeInsets.only(bottom: 30),
                          child: GridView.builder(
                            controller: userController.scrollController1,
                            primary: false,
                            padding: const EdgeInsets.all(2),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: (itemWidth / itemHeight),
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              crossAxisCount: 3,
                            ),
                            itemCount: userService.usersData.value.videos.length,
                            itemBuilder: (BuildContext context, int i) {
                              final item = userService.usersData.value.videos.elementAt(i);
                              print("item.videoThumbnail");
                              print(item.videoThumbnail);
                              return Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: Get.height,
                                    width: Get.width,
                                    child: item.videoThumbnail != ""
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              /*boxShadow: [
                                                BoxShadow(
                                                  color: .gridItemBorderColor!,
                                                  blurRadius: 3.0, // soften the shadow
                                                  spreadRadius: 0.0, //extend the shadow
                                                  offset: Offset(
                                                    0.0, // Move to right 10  horizontally
                                                    0.0, // Move to bottom 5 Vertically
                                                  ),
                                                )
                                              ],*/
                                            ),
                                            padding: const EdgeInsets.all(1),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(5.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: item.videoThumbnail,
                                                  placeholder: (context, url) => Center(
                                                    child: CommonHelper.showLoaderSpinner(Colors.white),
                                                  ),
                                                  fit: BoxFit.cover,
                                                )),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(5.0),
                                            child: Image.asset(
                                              'assets/images/noVideo.jpg',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 55,
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                        border: new Border.all(
                                          color: Get.theme.shadowColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Container(
                                        width: 35.0,
                                        height: 35.0,
                                        decoration: new BoxDecoration(
                                          image: new DecorationImage(
                                              image: (item.userDP != "")
                                                  ? CachedNetworkImageProvider(
                                                      item.userDP,
                                                    )
                                                  : AssetImage(
                                                      'assets/images/default-user.png',
                                                    ) as ImageProvider,
                                              fit: BoxFit.contain),
                                          borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 37,
                                      child: Row(
                                        children: [
                                          Text(
                                            item.username,
                                            style: TextStyle(
                                              color: Get.theme.primaryColor,
                                              fontSize: 11,
                                              fontFamily: 'RockWellStd',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          item.isVerified == true
                                              ? Icon(
                                                  Icons.verified,
                                                  color: Get.theme.highlightColor,
                                                  size: 16,
                                                )
                                              : Container(),
                                        ],
                                      )),
                                  Positioned(
                                    bottom: -5,
                                    child: ButtonTheme(
                                      minWidth: 80,
                                      height: 25,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            padding: EdgeInsets.all(0),
                                            // shape: RoundedRectangleBorder(
                                            //   borderRadius: BorderRadius.circular(100.0),
                                            // ),
                                            shadowColor: Colors.transparent),
                                        child: Obx(
                                          () => Container(
                                            height: 25,
                                            width: 80,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: Get.theme.highlightColor),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  (userController.followUserId.value != item.userId)
                                                      ? Text(
                                                          item.followText,
                                                          style: TextStyle(
                                                            color: Get.theme.indicatorColor,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                            fontFamily: 'RockWellStd',
                                                          ),
                                                        )
                                                      : CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          userController.followUnfollowUser(item.userId, i);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    : (!userController.showUserLoader)
                        ? Center(
                            child: Container(
                              height: Get.height - 360,
                              width: Get.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        width: 2,
                                        color: Get.theme.dividerColor,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Get.theme.iconTheme.color,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    "No User Yet",
                                    style: TextStyle(
                                      color: Get.theme.indicatorColor,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        )),
      );
    });
  }
}
