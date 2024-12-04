import 'dart:async';
import 'dart:convert';
import 'dart:io';

//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as HTTP;
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class DashboardController extends GetxController {
  MainService mainService = Get.find();
  PostService postService = Get.find();
  DashboardService dashboardService = Get.find();
  AuthService authService = Get.find();

  int videoId = 0;
  bool completeLoaded = false;
  String commentValue = '';
  bool textFieldMoveToUp = false;
  DateTime currentBackPressTime = DateTime.now();
  // GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  var pageViewController = new PageController(initialPage: 0).obs;
  PanelController pc = new PanelController();
  PanelController pc2 = new PanelController();
  PanelController pc3 = new PanelController();
  var hideBottomBar = false.obs;
  CommentData commentObj = new CommentData();

  var isVideoInitialized = false.obs;
  var dataLoaded = false.obs;
  var likeShowLoader = false.obs;
  var shareShowLoader = false.obs;
  var showReportLoader = false.obs;
  var showReportMsg = false.obs;
  var loadMoreUpdateView = false.obs;
  var commentsLoader = false.obs;
  var soundShowLoader = false.obs;
  var isFollowedAnyPerson = false.obs;
  var showBannerAd = false.obs;
  var showHomeLoader = false.obs;
  var showLikedAnimation = false.obs;
  ScrollController scrollController = new ScrollController();
  ScrollController scrollController1 = new ScrollController();

  int commentsPaging = 1;
  bool showLoadMoreComments = true;
  int active = 2;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  bool chkVideos = true;
  bool moreVideos = true;
  bool iFollowedAnyUser = false;
  int page = 1;
  int loginUserId = 0;
  String appToken = '';
  List videoList = [];
  // var response;
  int following = 0;
  int isFollowingVideos = 0;
  bool userFollowSuggestion = false;
  bool isLoggedIn = false;
  bool isLiked = false;
  bool videoInitialized = false;

  int index = 0;
  int videoIndex = 0;

  bool lock = true;
  static const double ActionWidgetSize = 60.0;
  static const double ProfileImageSize = 50.0;
  int soundId = 0;
  int userId = 0;
  String totalComments = '0';
  String userDP = '';
  String soundImageUrl = '';
  int isFollowing = 0;
  var isLoading = false.obs;
  var showFollowLoader = false.obs;
  String encodedVideoId = '';
  String selectedType = "It's spam";
  String encKey = 'yfmtythd84n4h';
  String mainServicertDescription = "";
  int chkVideo = 0;
  List<String> reportType = [
    "It's spam",
    "It's inappropriate",
    "I don't like it"
  ];
  bool videoStarted = true;
  bool initializePage = true;
  bool showNavigateLoader = false;
  FocusNode inputNode = FocusNode();
  var editedComment = "".obs;
  late BannerAd myBanner;
  TextEditingController liveCommentController = TextEditingController();
  var showProgress = false.obs;
  // int dashboardService.pageIndex = 0;

  DashboardController() {
    // mainService.userVideoObj.value = {"userId": 0, "videoId": 0, "user": ""};
  }
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? myRewarded;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  late VideoPlayerController controller;
  bool lights = false;
  late Duration duration;
  late Duration position;
  bool isEnd = false;
  var onTap = false.obs;
  late Future<void> initializeVideoPlayerFuture;
  var commentController = TextEditingController().obs;

  bool inCalling = false;
  bool micOn = true;
  var videoObj = Video().obs;
  ExpandableController? expandController;
  @override
  void onInit() {
    // expandController = ExpandableController.of(Get.context!, required: true)!;
    dashboardService.pageIndex.value = 0;

    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  updateSwiperIndex(int index) {
    dashboardService.pageIndex.value = index;
  }

  updateSwiperIndex2(int index) {
    dashboardService.pageIndex.value = index;
  }

  onVideoChange(String videoId) {
    videoId = videoId;
  }

  jumpToCurrentVideo() {
    print("jumpToCurrentVideo ${dashboardService.pageIndex.value}");
    pageViewController.value =
        PageController(initialPage: dashboardService.pageIndex.value);
    pageViewController.refresh();
  }

  getAds() async {
    HTTP.Response response = await CommonHelper.sendRequestToServer(
        endPoint: 'get-ads', requestData: {"data_var": "data"});

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        mainService.adsData.value = new Map<String, dynamic>.from(jsonData);
        mainService.adsData.refresh();
        print("getAdsresponse $response");
        appId = Platform.isAndroid
            ? jsonData['android_app_id']
            : jsonData['ios_app_id'];
        bannerUnitId = Platform.isAndroid
            ? jsonData['android_banner_app_id']
            : jsonData['ios_banner_app_id'];
        screenUnitId = Platform.isAndroid
            ? jsonData['android_interstitial_app_id']
            : jsonData['ios_interstitial_app_id'];
        videoUnitId = Platform.isAndroid
            ? jsonData['android_video_app_id']
            : jsonData['ios_video_app_id'];
        bannerShowOn = jsonData['banner_show_on'];
        interstitialShowOn = jsonData['interstitial_show_on'];
        videoShowOn = jsonData['video_show_on'];
      }

      if (appId != "") {
        MobileAds.instance.initialize().then((value) async {
          if (bannerShowOn.indexOf("1") > -1) {
            print("asdzxcqwe");
            showBannerAd.value = true;
            showBannerAd.refresh();
            // dashboardService.paddingBottom.value = Platform.isAndroid ? 50.0 : 80.0;
          }

          if (interstitialShowOn.indexOf("1") > -1) {
            createInterstitialAd(screenUnitId);
          }

          if (videoShowOn.indexOf("1") > -1) {
            await createRewardedAd(videoUnitId);
          }
        });
      }
    }
  }

  createInterstitialAd(adUnitId) {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('Ad loaded.');
          print('$ad loaded');

          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          print('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createInterstitialAd(adUnitId);
          }
        },
      ),
    );
    Future<void>.delayed(
        Duration(seconds: 3), () => _showInterstitialAd(adUnitId));
  }

  void _showInterstitialAd(adUnitId) {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // createInterstitialAd(adUnitId);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd(adUnitId);
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  createRewardedAd(adUnitId) {
    RewardedAd.load(
        adUnitId: adUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            myRewarded = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            myRewarded = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              createRewardedAd(adUnitId);
            }
          },
        ));

    Future<void>.delayed(
        Duration(seconds: 10), () => _showRewardedAd(adUnitId));
  }

  void _showRewardedAd(adUnitId) {
    if (myRewarded == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    myRewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // createRewardedAd(adUnitId);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd(adUnitId);
      },
    );

    myRewarded!.setImmersiveMode(true);
    myRewarded!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    myRewarded = null;
  }

  disposeControls(controls) {
    controls.forEach((key, value2) async {
      await value2.dispose();
    });
  }

  checkEulaAgreement() async {
    bool? check = GetStorage().read('EULA_agree') ?? false;
    bool agree = false;
    if (!check) {
      try {
        var response = await CommonHelper.sendRequestToServer(
            endPoint: 'get-eula-agree', requestData: {"data_var": "data"});
        print("checkEulaAgreement response ${response.body}");
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            if (jsonData['eulaAgree'] == 1) {
              agree = true;
            } else {
              agree = false;
            }
          } else {
            agree = false;
          }
        } else {
          agree = false;
        }

        if (agree) {
          GetStorage().write('EULA_agree', agree);
        } else {
          getEulaAgreement();
        }
      } catch (e) {
        print(e.toString() + "checkEulaAgreement Catch Errors");
      }
    } else {
      return true;
    }
  }

  Future getEulaAgreement() async {
    try {
      var response = await CommonHelper.sendRequestToServer(
          endPoint: 'end-user-license-agreement',
          requestData: {"data_var": "data"});
      var value = "";
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          value = json.encode(json.decode(response.body)['data']);
        } else {
          value = "";
        }
      } else {
        value = "";
      }
      print("getEulaAgreement : $value");
      dashboardService.eulaData = json.decode(value);
      mainService.isOnHomePage.value = false;
      mainService.isOnHomePage.refresh();
      stopController(dashboardService.pageIndex.value);
      Get.offNamed("/eula");
    } catch (e) {
      print(e.toString() + "catch Errors");
    }
    return true;
  }

  Future<void> getVideos() async {
    dashboardService.pageIndex.value = 0;
    isLoading.value = true;
    isLoading.refresh();
    isVideoInitialized.value = false;
    isVideoInitialized.refresh();
    dashboardService.pageIndex.value = 0;
    dashboardService.videosData.value.videos = [];
    dashboardService.videosData.refresh();
    page = 1;
    formKey = GlobalKey();
    getAds();
    Map obj = {'userId': 0, 'videoId': 0};

    if (mainService.userVideoObj.value.userId > 0) {
      obj['userId'] = mainService.userVideoObj.value.userId;
      obj['videoId'] = mainService.userVideoObj.value.videoId;
    } else if (mainService.userVideoObj.value.videoId > 0) {
      obj['videoId'] = mainService.userVideoObj.value.videoId;
      obj['search_type'] = mainService.userVideoObj.value.searchType;
    }
    if (mainService.userVideoObj.value.hashTag != "") {
      obj['hashtag'] = mainService.userVideoObj.value.hashTag;
    }
    if (dashboardService.randomString.value == "") {
      dashboardService.randomString.value =
          CommonHelper.getRandomString(4, numeric: true);
    }
    Map<String, String> requestData = {
      "page_size": '10',
      "random": dashboardService.randomString.value,
      "page": page.toString(),
      "user_id": (obj['userId'] == null) ? '0' : obj['userId'].toString(),
      "video_id": (obj['videoId'] == null) ? '0' : obj['videoId'].toString(),
      "hashtag": (obj['hashtag'] == null) ? '' : obj['hashtag'].toString(),
      "search_type":
          (obj['search_type'] == null) ? '' : obj['search_type'].toString(),
      "following": dashboardService.showFollowingPage.value ? '1' : '0',
    };
    var distinctIds = dashboardService.postIds.toSet().toList();
    if (distinctIds.isNotEmpty) {
      requestData['post_ids'] = distinctIds.join(",");
    }
    HTTP.Response response = await CommonHelper.sendRequestToServer(
      endPoint: "get-videos",
      requestData: requestData,
      method: "post",
    );
    isLoading.value = false;
    isLoading.refresh();
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print(
          "jsonData get videos ${jsonData['messagesCount']} ${json.decode(response.body)['data']}");
      if (jsonData['status'] == 'success') {
        mainService.firstTimeLoad.value = false;
        dashboardService.unreadMessageCount.value =
            jsonData['messagesCount'] ?? 0;
        dashboardService.unreadMessageCount.refresh();
        if (page > 1) {
          dashboardService.videosData.value.videos.addAll(
              VideoModel.fromJSON(json.decode(response.body)['data']).videos);
        } else {
          dashboardService.videosData.value =
              VideoModel.fromJSON(json.decode(response.body)['data']);
          videoObj.value =
              dashboardService.videosData.value.videos.elementAt(0);
        }
        dashboardService.videosData.refresh();
      } else {
        Fluttertoast.showToast(msg: "Error while fetching data");
      }
    }
  }

  Future<void> listenForMoreVideos() async {
    print("listenForMoreVideos");
    Map obj = {'userId': 0, 'videoId': 0};
    if (mainService.userVideoObj.value.userId > 0) {
      obj['userId'] = mainService.userVideoObj.value.userId;
      obj['videoId'] = mainService.userVideoObj.value.videoId;
    } else if (mainService.userVideoObj.value.videoId > 0) {
      obj['videoId'] = mainService.userVideoObj.value.videoId;
    } else if (mainService.userVideoObj.value.hashTag != "") {
      obj['hashtag'] = mainService.userVideoObj.value.hashTag;
    }
    Map<String, String> requestData = {
      "page_size": '10',
      "random": dashboardService.randomString.value,
      "page": page.toString(),
      "user_id": (obj['userId'] == null) ? '0' : obj['userId'].toString(),
      "video_id": (obj['videoId'] == null) ? '0' : obj['videoId'].toString(),
      "hashtag": (obj['hashtag'] == null) ? '' : obj['hashtag'].toString(),
      "search_type":
          (obj['search_type'] == null) ? '' : obj['search_type'].toString(),
      "following": dashboardService.showFollowingPage.value ? '1' : '0',
    };
    var distinctIds = dashboardService.postIds.toSet().toList();
    if (distinctIds.isNotEmpty) {
      requestData['post_ids'] = distinctIds.join(",");
    }
    page = page + 1;
    HTTP.Response response = await CommonHelper.sendRequestToServer(
      endPoint: "get-videos",
      requestData: requestData,
      method: "post",
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("get videos ${jsonData['messagesCount']}");
      if (jsonData['status'] == 'success') {
        mainService.firstTimeLoad.value = false;
        dashboardService.unreadMessageCount.value =
            jsonData['messagesCount'] ?? 0;
        dashboardService.unreadMessageCount.refresh();
        if (page > 1) {
          dashboardService.videosData.value.videos.addAll(
              VideoModel.fromJSON(json.decode(response.body)['data']).videos);
        } else {
          dashboardService.videosData.value =
              VideoModel.fromJSON(json.decode(response.body)['data']);
        }
        dashboardService.videosData.refresh();
      } else {
        Fluttertoast.showToast(msg: "Error while fetching data");
      }
    }
  }

