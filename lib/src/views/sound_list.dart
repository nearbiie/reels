import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../core.dart';

class SoundList extends StatefulWidget {
  SoundList();
  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends State<SoundList> {
  SoundController soundController = Get.find();
  SoundService soundService = Get.find();
  MainService mainService = Get.find();

  @override
  void initState() {
    soundController.getSounds();
    super.initState();
  }

  @override
  void dispose() {
    soundController.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () {
        mainService.isOnRecordingPage.value = true;
        Get.put(VideoRecorderController(), permanent: true);

        soundController.audioPlayer.stop();
        Get.offNamed('/video-recorder');
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Get.theme.primaryColor,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Get.theme.iconTheme.color,
              ),
              onPressed: () async {
                soundController.audioPlayer.stop();
                mainService.isOnRecordingPage.value = true;
                mainService.isOnRecordingPage.refresh();
                Get.put(VideoRecorderController(), permanent: true);
                Get.offNamed("/video-recorder");
              },
            ),
            iconTheme: IconThemeData(
              size: 16,
              color: Get.theme.indicatorColor, //change your color here
            ),
            backgroundColor: Get.theme.primaryColor,
            centerTitle: true,
          ),
          body: Container(
            color: Get.theme.primaryColor,
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Get.theme.primaryColor,
                    child: TabBar(
                      onTap: (index) {
                        if (index == 1) {
                          soundController.getFavSounds();
                        } else {
                          soundController.getSounds();
                        }
                      },
                      indicatorColor: Colors.black,
                      labelColor: Get.theme.indicatorColor,
                      unselectedLabelColor: Get.theme.indicatorColor.withOpacity(0.3),
                      indicatorWeight: 1,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Discover",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'RockWellStd',
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Favorites",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'RockWellStd',
                                    color: Get.theme.indicatorColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: Get.theme.iconTheme.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () {
                      return SingleChildScrollView(
                        child: Container(
                          color: Get.theme.primaryColor,
                          height: Get.height - 145,
                          child: TabBarView(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 45,
                                    child: TextField(
                                      controller: soundController.textController1,
                                      style: TextStyle(
                                        color: Get.theme.indicatorColor,
                                        fontSize: 16.0,
                                      ),
                                      obscureText: false,
                                      keyboardType: TextInputType.text,
                                      onChanged: (String val) {
                                        // soundController.searchKeyword1 = val;
                                        if (val.length > 2) {
                                          Timer(Duration(milliseconds: 1000), () {
                                            soundController.getSounds(searchKeyword: val);
                                          });
                                        }
                                        if (val.length == 0) {
                                          print("length 0");
                                          Timer(Duration(milliseconds: 1000), () {
                                            soundController.getSounds();
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Search",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.only(bottom: 12),
                                          onPressed: () {
                                            soundController.textController1.clear();
                                            soundController.searchKeyword = "";
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: soundController.searchKeyword != "" ? Get.theme.iconTheme.color : Colors.transparent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).pSymmetric(h: 10),
                                  Obx(() {
                                    if (soundService.soundsData.value.data.length > 0) {
                                      return Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: Get.height - 200,
                                            child: GroupedListView<SoundData, String>(
                                              shrinkWrap: true,
                                              controller: soundController.scrollController,
                                              elements: soundService.soundsData.value.data,
                                              groupBy: (element) => element.category + "_" + element.catId,
                                              order: GroupedListOrder.DESC,
                                              groupSeparatorBuilder: (String value) {
                                                var full = value.split("_");
                                                return Container(
                                                  color: Get.theme.primaryColor,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          full[0],
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            color: Get.theme.indicatorColor,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            soundService.catId = int.parse(full[1]);
                                                            soundService.catName = full[0];
                                                            Get.offNamed('/sound-cat-list');
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(7),
                                                              color: Get.theme.primaryColor.withOpacity(0.5),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Text(
                                                                "View More",
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Get.theme.indicatorColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              itemBuilder: (c, e) {
                                                return PlayerWidget(
                                                  sound: e,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      if (!soundController.showLoader.value) {
                                        return Center(
                                          child: Container(
                                            height: Get.height - 185,
                                            width: Get.width,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "No Sounds found",
                                                  style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          color: Get.theme.primaryColor,
                                          child: Center(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: new AlwaysStoppedAnimation<Color>(Get.theme.iconTheme.color!),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    /*} else {
                                          if (!soundController.showLoader.value) {
                                            return Center(
                                              child: Container(
                                                height: Get.height - 185,
                                                width: Get.width,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "No Sounds found",
                                                      style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              color: Get.theme.primaryColor,
                                              child: Center(
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(
                                                      Get.theme.iconTheme.color!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }*/
                                    // :CommonHelper.showLoaderSpinner(Colors.white);
                                  }),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: Get.width,
                                    child: TextField(
                                      controller: soundController.textController2,
                                      style: TextStyle(
                                        color: Get.theme.indicatorColor,
                                        fontSize: 16.0,
                                      ),
                                      obscureText: false,
                                      keyboardType: TextInputType.text,
                                      onChanged: (String val) {
                                        soundController.searchKeyword2 = val;
                                        if (val.length > 2) {
                                          Timer(Duration(seconds: 1), () {
                                            soundController.getFavSounds(val);
                                          });
                                        }
                                        if (val.length == 0) {
                                          Timer(Duration(milliseconds: 1000), () {
                                            soundController.getFavSounds();
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: mainService.setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Search favorite sound",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.only(bottom: 12),
                                          onPressed: () {
                                            soundController.textController2.clear();
                                            soundController.searchKeyword2 = "";
                                            soundController.getFavSounds();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: soundController.searchKeyword2 != "" ? Get.theme.iconTheme.color : Colors.transparent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).pSymmetric(h: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 48.0),
                                    child: Container(
                                      height: Get.height * .8 - 90,
                                      child: Obx(() {
                                        return (soundService.favSoundsData.value.data.isNotEmpty)
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                controller: soundController.scrollController1,
                                                itemCount: soundService.favSoundsData.value.data.length,
                                                itemBuilder: (context, index) {
                                                  return PlayerWidget(
                                                    sound: soundService.favSoundsData.value.data[index],
                                                  );
                                                })
                                            : (!soundController.showLoader.value)
                                                ? Center(
                                                    child: Container(
                                                      height: Get.height - 360,
                                                      width: Get.width,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Text(
                                                            "No favourite sounds found",
                                                            style: TextStyle(color: Get.theme.indicatorColor, fontSize: 15),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Get.theme.primaryColor,
                                                    child: Center(
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: new AlwaysStoppedAnimation<Color>(Get.theme.iconTheme.color!),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

//  }
//}
class SoundCatList extends StatefulWidget {
  SoundCatList();
  @override
  _SoundCatListState createState() => _SoundCatListState();
}

class _SoundCatListState extends State<SoundCatList> {
  Map<String, dynamic> sounds = {};

  List soundsList = [];
  var _textController = TextEditingController();
  SoundController soundController = Get.find();
  MainService mainService = Get.find();
  SoundService soundService = Get.find();

  @override
  void initState() {
    print("widget.catId");
    print(soundService.catId);

    soundController.catPage = 1;
    soundController.getCatSounds(soundService.catId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*SoundModel find(List<SoundData> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.toNamed("/sound-list");
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Get.theme.primaryColor,
        key: soundController.soundScaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Get.theme.iconTheme.color),
              onPressed: () {
                soundController.audioPlayer.stop();
                Get.toNamed("/sound-list");
              }),
          title: Text(
            soundService.catName,
            style: TextStyle(color: Get.theme.indicatorColor),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Container(
          color: Get.theme.primaryColor,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 2,
                child: Container(
                  color: Get.theme.primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  // width: Get.width - 50,
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(
                      color: Get.theme.indicatorColor,
                      fontSize: 16.0,
                    ),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    onChanged: (String val) {
                      soundController.catSearchKeyword = val;
                      if (val.length > 2) {
                        Timer(Duration(seconds: 1), () {
                          soundController.getCatSounds(soundService.catId, val);
                        });
                      }
                      if (val.length == 0) {
                        Timer(Duration(milliseconds: 1000), () {
                          soundController.getCatSounds(soundService.catId);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        wordSpacing: 2.0,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Get.theme.indicatorColor,
                          width: 0.3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Get.theme.indicatorColor,
                          width: 0.3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Get.theme.indicatorColor,
                          width: 0.3,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.only(bottom: 12),
                        onPressed: () {
                          _textController.clear();
                          soundController.getCatSounds(soundService.catId);
                        },
                        icon: Icon(
                          Icons.clear,
                          color: soundController.searchKeyword2 != "" ? Get.theme.iconTheme.color : Colors.transparent,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () {
                  return (soundService.catSoundsData.value.data.length > 0)
                      ? SingleChildScrollView(
                          child: Container(
                            height: Get.height - 150,
                            color: Get.theme.primaryColor,
                            child: ListView.builder(
                              shrinkWrap: true,
                              controller: soundController.catScrollController,
                              itemCount: soundService.catSoundsData.value.data.length,
                              itemBuilder: (context, index) {
                                return PlayerWidget(
                                  sound: soundService.catSoundsData.value.data[index],
                                );
                              },
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            height: Get.height - 360,
                            width: Get.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                (!soundController.showLoader.value)
                                    ? Text(
                                        "No sounds found in this category",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      )
                                    : Center(
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
