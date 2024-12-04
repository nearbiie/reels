import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class FriendsListView extends StatefulWidget {
  FriendsListView({Key? key}) : super(key: key);

  @override
  _FriendsListViewState createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  FollowingController followingController = Get.find();
  MainService mainService = Get.find();
  FollowingService followingService = Get.find();
  int page = 1;

  @override
  void initState() {
    followingController.friendsList(page);
    super.initState();
  }

  Widget layout(obj) {
    return Obx(() {
      if (obj != null) {
        if (obj.users.length > 0) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: Get.width,
                  height: Get.height - 185,
                  child: ListView.builder(
                    controller: followingController.scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: obj.users.length,
                    itemBuilder: (context, i) {
                      print(obj.users[0].toString());
                      var fullName = obj.users[i].firstName + " " + obj.users[i].lastName;
                      return Container(
                        decoration: new BoxDecoration(
                          border: new Border(
                            bottom: new BorderSide(
                              width: 0.2,
                              color: Get.theme.indicatorColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              UserController userController = Get.find();
                              userController.openUserProfile(obj.users[i].id);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: (obj.users[i].dp != '')
                                  ? Image.network(
                                      obj.users[i].dp,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                        );
                                      },
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
                          title: GestureDetector(
                            onTap: () {
                              UserController userCon = Get.find();
                              userCon.openUserProfile(obj.users[i].id);
                            },
                            child: Text(
                              obj.users[i].username,
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            fullName,
                            style: TextStyle(
                              color: Get.theme.indicatorColor,
                            ),
                          ),
                          trailing: Container(
                            width: 85,
                            height: 26,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Get.theme.indicatorColor,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Text(
                                "Start Chat",
                                style: TextStyle(
                                  color: Get.theme.indicatorColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                      );
                    },
                  )),
            ),
          );
        } else {
          if (followingController.noRecord) {
            return Center(
              child: Container(
                height: Get.height - 185,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey,
                    ),
                    Text(
                      "No record found",
                      style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.5), fontSize: 15),
                    )
                  ],
                ),
              ),
            );
          } else if (!followingController.showLoader.value) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/users',
                  );
                },
                child: Container(
                  height: Get.height - 80,
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
                            color: Get.theme.iconTheme.color!,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Get.theme.iconTheme.color,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "This is your feed of user you follow.",
                        style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "You can follow people or subscribe to hashtags.",
                        style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Icon(
                        Icons.person_add,
                        color: Get.theme.iconTheme.color,
                        size: 45,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        }
      } else {
        if (!followingController.showLoader.value) {
          return Center(
            child: Container(
              height: Get.height - 185,
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No User Yet",
                    style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.6), fontSize: 15),
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: Get.theme.primaryColor,
              child: Column(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: Get.height,
                          child: Container(
                              child: Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  Flexible(
                                    flex: 0,
                                    child: IconButton(
                                      color: Get.theme.iconTheme.color,
                                      icon: new Icon(
                                        Icons.arrow_back,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 15),
                                      child: TextField(
                                        controller: followingController.searchController,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 16.0,
                                        ),
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        onChanged: (String val) {
                                          setState(() {
                                            followingController.searchKeyword = val;
                                          });
                                          Timer(Duration(seconds: 1), () {
                                            followingController.friendsList(1);
                                          });
                                        },
                                        decoration: new InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                          ),
                                          hintText: "Search",
                                          hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor.withOpacity(0.6)),
                                          contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                                          suffixIcon: IconButton(
                                            padding: EdgeInsets.only(bottom: 0, right: 0),
                                            onPressed: () {
                                              followingController.searchController.clear();
                                              setState(() {
                                                followingController.searchKeyword = '';
                                                followingController.friendsList(1);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.clear,
                                              color: (followingController.searchKeyword.length > 0) ? Get.theme.iconTheme.color : Get.theme.primaryColor,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              (followingService.friendsData.value.users.isNotEmpty) ? layout(followingService.friendsData.value) : Container()
                            ],
                          )),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