/*
  Future<void> listenForMoreUserFollowingVideos() async {
    page = page + 1;
    dashboardApi.getFollowingUserVideos(page).whenComplete(() {
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.refresh();
    });
  }
*/
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    if (authService.currentUser.value.accessToken != '') {
      likeVideo(dashboardService.pageIndex.value);
    } else {
      hideBottomBar.value = false;
      hideBottomBar.refresh();
      stopController(dashboardService.pageIndex.value);
      Get.offNamed("/login");
    }
    return !isLiked;
  }

  Future<void> likeVideo(int index) async {
    likeShowLoader.value = true;
    likeShowLoader.refresh();
    int chkIndex = authService.currentUser.value.userFavoriteVideos
        .indexWhere((element) => element.videoId == videoObj.value.videoId);
    if (!videoObj.value.isLike) {
      videoObj.value.totalLikes = videoObj.value.totalLikes + 1;
      if (chkIndex == -1) {
        authService.currentUser.value.userFavoriteVideos
            .insert(0, videoObj.value);
        authService.currentUser.value.totalUserFavoriteVideos++;
      }
    } else if (videoObj.value.totalLikes > 0) {
      if (chkIndex > -1) {
        authService.currentUser.value.userFavoriteVideos.removeWhere(
            (element) => element.videoId == videoObj.value.videoId);
        authService.currentUser.value.totalUserFavoriteVideos--;
      }
      videoObj.value.totalLikes = videoObj.value.totalLikes - 1;
    } else {}
    authService.currentUser.refresh();
    videoObj.value.isLike = (videoObj.value.isLike) ? false : true;
    videoObj.refresh();
    dashboardService.videosData.value.videos[index] = videoObj.value;
    dashboardService.videosData.refresh();
    print(
        "dashboardService.videosData.value.videos.elementAt(index).videoId $index ${dashboardService.videosData.value.videos.elementAt(index).videoId}");
    try {
      await CommonHelper.sendRequestToServer(
          endPoint: 'video-like',
          requestData: {
            "video_id": dashboardService.videosData.value.videos
                .elementAt(index)
                .videoId
                .toString()
          },
          method: "post");
      likeShowLoader.value = false;
      likeShowLoader.refresh();
    } catch (e) {
      likeShowLoader.value = false;
      likeShowLoader.refresh();
    }
  }

  Future<void> submitReport(Video videoObj, context) async {
    showReportLoader.value = true;
    showReportLoader.refresh();
    await CommonHelper.sendRequestToServer(
      endPoint: 'submit-report',
      requestData: {
        "video_id": videoObj.videoId.toString(),
        "type": selectedType,
        "description": mainService.rtDescription,
        "blocked": mainService.rtBlocked.value ? 1 : 0
      },
      method: "post",
    );
    showReportLoader.value = false;
    showReportLoader.refresh();
    selectedType = "It's spam";
    mainServicertDescription = '';
    showReportMsg.value = true;
    showReportMsg.refresh();
    Timer(Duration(seconds: 5), () {
      if (!dashboardService.showFollowingPage.value) {
        dashboardService.videosData.value.videos
            .removeWhere((element) => element.videoId == videoObj.videoId);
        dashboardService.videosData.refresh();
      }
      Get.back();
    });
  }

  Future<void> getComments(Video videoObj) async {
    print("getComments ${videoObj.videoId}");
    postService.commentsObj.value.comments = [];
    showLoadMoreComments = true;
    page = 1;
    scrollController = new ScrollController();
    scrollController1 = new ScrollController();
    HTTP.Response response = await CommonHelper.sendRequestToServer(
        endPoint: 'fetch-video-comments',
        requestData: {
          "page": page.toString(),
          "video_id": videoObj.videoId.toString(),
        },
        method: "post");

    List<CommentData> newComments =
        parseComments(json.decode(response.body)['data']);
    postService.commentsObj.value.comments.addAll(newComments);
    if (postService.commentsObj.value.comments.length ==
        videoObj.totalComments) {
      showLoadMoreComments = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (postService.commentsObj.value.comments.length !=
                videoObj.totalComments &&
            showLoadMoreComments) {
          loadMore(videoObj);
        }
      }
    });
  }

  loadMore(Video videoObj) async {
    print("loadMoreComment ${videoObj.videoId}");
    commentsLoader.value = true;
    commentsLoader.refresh();
    page = page + 1;
    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'fetch-video-comments',
        requestData: {
          "page": page.toString(),
          "video_id": videoObj.videoId.toString(),
        },
        method: "post");

    print("comments response.body ${response.body}");
    List<CommentData> newComments =
        parseComments(json.decode(response.body)['data']);
    postService.commentsObj.value.comments.addAll(newComments);
    commentsLoader.value = false;
    commentsLoader.refresh();
    if (postService.commentsObj.value.comments.length ==
        videoObj.totalComments) {
      showLoadMoreComments = false;
    }
    loadMoreUpdateView.value = true;
    loadMoreUpdateView.refresh();
  }

  List<CommentData> parseComments(attributesJson) {
    List list = attributesJson;
    List<CommentData> attrList =
        list.map((data) => CommentData.fromJSON(data)).toList();
    return attrList;
  }

  Future<void> addComment(int videoId, context) async {
    FocusScope.of(context).unfocus();
    commentController.value = new TextEditingController(text: "");
    commentObj = new CommentData();
    commentObj.videoId = videoId;
    commentObj.comment = commentValue;
    commentObj.userId = authService.currentUser.value.id;
    commentObj.accessToken = authService.currentUser.value.accessToken;
    commentObj.userDp = authService.currentUser.value.userDP;
    commentObj.username = authService.currentUser.value.username;
    commentObj.time = 'now';
    commentValue = '';
    try {
      var response = await CommonHelper.sendRequestToServer(
          endPoint: 'add-comment',
          requestData: {
            "video_id": commentObj.videoId.toString(),
            "comment": commentObj.comment.toString()
          },
          method: "post");
      int commentId = json.decode(response.body)['comment_id'];
      commentObj.commentId = commentId;
      postService.commentsObj.value.comments.insert(0, commentObj);
      postService.commentsObj.refresh();
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
      DashboardController dashboardController = Get.find();
      dashboardController.videoObj.value.totalComments++;
      dashboardController.videoObj.refresh();
    } catch (e, s) {
      print("AddComment Issue $e $s");
      print(e.toString());
      Fluttertoast.showToast(msg: "There's some issue with the server");
    }
  }

  Future<void> onEditComment(index, context) async {
    print(
        "postService.commentsObj.value.comments[index].comment ${postService.commentsObj.value.comments[index].comment} $index");
    FocusScope.of(context).requestFocus(inputNode);
    commentController.value = new TextEditingController(
        text: postService.commentsObj.value.comments[index].comment);
    editedComment.value = index.toString();
    editedComment.refresh();
  }

  Future<void> editComment(index, videoId, context) async {
    FocusScope.of(context).unfocus();
    commentController.value = new TextEditingController(text: "");
    commentObj = new CommentData();
    commentObj.commentId =
        postService.commentsObj.value.comments[int.parse(index)].commentId;
    commentObj.videoId = videoId;
    commentObj.comment = commentValue;
    commentObj.userId = authService.currentUser.value.id;
    commentObj.accessToken = authService.currentUser.value.accessToken;
    commentObj.userDp = authService.currentUser.value.userDP;
    commentObj.username = authService.currentUser.value.username;
    commentObj.time =
        postService.commentsObj.value.comments[int.parse(index)].time;
    commentValue = '';
    try {
      // var response = await CommonHelper.sendRequestToServer(endPoint: 'edit-comment', method: "post", requestData: {
      await CommonHelper.sendRequestToServer(
          endPoint: 'edit-comment',
          method: "post",
          requestData: {
            "user_id": commentObj.userId.toString(),
            "comment_id": commentObj.commentId.toString(),
            "video_id": commentObj.videoId.toString(),
            "comment": commentObj.comment.toString(),
          });
      editedComment.value = "";
      editedComment.refresh();
      postService.commentsObj.value.comments[int.parse(index)] = commentObj;
      postService.commentsObj.refresh();
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.refresh();
    } catch (e) {
      print("error $e");
    }

    /*catchError((e) {
      context.showSnackBar(SnackBar(
        content: Text("There's some issue with the server"),
      ));
    });*/
  }

  /*Future<void> initController(int index) async {
    try {
      var controller = await getControllerForVideo(dashboardService.videosData.value.videos.elementAt(index).url);
      videoControllers[dashboardService.videosData.value.videos.elementAt(index).url] = controller;
      // initializeVideoPlayerFutures[dashboardService.videosData.value.videos.elementAt(index).url] = controller.initialize().onError((error, stackTrace) => print("Init Error: $error"));
      initializeVideoPlayerFutures[dashboardService.videosData.value.videos.elementAt(index).url] = controller.initialize();
      controller.setLooping(true);
    } on PlatformException catch (e) {
      print("Init Catch Error: $e");
    }
  }*/

  void playOrPauseVideo() {
    if (dashboardService.currentVideoPlayer.value.dataSource != "" &&
        dashboardService.currentVideoPlayer.value.value.isPlaying) {
      try {
        print("stopController isInitialized $index");
        print(dashboardService.currentVideoPlayer.value.value.isInitialized);
        if (dashboardService.currentVideoPlayer.value.dataSource != "")
          dashboardService.currentVideoPlayer.value.pause();
        print("paused $index");
      } catch (e, s) {
        print("Error pausing stopController $index $e $s");
      }
    } else {
      try {
        print("playController isInitialized $index");
        print(dashboardService.currentVideoPlayer.value.value.isInitialized);
        if (dashboardService.currentVideoPlayer.value.dataSource != "")
          dashboardService.currentVideoPlayer.value.play();
        print("played $index");
      } catch (e, s) {
        print("Error playing stopController $index $e $s");
      }
    }
  }

  void stopController(int index) {}

  void playController(int index) async {
    if (mainService.isOnHomePage.value) {
      print(index);
      try {
        print("playController isInitialized $index");
        print(dashboardService.currentVideoPlayer.value.value.isInitialized);
        if (dashboardService.currentVideoPlayer.value.dataSource != "")
          dashboardService.currentVideoPlayer.value.play();
      } catch (e) {
        print("Error playing playController $index $e");
      }
    }
  }

  Future<void> preCacheVideoThumbs() {
    for (final e in dashboardService.videosData.value.videos) {
      Video video = e;
      try {
        CustomCacheManager.instance.downloadFile(video.videoThumbnail);
      } on HttpException catch (e) {
        print("Cache preCacheVideos Errors $e");
      }
    }
    return Future.value();
  }

  Future<void> followUnfollowUser() async {
    showFollowLoader.value = true;
    showFollowLoader.refresh();
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(
        endPoint: 'follow-unfollow-user',
        requestData: {
          "follow_to": videoObj.value.userId.toString(),
        },
        method: "post",
      );

      showFollowLoader.value = false;
      showFollowLoader.refresh();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          videoObj.value.isFollowing = data['followText'] == 'Follow' ? 0 : 1;
          loadMoreUpdateView.value = true;
          loadMoreUpdateView.refresh();
          for (var item in dashboardService.videosData.value.videos) {
            if (videoObj.value.userId == item.userId) {
              if (videoObj.value.isFollowing == 1) {
                item.totalFollowers++;
              } else {
                item.totalFollowers--;
              }
            }
            if (videoObj.value.videoId != item.videoId) {
              item.isFollowing = data['followText'] == 'Follow' ? 0 : 1;
            }
          }
          dashboardService.videosData.value
              .videos[dashboardService.pageIndex.value] = videoObj.value;
          dashboardService.videosData.refresh();
          videoObj.refresh();
          UserController userController = Get.find();
          userController.getMyProfile(false);
        }
      } else {}
    } catch (e) {
      showFollowLoader.value = false;
      showFollowLoader.refresh();
    }
  }

  incrementVideoViews(Video videoObj) async {
    String userVideoId = authService.currentUser.value.id != 0
        ? authService.currentUser.value.id.toString()
        : "";
    String userVideo = videoObj.videoId.toString() + userVideoId;
    if (!dashboardService.watchedVideos.contains(userVideo)) {
      dashboardService.watchedVideos.add(userVideo);
      dashboardService.watchedVideos.refresh();
      String uniqueToken = GetStorage().read("unique_id")!;
      Map<String, dynamic> data = {};
      data["unique_token"] = uniqueToken;
      data["video_id"] = videoObj.videoId.toString();
      final response = await CommonHelper.sendRequestToServer(
          endPoint: 'video-views', requestData: data, method: "post");
      if (response.statusCode == 200) {
        dashboardService.videosData.value.videos
            .elementAt(dashboardService.pageIndex.value)
            .totalViews = json.decode(response.body)['total_views'];
        dashboardService.videosData.refresh();
      } else {
        throw new Exception(response.body);
      }
    }
  }

  Future<void> onLinkTap(String text) async {
    print("onTaptext $text");
    if (text.contains("#")) {
      EasyLoading.show(status: "Loading".tr + "...");
      SearchService searchService = Get.find();
      searchService.currentHashTag.value.tag = text.replaceAll("#", "");
      mainService.isOnHomePage.value = false;
      mainService.isOnHomePage.refresh();
      stopController(dashboardService.pageIndex.value);
      dashboardService.postIds = [];
      SearchViewController searchController = Get.find();
      await searchController.getHashTagPageData();
      EasyLoading.dismiss();
      searchService.navigatedToHashVideoPage.value = true;
      Get.offNamed('/hash-tag');
    } else if (text.contains("@")) {
      SearchService searchService = Get.find();
      searchService.searchUsername.value = text.replaceAll("@", "");
      mainService.isOnHomePage.value = false;
      mainService.isOnHomePage.refresh();
      UserController userCon = Get.find();
      userCon.openUserProfile(searchService.searchUsername.value);
    }
  }

  void updateEULA() async {
    var value = false;
    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'update-eula-agree',
        method: "post",
        requestData: {"data_var": "data"});
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        value = true;
      } else {
        value = false;
      }
    } else {
      value = false;
    }

    print("userApi.agreeEula() value $value");
    if (value) {
      Get.offNamed('/home');
    }
  }
}
