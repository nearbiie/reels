import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as EmojiPickers;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../core.dart';

class ChatView extends StatefulWidget {
  ChatView({Key? key}) : super(key: key);
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ChatController chatController = Get.find();
  ChatService chatService = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        chatController.chatScrollController.removeListener(chatController.listener);
        chatService.currentConversation.value = Conversation.fromJSON({});
        chatService.currentConversation.refresh();
        return Future.value(true);
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: Get.theme.primaryColor,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(
              size: 16,
              color: Get.theme.indicatorColor, //change your color here
            ),
            leadingWidth: 30,
            titleSpacing: 10,
            backgroundColor: Get.theme.primaryColor,
            leading: InkWell(
              onTap: () {
                chatController.chatScrollController.removeListener(chatController.listener);
                chatService.currentConversation.value = Conversation.fromJSON({});
                chatService.currentConversation.refresh();
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
                color: Get.theme.iconTheme.color,
              ),
            ),
            centerTitle: true,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 80,
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: chatService.conversationUser.value.userDP != ""
                            ? CachedNetworkImage(
                                imageUrl: chatService.conversationUser.value.userDP,
                                placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              )
                            : Image.asset(
                                "assets/images/default-user.png",
                              ),
                      ).centered(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "${chatService.conversationUser.value.name}".text.black.ellipsis.bold.size(16).make(),
                          chatService.showTyping.value
                              ? Row(
                                  children: [
                                    DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                      ),
                                      child: AnimatedTextKit(
                                        animatedTexts: [
                                          TyperAnimatedText('typing...', speed: Duration(milliseconds: 100)),
                                        ],
                                        isRepeatingAnimation: true,
                                        repeatForever: true,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Obx(
              () => Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          color: Get.theme.primaryColor,
                          child: chatService.currentConversation.value.messages.isNotEmpty
                              ? Container(
                                  color: Get.theme.primaryColor,
                                  padding: EdgeInsets.only(bottom: 55),
                                  child: GroupedListView<ChatMessage, String>(
                                    shrinkWrap: true,
                                    elements: chatService.currentConversation.value.messages,
                                    controller: chatController.chatScrollController,
                                    groupBy: (ChatMessage element) => element.sentDate,
                                    itemComparator: (item1, item2) => (DateFormat("yyyy-MM-dd HH:mm:ss").parse(item2.sentDatetime))
                                        .millisecondsSinceEpoch
                                        .compareTo((DateFormat("yyyy-MM-dd HH:mm:ss").parse(item1.sentDatetime)).millisecondsSinceEpoch),
                                    groupComparator: (item1, item2) =>
                                        (DateFormat('dd MMM yyyy').parse(item2)).millisecondsSinceEpoch.compareTo((DateFormat('dd MMM yyyy').parse(item1)).millisecondsSinceEpoch),
                                    useStickyGroupSeparators: true, // optional
                                    floatingHeader: true, // optional
                                    order: GroupedListOrder.DESC, // optional
                                    groupSeparatorBuilder: (String groupByValue) {
                                      return Container(
                                        width: Get.width,
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Expanded(child: Divider()),
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 1.7),
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                    6.0,
                                                  ),
                                                  margin: EdgeInsets.all(
                                                    3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(15),
                                                    ),
                                                    color: Get.theme.highlightColor,
                                                  ),
                                                  child: Text(
                                                    groupByValue,
                                                    style: TextStyle(
                                                      fontFamily: "NanumGothic",
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: mainService.setting.value.buttonTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Divider()),
                                          ],
                                        ),
                                      );
                                    },
                                    itemBuilder: (context, ChatMessage message) {
                                      return Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(top: 3, bottom: 3),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 14, right: 14, top: 3, bottom: 3),
                                          child: Column(
                                            crossAxisAlignment: message.userId != authService.currentUser.value.id ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                            children: [
                                              Align(
                                                alignment: (message.userId != authService.currentUser.value.id ? Alignment.topLeft : Alignment.topRight),
                                                child: Row(
                                                  mainAxisAlignment: message.userId != authService.currentUser.value.id ? MainAxisAlignment.start : MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    message.userId != authService.currentUser.value.id
                                                        ? Container(
                                                            width: 30,
                                                            height: 30,
                                                            margin: EdgeInsets.only(bottom: 20),
                                                            decoration: BoxDecoration(
                                                              color: mainService.setting.value.dpBorderColor,
                                                              borderRadius: BorderRadius.circular(100),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(100),
                                                              child: chatService.conversationUser.value.userDP != ""
                                                                  ? CachedNetworkImage(
                                                                      imageUrl: chatService.conversationUser.value.userDP,
                                                                      memCacheHeight: 50,
                                                                      memCacheWidth: 50,
                                                                      width: 40,
                                                                      height: 40,
                                                                      fit: BoxFit.cover,
                                                                    )
                                                                  : Image.asset(
                                                                      "assets/images/default-user.png",
                                                                    ),
                                                            ).p(2),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      width: message.userId != authService.currentUser.value.id ? 5 : 0,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: message.userId != authService.currentUser.value.id ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onLongPress: () {
                                                            Clipboard.setData(new ClipboardData(text: message.msg));
                                                            ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: new Text("Copied to Clipboard")));
                                                          },
                                                          child: Container(
                                                            constraints: BoxConstraints(maxWidth: Get.width * 065),
                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                            margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  message.userId == authService.currentUser.value.id ? mainService.setting.value.myMsgColor : mainService.setting.value.senderMsgColor,
                                                              borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(15.0),
                                                                bottomRight: Radius.circular(message.userId == authService.currentUser.value.id ? 0 : 15.0),
                                                                bottomLeft: Radius.circular(message.userId == authService.currentUser.value.id ? 15.0 : 0),
                                                                topLeft: Radius.circular(15.0),
                                                              ),
                                                            ),
                                                            child: message.msg.selectableText
                                                                .textStyle(
                                                                  TextStyle(
                                                                    fontSize: 14,
                                                                    color: message.userId == authService.currentUser.value.id
                                                                        ? mainService.setting.value.myMsgTextColor
                                                                        : mainService.setting.value.senderMsgTextColor,
                                                                  ),
                                                                )
                                                                .make(),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(4, 2, 0, 3),
                                                          child: message.sentOn.text.textStyle(TextStyle(fontSize: 10, color: Get.theme.indicatorColor.withOpacity(0.6))).make(),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: message.userId == authService.currentUser.value.id ? 5 : 0,
                                                    ),
                                                    message.userId == authService.currentUser.value.id
                                                        ? Container(
                                                            width: 30,
                                                            height: 30,
                                                            margin: EdgeInsets.only(bottom: 20),
                                                            decoration: BoxDecoration(
                                                              color: mainService.setting.value.dpBorderColor,
                                                              borderRadius: BorderRadius.circular(100),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(100),
                                                              child: authService.currentUser.value.userDP != ""
                                                                  ? CachedNetworkImage(
                                                                      imageUrl: authService.currentUser.value.userDP,
                                                                      memCacheHeight: 50,
                                                                      memCacheWidth: 50,
                                                                      width: 40,
                                                                      height: 40,
                                                                      fit: BoxFit.cover,
                                                                    )
                                                                  : Image.asset(
                                                                      "assets/images/default-user.png",
                                                                    ),
                                                            ).p(2),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  height: 10,
                                  color: Colors.white,
                                ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  margin: EdgeInsets.only(left: 0, bottom: 2, top: 0),
                                  constraints: BoxConstraints(
                                    maxHeight: 300,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Get.theme.shadowColor,
                                  ),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Obx(
                                        () => Container(
                                          width: Get.width * 0.95,
                                          child: TextField(
                                            maxLines: null,
                                            minLines: 1,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Get.theme.primaryColorDark,
                                            ),
                                            onTap: () {
                                              if (chatController.emojiShowing.value) {
                                                chatController.emojiShowing.value = false;
                                                chatController.emojiShowing.refresh();
                                              }
                                              if (chatController.chatScrollController.positions.isNotEmpty) {
                                                Timer(
                                                  Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  () => chatController.chatScrollController.animateTo(
                                                    chatController.chatScrollController.position.maxScrollExtent,
                                                    duration: Duration(milliseconds: 100),
                                                    curve: Curves.easeInOut,
                                                  ),
                                                );
                                              }
                                            },
                                            onChanged: (value) {
                                              if (value.length == 1) {
                                                chatController.typing(true);
                                              }
                                              if (value.length == 0) {
                                                chatController.typing(false);
                                              }
                                              chatController.message = value;
                                            },
                                            controller: chatController.msgController,
                                            decoration: InputDecoration(
                                              fillColor: Get.theme.primaryColor,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              hintText: chatService.showTyping.value ? "${chatService.conversationUser.value.name} is typing.." : "Say something",
                                              hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.primaryColorDark.withOpacity(0.5)),
                                              prefixIcon: InkWell(
                                                onTap: () {
                                                  FocusScope.of(context).unfocus();
                                                  chatController.emojiShowing.value = !chatController.emojiShowing.value;
                                                  chatController.emojiShowing.refresh();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(13),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/smile.svg',
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.fill,
                                                    colorFilter: ColorFilter.mode(Get.theme.primaryColorDark.withOpacity(0.5), BlendMode.srcIn),
                                                  ),
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                            ),
                                          ),
                                        ).centered(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                chatController.typing(false);
                                chatController.sendMsg();
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/send.svg',
                                width: 25,
                                height: 25,
                                fit: BoxFit.fill,
                                colorFilter: ColorFilter.mode(Get.theme.highlightColor, BlendMode.srcIn),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !chatController.emojiShowing.value,
                    child: SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        onEmojiSelected: (EmojiPickers.Category? category, Emoji emoji) {
                          chatController.onEmojiSelected(emoji);
                        },
                        onBackspacePressed: chatController.onBackspacePressed,
                        config: Config(
                          height: 256,
                          // bgColor: const Color(0xFFF2F2F2),
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            // Issue: https://github.com/flutter/flutter/issues/28894
                            emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                          ),
                          swapCategoryAndBottomBar: false,
                          skinToneConfig: const SkinToneConfig(),
                          categoryViewConfig: const CategoryViewConfig(),
                          bottomActionBarConfig: const BottomActionBarConfig(),
                          searchViewConfig: const SearchViewConfig(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
