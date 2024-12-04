import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:just_audio/just_audio.dart';

import '../core.dart';

class SoundController extends GetxController {
  int currentIndex = 0;
  String currentFile = "";
  AudioPlayer audioPlayer = AudioPlayer();

  GlobalKey<ScaffoldState> soundScaffoldKey = GlobalKey<ScaffoldState>();
  var jsonData;
  var getSoundResult;
  var getFavSoundResult;
  bool allPaused = true;
  int userId = 0;
  int videoId = 0;
  List<SoundData> sounds = [];
  var textController1 = TextEditingController();
  var textController2 = TextEditingController();
  String searchKeyword = '';
  String searchKeyword1 = '';
  String searchKeyword2 = '';
  String catSearchKeyword = '';
  Map<dynamic, dynamic> map = {};
  var showLoader = true.obs;
  ScrollController scrollController = new ScrollController();
  ScrollController scrollController1 = new ScrollController();
  ScrollController catScrollController = new ScrollController();
  int page = 1;
  bool moreResults = true;
  bool stillLoading = true;
  Color loaderBGColor = Colors.black;
  bool showLoadMore = true;
  int favPage = 1;
  int catPage = 1;
  SoundService soundService = Get.find();
  @override
  void onInit() {
    soundScaffoldKey = new GlobalKey();
    // TODO: implement onInit

    super.onInit();
    audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse("https://leuke.blr1.digitaloceanspaces.com/public/sounds/1704886450.mp3?qq=1"), tag: "https://leuke.blr1.digitaloceanspaces.com/public/sounds/1704886450.mp3?qq=1"),
    );
  }

  showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  selectSound(SoundData sound) {
    soundService.currentSound.value = sound;
    soundService.currentSound.refresh();
    return soundService.currentSound.value;
  }

  Future getSounds({searchKeyword}) async {
    // showLoader.value = true;
    // showLoader.refresh();

    if (page > 1) {
      // setState(() {
      loaderBGColor = Colors.black26;
      // });
    } else {
      scrollController = new ScrollController();
    }
    if (searchKeyword != "") {
      page = 1;
    }
    stillLoading = true;
    HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'get-sounds', requestData: {'page': page.toString(), 'search': searchKeyword}, method: "get");
    stillLoading = false;
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          soundService.soundsData.value.data.addAll(SoundModelList.fromJSON(json.decode(response.body)).data.toList());
        } else {
          soundService.soundsData.value = SoundModelList.fromJSON(json.decode(response.body));
        }
      }
    }
    soundService.soundsData.refresh();
    showLoader.value = false;
    showLoader.refresh();
    print("value.data ${soundService.soundsData.value.data}");
    if (soundService.soundsData.value.data.isNotEmpty) {
      print("asdasd");
      showLoadMore = true;
    } else {
      print("cvcbcv");
      showLoadMore = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (showLoadMore && !stillLoading) {
          // setState(() {
          page = page + 1;
          // });
          getSounds();
        }
      }
    });
  }

  Future<dynamic> setFavSound(soundId, set) async {
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(
          endPoint: "set-fav-sound",
          requestData: {
            "sound_id": soundId,
            "set": set,
          },
          method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {}
        return jsonData['msg'];
      } else {
        return "There's some server side issue";
      }
    } catch (e) {
      print(e.toString());
      return "There's some server side issue";
    }
  }

  Future getFavSounds([searchKeyword]) async {
    if (searchKeyword == null) {
      searchKeyword = "";
    }
    // showLoader.value = true;
    // showLoader.refresh();
    if (favPage == 1 && searchKeyword == '') {
      scrollController1 = new ScrollController();
    }

    if (favPage > 1) {
      // setState(() {
      loaderBGColor = Colors.black26;
      // });
    }
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'fav-sounds', requestData: {'page': page.toString(), 'search': searchKeyword2}, method: "get");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            soundService.favSoundsData.value.data.addAll(SoundModelList.fromJSON(json.decode(response.body)).data.toList());
          } else {
            soundService.favSoundsData.value = SoundModelList.fromJSON(json.decode(response.body));
          }
        }
      }
    } catch (e) {
      print(e.toString());
      soundService.favSoundsData.value = SoundModelList.fromJSON({});
    }
    soundService.favSoundsData.refresh();
    // showLoader.value = false;
    // showLoader.refresh();
    if (soundService.favSoundsData.value.data.isNotEmpty) {
      showLoadMore = true;
    } else {
      showLoadMore = false;
    }
    scrollController1.addListener(() {
      if (scrollController1.position.pixels == scrollController.position.maxScrollExtent) {
        if (showLoadMore) {
          favPage = favPage + 1;
          getFavSounds();
        }
      }
    });
  }

  Future getCatSounds(catId, [searchKeyword]) async {
    if (searchKeyword == null) {
      searchKeyword = "";
    }
    EasyLoading.show(status: "Loading...".tr);
    // showLoader.value = true;
    // showLoader.refresh();
    catScrollController = new ScrollController();
    if (favPage > 1) {
      // setState(() {
      loaderBGColor = Colors.black26;
      // });
    }
    if (searchKeyword != '' && searchKeyword != null) {
      soundService.catSoundsData.value = SoundModelList.fromJSON({});
      soundService.catSoundsData.refresh();
    }

    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'get-cat-sounds', requestData: {'cat_id': catId.toString(), 'search': searchKeyword});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (catPage > 1) {
            soundService.catSoundsData.value.data.addAll(SoundModelList.fromJSON(json.decode(response.body)).data.toList());
          } else {
            soundService.catSoundsData.value = SoundModelList.fromJSON(json.decode(response.body));
          }
        }
      }
    } catch (e) {
      print(e.toString());
      soundService.soundsData.value = SoundModelList.fromJSON({});
    }
    soundService.catSoundsData.refresh();
    EasyLoading.dismiss();
    if (soundService.catSoundsData.value.data.isNotEmpty) {
      showLoadMore = true;
    } else {
      showLoadMore = false;
    }
    catScrollController.addListener(() {
      if (catScrollController.position.pixels == catScrollController.position.maxScrollExtent) {
        if (showLoadMore) {
          // setState(() {
          catPage = catPage + 1;
          // });
          getCatSounds(catId);
        }
      }
    });
  }

  Future<SoundModelList> getData(page, searchKeyword) async {
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'get-sounds', requestData: {'page': page.toString(), 'search': searchKeyword}, method: "get");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            soundService.soundsData.value.data.addAll(SoundModelList.fromJSON(json.decode(response.body)).data.toList());
          } else {
            soundService.soundsData.value = SoundModelList.fromJSON(json.decode(response.body));
          }
        }
      }
    } catch (e) {
      print(e.toString());
      soundService.soundsData.value = SoundModelList.fromJSON({});
    }
    soundService.soundsData.refresh();
    return soundService.soundsData.value;
  }

  Future<SoundData> getSound(soundId) async {
    SoundData sound = SoundData.fromJSON({});
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(
          endPoint: "get-sound",
          requestData: {
            "sound_id": soundId.toString(),
          },
          method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          var map = Map<String, dynamic>.from(jsonData['data']);
          sound = SoundData.fromJSON(map);
        }
      }
    } catch (e) {
      print(e);
      sound = SoundData.fromJSON({});
    }
    return sound;
  }
}
