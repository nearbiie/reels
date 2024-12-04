import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../core.dart';

class SearchViewController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> hashScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  PanelController pc = new PanelController();
  ScrollController scrollController = new ScrollController();
  ScrollController hashScrollController = new ScrollController();
  ScrollController videoScrollController = new ScrollController();
  ScrollController userScrollController = new ScrollController();
  var showLoader = false.obs;
  bool showLoadMore = true;
  bool showLoadMoreHashTags = true;
  bool showLoadMoreUsers = true;
  bool showLoadMoreVideos = true;
  String searchKeyword = '';
  DashboardController dashboardController = Get.find();
  SearchService searchService = Get.find();
  var searchController = TextEditingController();

  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  int hashesPage = 2;
  int videosPage = 2;
  int usersPage = 2;
  var showBannerAd = false.obs;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? myRewarded;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  bool isCurrentlyLoadingHashPageData = false;

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  MainService mainService = Get.find();

  var page = 1;

  var hashTagScrollController;

  @override
  void onInit() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    hashScaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    super.onInit();
  }

  getAds() {
    appId = Platform.isAndroid ? mainService.adsData['android_app_id'] : mainService.adsData['ios_app_id'];
    bannerUnitId = Platform.isAndroid ? mainService.adsData['android_banner_app_id'] : mainService.adsData['ios_banner_app_id'];
    screenUnitId = Platform.isAndroid ? mainService.adsData['android_interstitial_app_id'] : mainService.adsData['ios_interstitial_app_id'];
    videoUnitId = Platform.isAndroid ? mainService.adsData['android_video_app_id'] : mainService.adsData['ios_video_app_id'];
    bannerShowOn = mainService.adsData['banner_show_on'];
    interstitialShowOn = mainService.adsData['interstitial_show_on'];
    videoShowOn = mainService.adsData['video_show_on'];
    if (appId != "") {
      MobileAds.instance.initialize().then((value) async {
        if (bannerShowOn.indexOf("3") > -1) {
          showBannerAd.value = true;
          showBannerAd.refresh();
        }
        if (interstitialShowOn.indexOf("3") > -1) {
          createInterstitialAd(screenUnitId);
        }
        if (videoShowOn.indexOf("3") > -1) {
          await createRewardedAd(videoUnitId);
        }
      });
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
    Future<void>.delayed(Duration(seconds: 3), () => _showInterstitialAd(adUnitId));
  }

  void _showInterstitialAd(adUnitId) {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
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
    print("createRewardedAd");
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

    Future<void>.delayed(Duration(seconds: 10), () => _showRewardedAd(adUnitId));
  }

  void _showRewardedAd(adUnitId) {
    if (myRewarded == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    myRewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => print('ad onAdShowedFullScreenContent.'),
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

  Future getData() async {
    EasyLoading.show(status: "Loading".tr + "...");
    print("searchService.currentHashTag.value.tag ${searchService.currentHashTag.value.tag}");
    mainService.userVideoObj.value.userId = 0;
    mainService.userVideoObj.value.videoId = 0;
    mainService.userVideoObj.refresh();
    showLoadMoreHashTags = true;
    showLoadMoreUsers = true;
    showLoadMoreVideos = true;
    hashesPage = 2;
    usersPage = 2;
    videosPage = 2;
    showLoader.value = true;
    scrollController = new ScrollController();
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'hash-tag-videos', method: "post", requestData: {
        'user_id': "0",
        'page': page.toString(),
        'search': searchKeyword,
        'hashtag': "",
      });

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            searchService.searchPageData.value.videos.addAll(HashVideosModel.fromJSON(json.decode(response.body)['data']).videos);
          } else {
            searchService.searchPageData.value = HashVideosModel.fromJSON(json.decode(response.body)['data']);
          }
          EasyLoading.dismiss();
          searchService.searchPageData.refresh();
          showLoader.value = false;
          showLoader.refresh();
          if (searchService.searchPageData.value.videos.length == searchService.searchPageData.value.totalRecords) {
            showLoadMore = false;
          }

          scrollController.addListener(() {
            print("scrollController.addListener ${scrollController.position.pixels} ${scrollController.position.maxScrollExtent}");
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              if (searchService.searchPageData.value.videos.length != searchService.searchPageData.value.totalRecords && showLoadMore) {
                page = page + 1;
                getData();
              }
            }
          });
        }
      } else {
        print("searchService.searchPageData.valueError1");
      }
    } catch (e, s) {
      print("searchService.searchPageData.valueError");
      print(e.toString());
      print(s);
      HashVideosModel.fromJSON({});
    }
  }

  Future getHashTagPageData() async {
    EasyLoading.show(status: "Loading".tr + "...");
    print("searchService.currentHashTag.value.tag ${searchService.currentHashTag.value.tag}");
    mainService.userVideoObj.value.userId = 0;
    mainService.userVideoObj.value.videoId = 0;
    mainService.userVideoObj.refresh();
    showLoadMoreHashTags = true;
    showLoadMoreUsers = true;
    showLoadMoreVideos = true;
    hashesPage = 2;
    usersPage = 2;
    videosPage = 2;
    showLoader.value = true;
    scrollController = new ScrollController();
    try {
      if (!isCurrentlyLoadingHashPageData) {
        isCurrentlyLoadingHashPageData = true;
        var response = await CommonHelper.sendRequestToServer(endPoint: 'hash-tag-videos', method: "post", requestData: {
          'user_id': "0",
          'page': page.toString(),
          'search': searchKeyword,
          'hashtag': searchService.currentHashTag.value.tag.replaceAll("#", ""),
        });
        isCurrentlyLoadingHashPageData = false;
        showLoader.value = false;
        showLoader.refresh();
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            if (page > 1) {
              scrollController = new ScrollController();
              searchService.hashVideoData.value.videos.addAll(HashVideosModel.fromJSON(json.decode(response.body)['data']).videos);
            } else {
              searchService.hashVideoData.value = HashVideosModel.fromJSON(json.decode(response.body)['data']);
            }
            print("searchService.hashVideoData.value ${searchService.hashVideoData.value.videos.length}");

            sleep(Duration(seconds: 1));
            EasyLoading.dismiss();
            searchService.hashVideoData.refresh();

            showLoader.value = false;
            showLoader.refresh();
            if (searchService.hashVideoData.value.videos.length == searchService.hashVideoData.value.totalRecords) {
              showLoadMore = false;
            }
            scrollController.addListener(() {
              if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                if (searchService.hashVideoData.value.videos.length != searchService.hashVideoData.value.totalRecords && showLoadMore) {
                  page = page + 1;
                  getData();
                }
              }
            });
          }
        } else {
          print("searchService.hashData.valueError1");
        }
      }
    } catch (e, s) {
      print("searchService.hashData.valueError");
      print(e.toString());
      print(s);
      EasyLoading.dismiss();
      HashVideosModel.fromJSON({});
    }
  }

  Future getHashData(page, hash) async {
    mainService.userVideoObj.value.userId = 0;
    mainService.userVideoObj.value.videoId = 0;
    mainService.userVideoObj.refresh();
    dashboardController.refresh();
    showLoader.value = true;
    showLoader.refresh();
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'hash-videos', requestData: {'page': page.toString(), 'hash': hash});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            hashScrollController = new ScrollController();
            searchService.searchPageData.value.videos.addAll(HashVideosModel.fromJSON(json.decode(response.body)['data']).videos);
          } else {
            searchService.searchPageData.value = HashVideosModel.fromJSON(json.decode(response.body)['data']);
          }
          searchService.searchPageData.refresh();
          showLoader.value = false;
          showLoader.refresh();
          if (searchService.searchPageData.value.videos.length == searchService.searchPageData.value.totalRecords) {
            showLoadMore = false;
          }
          hashTagScrollController.addListener(() {
            if (hashTagScrollController.position.pixels == hashTagScrollController.position.maxScrollExtent) {
              if (searchService.searchPageData.value.videos.length != searchService.searchPageData.value.totalRecords && showLoadMore) {
                page = page + 1;
                getHashData(page, hash);
              }
            }
          });
        } else {
          return HashVideosModel.fromJSON({});
        }
      } else {
        return HashVideosModel.fromJSON({});
      }
    } catch (e) {
      print(e.toString());
      return HashVideosModel.fromJSON({});
    }
  }

  Future getHashesData(searchKeyword) async {
    if (showLoadMoreHashTags) {
      mainService.userVideoObj.value.userId = 0;
      mainService.userVideoObj.value.videoId = 0;
      mainService.userVideoObj.value.hashTag = "";
      mainService.userVideoObj.refresh();

      showLoader.value = true;
      showLoader.refresh();
      hashScrollController = new ScrollController();
      try {
        var response = await CommonHelper.sendRequestToServer(endPoint: 'tag-search', requestData: {'page': hashesPage.toString(), 'search': searchKeyword});

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            if (hashesPage > 1) {
              searchService.searchData.value.hashTags.addAll(SearchModel.fromJSON(json.decode(response.body)).hashTags);
            } else {
              searchService.searchData.value = SearchModel.fromJSON(json.decode(response.body)['data']);
            }
            searchService.searchData.refresh();
            showLoader.value = false;
            showLoader.refresh();
            if (searchService.searchData.value.hashTags.length == 0) {
              showLoadMoreHashTags = false;
            }
          } else {
            return [];
          }
        } else {
          return [];
        }
      } catch (e) {
        print(e.toString());
        return [];
      }
    }
  }

  Future getUsersData(searchKeyword) async {
    if (showLoadMoreHashTags) {
      mainService.userVideoObj.value.userId = 0;
      mainService.userVideoObj.value.videoId = 0;
      mainService.userVideoObj.value.hashTag = "";
      mainService.userVideoObj.refresh();
      showLoader.value = true;
      showLoader.refresh();
      userScrollController = new ScrollController();
      try {
        var response = await CommonHelper.sendRequestToServer(endPoint: 'user-search', requestData: {'page': usersPage.toString(), 'search': searchKeyword});

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            if (usersPage > 1) {
              searchService.searchData.value.users.addAll(SearchModel.fromJSON(json.decode(response.body)).users);
            } else {
              searchService.searchData.value = SearchModel.fromJSON(json.decode(response.body)['data']);
            }
            searchService.searchData.refresh();

            showLoader.value = false;
            showLoader.refresh();
            if (searchService.searchData.value.users.length == 0) {
              showLoadMoreUsers = false;
            }
          } else {
            return [];
          }
        } else {
          return [];
        }
      } catch (e) {
        print(e.toString());

        return [];
      }
    }
  }

  Future getVideosData(searchKeyword) async {
    if (showLoadMoreVideos) {
      mainService.userVideoObj.value.userId = 0;
      mainService.userVideoObj.value.videoId = 0;
      mainService.userVideoObj.value.hashTag = "";
      mainService.userVideoObj.refresh();
      showLoader.value = true;
      showLoader.refresh();
      videoScrollController = new ScrollController();
      try {
        var response = await CommonHelper.sendRequestToServer(endPoint: 'video-search', requestData: {'page': videosPage.toString(), 'search': searchKeyword});

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            if (videosPage > 1) {
              searchService.searchData.value.videos.addAll(SearchModel.fromJSON(json.decode(response.body)).videos);
            } else {
              searchService.searchData.value = SearchModel.fromJSON(json.decode(response.body)['data']);
            }
            searchService.searchData.refresh();
            showLoader.value = false;
            showLoader.refresh();
            if (searchService.searchData.value.videos.length > 0) {
              showLoadMoreVideos = false;
            }
          } else {
            return [];
          }
        } else {
          return [];
        }
      } catch (e) {
        print(e.toString());

        return [];
      }
    }
  }

  Future getSearchData(page) async {
    mainService.userVideoObj.value.userId = 0;
    mainService.userVideoObj.value.videoId = 0;
    mainService.userVideoObj.value.hashTag = "";
    mainService.userVideoObj.refresh();

    showLoader.value = true;
    showLoader.refresh();
    scrollController = new ScrollController();
    // try {
    var response = await CommonHelper.sendRequestToServer(endPoint: 'search', requestData: {'page': page.toString(), 'search': searchKeyword});

    print("getSearchData ${response.body}");
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        searchService.searchData.value = SearchModel.fromJSON(json.decode(response.body));
        searchService.searchData.refresh();
        print("${searchService.searchData.value.users.length} ${searchService.searchData.value.hashTags.length} ${searchService.searchData.value.videos.length}");

        showLoader.value = false;
        showLoader.refresh();
        if (searchService.searchData.value.hashTags.length < 10) {
          // setState(() {
          showLoadMoreHashTags = false;
          // });
        } else {
          hashScrollController = new ScrollController();
          hashScrollController.addListener(() {
            if (hashScrollController.position.pixels >= hashScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreHashTags) {
                getHashesData(searchKeyword);
                // setState(() {
                hashesPage++;
                // });
              }
            }
          });
        }
        if (searchService.searchData.value.users.length < 10) {
          // setState(() {
          showLoadMoreUsers = false;
          // });
        } else {
          userScrollController = new ScrollController();
          userScrollController.addListener(() {
            if (userScrollController.position.pixels >= userScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreUsers) {
                getUsersData(searchKeyword);
                // setState(() {
                usersPage++;
                // });
              }
            }
          });
        }
        if (searchService.searchData.value.videos.length < 10) {
          // setState(() {
          showLoadMoreVideos = false;
          // });
        } else {
          videoScrollController = new ScrollController();
          videoScrollController.addListener(() {
            if (videoScrollController.position.pixels >= videoScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreVideos) {
                getVideosData(searchKeyword);
                // setState(() {
                videosPage++;
                // });
              }
            }
          });
        }
      } else {
        return SearchModel.fromJSON({});
      }
    } else {
      return SearchModel.fromJSON({});
    }
  }
}
