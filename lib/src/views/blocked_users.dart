import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:get/get.dart";

import '../core.dart';

class BlockedUsers extends StatefulWidget {
  final int type;
  final int userId;
  BlockedUsers({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  UserProfileController userProfileController = Get.find();
  AuthService authService = Get.find();
  UserService userService = Get.find();
  MainService mainService = Get.find();

  int page = 1;

  @override
  void initState() {
    userService.blockedUsersData = BlockedModel().obs;
    userService.blockedUsersData.refresh();
    userProfileController.getBlockedUsers(page);
    super.initState();
  }

  Widget layout(_user) {
    return Obx(() => (_user != null)
        ? (_user.users.length > 0)
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: Get.width,
                    height: Get.height - 185,
                    child: ListView.builder(
                      controller: userProfileController.scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: _user.users.length,
                      itemBuilder: (context, i) {
                        print(_user.users[0].toString());
                        var fullName = _user.users[i].firstName + " " + _user.users[i].lastName;
                        return Container(
                          decoration: new BoxDecoration(
                            border: new Border(bottom: new BorderSide(width: 0.2, color: mainService.setting.value.dividerColor!)),
                          ),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mainService.setting.value.dpBorderColor!,
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: (_user.users[i].dp != '')
                                    ? CachedNetworkImage(
                                        imageUrl: _user.users[i].dp,
                                        placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
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
                            title: Text(
                              _user.users[i].username,
                              style: TextStyle(color: Get.theme.indicatorColor, fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            subtitle: Text(
                              fullName,
                              style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.7), fontSize: 14),
                            ),
                            trailing: GestureDetector(
                                onTap: () {
                                  if (!userProfileController.blockUnblockLoader) {
                                    userProfileController.blockUnblockUser(_user.users[i].id);
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: mainService.setting.value.inactiveButtonColor,
                                    border: Border.all(color: mainService.setting.value.inactiveButtonColor!),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: (!userProfileController.blockUnblockLoader)
                                        ? Text(
                                            "Unblock",
                                            style: TextStyle(
                                              color: (_user.users[i].followText == 'Following') ? mainService.setting.value.inactiveButtonTextColor : mainService.setting.value.buttonTextColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                  ),
                                )),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : !userProfileController.showLoader.value
                ? Center(
                    child: Container(
                      height: Get.height - 185,
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            size: 30,
                            color: Get.theme.iconTheme.color!.withOpacity(0.5),
                          ),
                          Text(
                            "No Blocked Users",
                            style: TextStyle(
                              color: Get.theme.indicatorColor.withOpacity(0.5),
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container()
        : (!userProfileController.showLoader.value)
            ? Center(
                child: Container(
                  height: Get.height - 185,
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 30,
                        color: Get.theme.iconTheme.color!.withOpacity(0.5),
                      ),
                      Text(
                        "No User Yet",
                        style: TextStyle(color: Get.theme.indicatorColor.withOpacity(0.5), fontSize: 15),
                      )
                    ],
                  ),
                ),
              )
            : Container());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Obx(
      () => Scaffold(
        backgroundColor: Get.theme.primaryColor,
        key: userProfileController.blockedUserScaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: true,
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
          title: "Blocked Users".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: Get.theme.primaryColor,
              child: Column(
                children: <Widget>[
                  layout(userService.blockedUsersData.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
