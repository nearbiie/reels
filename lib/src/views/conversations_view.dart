import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class ConversationsView extends StatefulWidget {
  @override
  _ConversationsViewState createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  ChatController chatController = Get.find();
  MainService mainService = Get.find();
  ChatService chatService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();

  int active = 1;
  @override
  void initState() {
    super.initState();
    chatController.myConversations(1);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    print("onlineUserIds ${chatService.onlineUserIds}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        dashboardService.showFollowingPage.value = false;
        dashboardService.showFollowingPage.refresh();
        dashboardController.getVideos();
        dashboardService.currentPage.value = 0;
        dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
        dashboardService.currentPage.refresh();
        dashboardService.pageController.refresh();
        return Future.value(false);
      },
      child: Scaffold(
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
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              dashboardService.showFollowingPage.value = false;
              dashboardService.showFollowingPage.refresh();
              dashboardController.getVideos();
              dashboardService.currentPage.value = 0;
              dashboardService.currentPage.refresh();
              dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
              dashboardService.pageController.refresh();
            },
            child: Icon(
              Icons.arrow_back,
              color: Get.theme.iconTheme.color,
            ),
          ),
          centerTitle: true,
          title: "Conversations".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
        ),
        body: Obx(
          () => SafeArea(
              maintainBottomViewPadding: true,
              child: SingleChildScrollView(
                controller: chatController.scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Get.theme.shadowColor.withOpacity(0.4),
                      width: Get.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: Get.width * 0.02, top: 5, bottom: 5, right: Get.width * 0.02),
                            child: Container(
                              width: Get.width * 0.96,
                              height: 40,
                              child: TextField(
                                controller: chatController.searchController,
                                style: TextStyle(
                                  color: Get.theme.indicatorColor,
                                  fontSize: 16.0,
                                ),
                                obscureText: false,
                                keyboardType: TextInputType.text,
                                onChanged: (String val) {
                                  setState(() {
                                    chatController.searchKeyword = val;
                                  });
                                },
                                onSubmitted: (String val) {
                                  if (active == 1) {
                                    chatController.myConversations(1, showApiLoader: false);
                                  } else {
                                    chatController.getPeople(1);
                                  }
                                },
                                decoration: new InputDecoration(
                                  fillColor: Get.theme.primaryColor.withOpacity(0.4),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  hintText: "Search",
                                  hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: SvgPicture.asset(
                                      'assets/icons/search.svg',
                                      fit: BoxFit.contain,
                                      colorFilter: ColorFilter.mode(Get.theme.indicatorColor, BlendMode.srcIn),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.only(bottom: 0, right: 0),
                                    onPressed: () {
                                      setState(() {
                                        chatController.searchKeyword = "";
                                        chatController.searchController = TextEditingController();
                                      });
                                      if (active == 1) {
                                        chatController.myConversations(1, showApiLoader: false);
                                      } else {
                                        chatController.getPeople(1);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: (chatController.searchKeyword.length > 0) ? Get.theme.iconTheme.color : Colors.transparent,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            chatService.onlineUsers.toSet().toList();
                            return chatService.onlineUsers.length > 0
                                ? Container(
                                    height: 65,
                                    width: Get.width,
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    child: ListView.builder(
                                      itemCount: chatService.onlineUsers.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final onlineUserItem = chatService.onlineUsers.elementAt(index);
                                        return InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            chatService.conversationUser.value.convId = 0;
                                            chatService.conversationUser.value.id = onlineUserItem.id;
                                            chatService.conversationUser.value.name = onlineUserItem.firstName + " " + onlineUserItem.lastName;
                                            chatService.conversationUser.value.userDP = onlineUserItem.userDP;
                                            chatService.conversationUser.value.online = onlineUserItem.online;
                                            chatService.conversationUser.refresh();
                                            await chatController.fetchChat();
                                            Get.toNamed("/chat");
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Get.theme.highlightColor,
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(100),
                                                  child: onlineUserItem.userDP != ""
                                                      ? CachedNetworkImage(
                                                          imageUrl: onlineUserItem.userDP,
                                                          memCacheHeight: 40,
                                                          placeholder: (context, url) => Center(
                                                            child: CommonHelper.showLoaderSpinner(Colors.white),
                                                          ),
                                                          fit: BoxFit.cover,
                                                          width: 40,
                                                          height: 40,
                                                        )
                                                      : Image.asset(
                                                          "assets/images/default-user.png",
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ).p(3),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                width: 50,
                                                child: "${onlineUserItem.name}".text.bold.size(12).color(Get.theme.indicatorColor.withOpacity(0.5)).ellipsis.make().centered(),
                                              )
                                            ],
                                          ).pOnly(right: 15),
                                        );
                                      },
                                    ),
                                  ).pOnly(left: 10, top: 3)
                                : SizedBox(
                                    height: 0,
                                  );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                active = 1;
                                chatController.searchKeyword = '';
                                chatController.searchController = TextEditingController();
                              });
                              chatController.myConversations(1, showApiLoader: false);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: active == 1
                                    ? Border(
                                        bottom: BorderSide(
                                          color: Get.theme.highlightColor,
                                          width: 2.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: "Chat".text.uppercase.bold.size(16).color(active == 1 ? Get.theme.highlightColor : Get.theme.indicatorColor).make().pSymmetric(h: 15, v: 15),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                active = 2;
                                chatController.searchKeyword = '';
                                chatController.searchController = TextEditingController();
                              });
                              chatController.getPeople(1);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: active == 2
                                    ? Border(
                                        bottom: BorderSide(
                                          color: Get.theme.highlightColor,
                                          width: 2.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: "People".text.uppercase.bold.size(16).color(active == 2 ? Get.theme.highlightColor : Get.theme.indicatorColor).make().pSymmetric(h: 15, v: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !chatController.showLoader.value
                        ? active == 1
                            ? Container(
                                width: Get.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: chatService.conversations.value.data.length > 0
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: chatService.conversations.value.data.length,
                                        shrinkWrap: true,
                                        itemExtent: 60,
                                        scrollDirection: Axis.vertical,
                                        padding: EdgeInsets.only(bottom: 50),
                                        itemBuilder: (context, index) {
                                          final item = chatService.conversations.value.data.elementAt(index);
                                          return ListTile(
                                            splashColor: Colors.white,
                                            selectedColor: Colors.white,
                                            focusColor: Colors.white,
                                            tileColor: Get.theme.primaryColor,
                                            onTap: () async {
                                              print("item.toString() ${item.userId} ${item.id}");
                                              chatService.currentConversation.value.id = item.id;
                                              chatService.currentConversation.value.userId = item.userId;
                                              chatService.currentConversation.value.totalMessages = item.totalMessages;
                                              chatService.currentConversation.value.messages = item.messages;
                                              chatService.currentConversation.value.userDp = item.userDp;
                                              chatService.currentConversation.value.username = item.username;

                                              chatService.conversationUser.value.convId = item.id;
                                              chatService.conversationUser.value.id = item.userId;
                                              chatService.conversationUser.value.name = item.personName;
                                              chatService.conversationUser.value.userDP = item.userDp;
                                              chatService.conversationUser.value.online = item.online;
                                              chatService.conversationUser.refresh();
                                              await chatController.fetchChat();

                                              Get.toNamed("/chat");
                                            },
                                            leading: Stack(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Get.theme.highlightColor,
                                                    borderRadius: BorderRadius.circular(100),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: item.userDp != ""
                                                        ? CachedNetworkImage(
                                                            imageUrl: item.userDp,
                                                            memCacheHeight: 40,
                                                            placeholder: (context, url) => Center(
                                                              child: CommonHelper.showLoaderSpinner(Colors.white),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            "assets/images/default-user.png",
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ).p(2),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  right: 1,
                                                  child: item.online || chatService.onlineUserIds.contains(item.userId)
                                                      ? Container(
                                                          width: 13,
                                                          height: 13,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white, width: 2),
                                                            color: Colors.green,
                                                            borderRadius: BorderRadius.circular(100),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0,
                                                        ),
                                                ),
                                              ],
                                            ),
                                            title: "${item.personName}".text.size(16).color(Get.theme.indicatorColor).make(),
                                            subtitle: "${item.message}".text.size(13).ellipsis.maxLines(2).color(Get.theme.indicatorColor.withOpacity(0.7)).make(),
                                            trailing: "${item.time}".text.size(13).color(Get.theme.indicatorColor.withOpacity(0.7)).make(),
                                          );
                                        },
                                      )
                                    : !chatController.showLoader.value
                                        ? Container(
                                            height: Get.height * (0.40),
                                            child: "No conversation yet.".text.size(17).color(Get.theme.indicatorColor.withOpacity(0.5)).make(),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                              )
                            : Container(
                                width: Get.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: chatService.peopleData.value.users.length > 0
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: chatService.peopleData.value.users.length,
                                        shrinkWrap: true,
                                        itemExtent: 60,
                                        scrollDirection: Axis.vertical,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final item = chatService.peopleData.value.users.elementAt(index);
                                          return ListTile(
                                            onTap: () async {
                                              chatService.conversationUser.value.convId = 0;
                                              chatService.conversationUser.value.id = item.id;
                                              chatService.conversationUser.value.name = item.firstName + " " + item.lastName;
                                              chatService.conversationUser.value.userDP = item.dp;
                                              chatService.conversationUser.value.online = item.online;
                                              chatService.conversationUser.refresh();
                                              await chatController.fetchChat();
                                              Get.toNamed("/chat");
                                            },
                                            leading: Stack(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Get.theme.highlightColor,
                                                    borderRadius: BorderRadius.circular(100),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: item.dp != ""
                                                        ? CachedNetworkImage(
                                                            imageUrl: item.dp,
                                                            memCacheHeight: 40,
                                                            placeholder: (context, url) => Center(
                                                              child: CommonHelper.showLoaderSpinner(Colors.white),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            "assets/images/default-user.png",
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ).p(2),
                                                ),
                                                Positioned(
                                                  bottom: 2,
                                                  right: 1,
                                                  child: item.online
                                                      ? Container(
                                                          width: 13,
                                                          height: 13,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white, width: 2),
                                                            color: Colors.green,
                                                            borderRadius: BorderRadius.circular(100),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0,
                                                        ),
                                                ),
                                              ],
                                            ),
                                            title: "${item.firstName} ${item.lastName}".text.size(16).color(Get.theme.indicatorColor).make(),
                                          );
                                        },
                                      )
                                    : !chatController.showLoader.value
                                        ? Container(
                                            height: Get.height * (0.40),
                                            child: active == 1
                                                ? "No conversation yet.".text.size(17).color(Get.theme.indicatorColor.withOpacity(0.5)).make()
                                                : "No people yet.".text.size(17).color(Get.theme.indicatorColor.withOpacity(0.5)).make(),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                              )
                        : SizedBox(
                            height: 0,
                          ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
