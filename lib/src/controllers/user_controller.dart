import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as HTTP;
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';

class UserController extends GetxController {
  AuthService authService = Get.find();
  UserService userService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  List<Video> users = <Video>[];
  GlobalKey<ScaffoldState> userScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> completeProfileScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> forgotPasswordScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> resetForgotPasswordScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> editVideoScaffoldKey = GlobalKey<ScaffoldState>();
  var hidePassword = true.obs;
  var keyboardVisible = false.obs;
  ValueNotifier<bool> updateViewState = new ValueNotifier(false);
  var userIdValue = 0.obs;
  GlobalKey<FormState> formKey = new GlobalKey();
  GlobalKey<FormState> otpFormKey = new GlobalKey();
  GlobalKey<FormState> loginFormKey = new GlobalKey(debugLabel: "login");
  GlobalKey<FormState> registerFormKey = new GlobalKey(debugLabel: "register");
  GlobalKey<FormState> completeProfileFormKey = new GlobalKey(debugLabel: "completeProfile");
  GlobalKey<FormState> resetForgotPassword = new GlobalKey(debugLabel: "resetForgotPassword");
  GlobalKey<FormState> editVideoFormKey = new GlobalKey(debugLabel: "editVideoForm");
  var showBannerAd = false.obs;
  Map userProfile = {};
  OverlayEntry loader = new OverlayEntry(builder: (context) {
    return Container();
  });
  DashboardController homeCon = DashboardController();
  String timezone = 'Unknown';
  bool showUserLoader = false;
  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  int page = 1;

  var followUserId = 0.obs;
  String searchKeyword = '';
  bool showLoadMoreUsers = true;
  String largeProfilePic = '';
  String smallProfilePic = '';
  User completeProfile = User();
  int curIndex = 0;
  String otp = "";
  var showLoader = false.obs;
  var videosLoader = false.obs;
  bool showLoadMore = true;
  var searchController = TextEditingController();
  bool followUnfollowLoader = false;
  String followText = "Follow";
  var countTimer = 60.obs;
  var bHideTimer = false.obs;
  var reload = false.obs;
  String iosUuId = "";
  String iosEmail = "";
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
  var fullName = "".obs;
  String username = "";
  var email = "".obs;
  String password = "";
  String confirmPassword = "";
  PanelController pc = new PanelController();
  var fullNameController = TextEditingController().obs;
  TextEditingController emailController = TextEditingController();
  // var emailController = TextEditingController().obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController profileUsernameController = TextEditingController();
  var profileEmailController = TextEditingController().obs;
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController conDob = new TextEditingController();
  TextEditingController otpController = new TextEditingController();

  String uniqueId = "";

  var showSendOtp = false.obs;
  ScrollController scrollController = new ScrollController();
  String profileUsername = '';
  DateTime profileDOB = DateTime.now();
  String profileDOBString = '';
  final picker = ImagePicker();
  var selectedDp = File("").obs;
  String loginType = '';
  var gender = <Gender>[const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')].obs;
  var selectedGender = "".obs;
  bool visibleSocialButtons = true;
  GlobalKey<ScaffoldState> myProfileScaffoldKey = GlobalKey<ScaffoldState>();
  String description = "";
  int privacy = 0;
  String deleteProfileOtp = "";
  StreamController<ErrorAnimationType> otpErrorController = StreamController<ErrorAnimationType>();
  var isValidEmail = false.obs;
  bool noLiveUserRecord = true;

  var activeTab = 1.obs;

  @override
  void onInit() {
    userScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_loginPage');
    otpScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_otpPage');
    completeProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_completeProfilePage');
    forgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_ForgotPasswordPage');
    resetForgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_resetForgotPasswordScaffoldPage');
    myProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_myProfileScaffoldPage');
    editVideoScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editVideoScaffoldPage');
    scrollController = new ScrollController();
    initPlatformState();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String validDob(String year, String month, String day) {
    if (day.length == 1) {
      day = "0" + day;
    }
    if (month.length == 1) {
      month = "0" + month;
    }
    return year + "-" + month + "-" + day;
  }

  Future<void> initPlatformState() async {
    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }

    timezone = timezone;
  }

  @override
  dispose() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    super.dispose();
  }

  /*Future<void> getAds() async {
    appId = Platform.isAndroid ? mainService.adsData.value['android_app_id'] : mainService.adsData.value['ios_app_id'];
    bannerUnitId = Platform.isAndroid ? mainService.adsData.value['android_banner_app_id'] : mainService.adsData.value['ios_banner_app_id'];
    screenUnitId = Platform.isAndroid ? mainService.adsData.value['android_interstitial_app_id'] : mainService.adsData.value['ios_interstitial_app_id'];
    videoUnitId = Platform.isAndroid ? mainService.adsData.value['android_video_app_id'] : mainService.adsData.value['ios_video_app_id'];
    bannerShowOn = mainService.adsData.value['banner_show_on'];
    interstitialShowOn = mainService.adsData.value['interstitial_show_on'];
    videoShowOn = mainService.adsData.value['video_show_on'];

    if (appId != "") {
      MobileAds.instance.initialize().then((value) async {
        if (bannerShowOn.indexOf("2") > -1) {
          showBannerAd.value = true;
          showBannerAd.refresh();
        }

        if (interstitialShowOn.indexOf("2") > -1) {
          createInterstitialAd(screenUnitId);
        }

        if (videoShowOn.indexOf("2") > -1) {
          await createRewardedAd(videoUnitId);
        }
      });
    }
  }*/

  createInterstitialAd(adUnitId) {
    print("createInterstitialAd");
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
    print("createRewardedAd $adUnitId");
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

  getUuId() async {
    iosUuId = GetStorage().read("ios_uuid") == null ? "" : GetStorage().read("ios_uuid").toString();
    iosEmail = GetStorage().read("ios_email") == null ? "" : GetStorage().read("ios_email").toString();

    print("iosUuId $iosUuId");
    print("iosEmail $iosEmail");
  }

  socialLogin(userProfile, timezone, type) async {
    var profile = LoginData().toSocialLoginMap(userProfile, timezone, type);
    var response = await CommonHelper.sendRequestToServer(endPoint: 'register-social', requestData: profile, method: "post");
    if (type == "FB" && profile["email"] == "") {
      authService.errorString.value = "Your facebook profile does not provide email address. Please try with another method";
      authService.errorString.refresh();
      return false;
    }

    if (response.statusCode == 200) {
      print("SSSSSSSS");
      print(response.body);
      await setCurrentUser(response.body);
      return true;
    } else {
      return false;
      // throw new Exception(response.body);
    }
  }

  signInWithApple() async {
    showLoader.value = true;

    EasyLoading.show(status: "Please wait".tr + "...");

    showLoader.refresh();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId: 'com.leuke.applogin',
          redirectUri: Uri.parse(
            'https://smiling-abrupt-screw.glitch.me/callbacks/sign_in_with_apple',
          ),
        ),
      );

      var firstName = credential.givenName;
      var lastName = credential.familyName;
      var email = credential.email;
      var userDp = "";
      var gender = "";
      var dob = "";
      var mobile = "";
      var country = "";
      if (iosUuId == "") {
        if (Platform.isIOS) {
          String uuid;
          // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          uuid = credential.userIdentifier!; //UUID for iOS
          print("uuid $uuid");
          final Map<String, String> userInfo = {
            'first_name': firstName != null ? firstName : "",
            'last_name': lastName != null ? lastName : "",
            'email': email != null ? email : "",
            'mobile': mobile,
            'gender': gender,
            'user_dp': userDp,
            'dob': dob,
            'country': country,
            'languages': "",
            'player_id': "",
            'time_zone': timezone,
            'login_type': "A",
            'ios_email': email != null ? email : "",
            'ios_uuid': uuid,
          };

          socialLogin(
            userInfo,
            timezone,
            'A',
          ).then((value) {
            if (value) {
              EasyLoading.dismiss();
              CommonHelper.hideLoader(loader);
              dashboardService.showFollowingPage.value = false;
              dashboardService.showFollowingPage.refresh();
              Get.offNamed('/home');
              dashboardController.getVideos();
            } else {
              if (authService.errorString.value != "") {
                CommonHelper.hideLoader(loader);

                EasyLoading.dismiss();
                ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(authService.errorString.value)));
              }
            }
          }).catchError((e) {
            print(e.toString());
            CommonHelper.hideLoader(loader);
            EasyLoading.dismiss();
            ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Sign In with Apple failed!')));
          });
        }
      } else {
        final Map<String, String> userInfo = {
          'first_name': firstName != null ? firstName : "",
          'last_name': lastName != null ? lastName : "",
          'email': email != null ? email : "",
          'mobile': mobile,
          'gender': gender,
          'user_dp': userDp,
          'dob': dob,
          'country': country,
          'languages': "",
          'player_id': "",
          'time_zone': timezone,
          'login_type': "A",
          'ios_uuid': iosUuId,
          'ios_email': iosEmail,
        };
        socialLogin(
          userInfo,
          timezone,
          'A',
        ).then((value) {
          print("socialLogin $value");
          if (value) {
            EasyLoading.dismiss();
            CommonHelper.hideLoader(loader);
            dashboardService.showFollowingPage.value = false;
            dashboardService.showFollowingPage.refresh();
            Get.offNamed('/home');
            dashboardController.getVideos();
          } else {
            if (authService.errorString.value != "") {
              EasyLoading.dismiss();
              CommonHelper.hideLoader(loader);
              ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                content: Text(authService.errorString.value),
              ));
            }
          }
        }).catchError((e) {
          CommonHelper.hideLoader(loader);

          EasyLoading.dismiss();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                'Sign In with Apple failed!',
              ),
            ),
          );
        });
      }

      EasyLoading.dismiss();
      showLoader.value = false;
      showLoader.refresh();
    } catch (e) {
      EasyLoading.dismiss();
      showLoader.value = false;
      showLoader.refresh();
      if (e.toString().contains("Unsupported platform")) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          CommonHelper.toast("Unsupported platform iOS version. Please try some other login method.", Colors.redAccent),
        );
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          CommonHelper.toast(
            e.toString() + " Please try Again with some other method.",
            Colors.redAccent,
          ),
        );
      }
    }
  }

  loginWithFB() async {
    final LoginResult fBResult = await FacebookAuth.instance.login();
    switch (fBResult.status) {
      case LoginStatus.success:
        final AccessToken accessToken = fBResult.accessToken!;
        // OverlayEntry loader =CommonHelper.overlayLoader(Get.context);
        // Overlay.of(Get.context).insert(loader);
        final graphResponse = await HTTP.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,email,first_name,last_name,picture.width(720).height(720),birthday,gender,languages,location{location}&access_token=${accessToken.token}'));
        final profile = jsonDecode(graphResponse.body);
        socialLogin(profile, timezone, 'FB').then((value) async {
          if (value != null) {
            if (value) {
              CommonHelper.hideLoader(loader);
              dashboardService.showFollowingPage.value = false;
              dashboardService.showFollowingPage.refresh();
              Get.offNamed('/home');
              dashboardController.getVideos();
            } else {
              if (authService.errorString.value != "") {
                CommonHelper.hideLoader(loader);
                Fluttertoast.showToast(msg: authService.errorString.value);
              }
            }
          }
          EasyLoading.dismiss();
        }).catchError((e, s) {
          print(e);
          print(s);
          CommonHelper.hideLoader(loader);
          EasyLoading.dismiss();
          Fluttertoast.showToast(msg: "Facebook login failed!");
        });
        break;
      case LoginStatus.cancelled:
        Fluttertoast.showToast(msg: "Facebook login Cancelled!");
        EasyLoading.dismiss();
        break;
      case LoginStatus.failed:
        Fluttertoast.showToast(msg: "Facebook login failed!");
        EasyLoading.dismiss();
        break;
      case LoginStatus.operationInProgress:
        EasyLoading.show(status: "Loading".tr + ".." + "Please Wait".tr);
        break;
    }
  }

  loginWithGoogle() async {
    await authService.googleSignIn.signIn();
    // OverlayEntry loader =CommonHelper.overlayLoader(Get.context!);
    // Overlay.of(Get.context!)!.insert(loader);

    if (authService.googleSignIn.currentUser != null) {
      EasyLoading.show(status: "Please wait".tr + "...");
      await getGoogleInfo(authService.googleSignIn).then((profile) {
        socialLogin(profile, timezone, 'G').then((value) {
          if (value != null) {
            if (value) {
              EasyLoading.dismiss();
              CommonHelper.hideLoader(loader);
              dashboardService.showFollowingPage.value = false;
              dashboardService.showFollowingPage.refresh();
              Get.offNamed('/home');
              dashboardController.getVideos();
            } else {
              EasyLoading.dismiss();
              CommonHelper.hideLoader(loader);
              if (authService.errorString.value != "") {
                CommonHelper.hideLoader(loader);
                Fluttertoast.showToast(msg: authService.errorString.value);
              }
            }
          }
        }).catchError((e) {
          EasyLoading.dismiss();
          CommonHelper.hideLoader(loader);
          Fluttertoast.showToast(msg: "Google login failed!");
        });
      });
    } else {
      EasyLoading.dismiss();
      CommonHelper.hideLoader(loader);
    }
  }

  Future getGoogleInfo(googleSignIn) async {
    List name = googleSignIn.currentUser.displayName.split(' ');
    String fname = name[0];
    String lname = "";
    if (name.length > 1) {
      name.removeAt(0);
      lname = name.join(' ');
    }
    final Map<String, String> userInfo = {
      'first_name': fname,
      'last_name': lname,
      'email': googleSignIn.currentUser.email,
      'user_dp': googleSignIn.currentUser.photoUrl != null ? googleSignIn.currentUser.photoUrl.replaceAll('=s96-c', '=s512-c') : "",
      'time_zone': timezone,
      'login_type': "G",
    };
    return userInfo;
  }

  Future getUsers(page) async {
    EasyLoading.show(
      status: "loading..",
      maskType: EasyLoadingMaskType.black,
    );
    scrollController1 = new ScrollController();

    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'most-viewed-video-users', requestData: {'page': page.toString(), 'search': searchKeyword}, method: "post");

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            userService.usersData.value.videos.addAll(VideoModel.fromJSON(json.decode(response.body)['data']).videos);
          } else {
            userService.usersData.value = VideoModel.fromJSON(json.decode(response.body)['data']);
          }
          userService.usersData.refresh();
          EasyLoading.dismiss();
          if (userService.usersData.value.videos.length == userService.usersData.value.totalVideos) {
            showLoadMore = false;
          }
          scrollController1.addListener(() {
            if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
              if (userService.usersData.value.videos.length != userService.usersData.value.totalVideos && showLoadMore) {
                page = page + 1;
                getUsers(page);
              }
            }
          });
        } else {
          EasyLoading.dismiss();
          return VideoModel.fromJSON({});
        }
      } else {
        EasyLoading.dismiss();
        return VideoModel.fromJSON({});
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e.toString());
      return VideoModel.fromJSON({});
    }
  }

  Future<void> followUnfollowUser(userId, index) async {
    EasyLoading.show(status: "Loading...");

    followUserId.value = userId;
    followUserId.refresh();
    showLoader.value = true;
    showLoader.refresh();
    var value =
        await CommonHelper.sendRequestToServer(endPoint: 'follow-unfollow-user', method: "post", requestData: {"follow_to": userId.toString(), "app_token": authService.currentUser.value.accessToken});
    followUserId.value = 0;
    followUserId.refresh();
    EasyLoading.dismiss();

    print("followUnfollowUser value.body ${value.body}");
    if (value.statusCode == 200) {
      print("followUnfollowUser value.body ${value.body}");
      print(json.encode(json.decode(value.body)));
      showLoader.value = false;
      showLoader.refresh();
      var response = json.decode(value.body);
      if (response['status'] == 'success') {
        // followCon.friendsList(1);
        userService.usersData.value.videos.elementAt(index).followText = response['followText'];
        userService.usersData.refresh();
      } else {
        showLoader.value = false;
        showLoader.refresh();
        Fluttertoast.showToast(msg: "There is some error");
      }
    } else {
      showLoader.value = false;
      showLoader.refresh();
      Fluttertoast.showToast(msg: "There is some error");
    }
  }

  Future<void> followUnfollowUserFromUserProfile(userId) async {
    // setState(() {});
    followUnfollowLoader = true;
    var value =
        await CommonHelper.sendRequestToServer(endPoint: 'follow-unfollow-user', method: "post", requestData: {"follow_to": userId.toString(), "app_token": authService.currentUser.value.accessToken});

    if (value.statusCode == 200) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      print(response);
      if (response['status'] == 'success') {
        for (var item in dashboardService.videosData.value.videos) {
          if (userId == item.userId) {
            item.isFollowing = response['followText'] == 'Follow' ? 0 : 1;
          }
        }
        userService.userProfile.value.followText = response['followText'];
        userService.userProfile.value.totalFollowers = response['totalFollowers'].toString();
        userService.userProfile.refresh();
      } else {
        showLoader.value = false;
        showLoader.refresh();
        Fluttertoast.showToast(msg: "There is some error");
      }
    } else {
      showLoader.value = false;
      showLoader.refresh();
      Fluttertoast.showToast(msg: "There is some error");
    }
  }

  Future<String> getUsersProfile(page) async {
    print("getUsersProfile page $page");
    if (page == 1) {
      userService.userProfile.value = User();
      scrollController1 = new ScrollController();
      showLoader.value = true;
      showLoader.refresh();
    }
    bool stillFetching = true;
    try {
      EasyLoading.show(status: "Loading...");
      SearchService searchService = Get.find();
      var response = await CommonHelper.sendRequestToServer(
        endPoint: 'fetch-user-info',
        requestData: {
          "user_id": userService.userId.value.toString(),
          "username": searchService.searchUsername.value,
          'page': page.toString(),
        },
        method: "post",
      );
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          print("User.fromJSON(json.decode(response.body)['data']).userVideos.length");
          print(User.fromJSON(json.decode(response.body)['data']).userVideos.length);
          if (page > 1) {
            userService.userProfile.value.userVideos.addAll(User.fromJSON(json.decode(response.body)['data']).userVideos);
          } else {
            userService.userProfile.value = User.fromJSON(json.decode(response.body)['data']);
          }
          userService.userProfile.refresh();
          User userValue = userService.userProfile.value;
          stillFetching = false;
          showLoader.value = false;
          showLoader.refresh();
          if (userValue.userVideos.length == userValue.totalVideos) {
            showLoadMore = false;
          }
          if (page == 1) {
            scrollController1.addListener(() async {
              if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
                if (userValue.userVideos.length != userValue.totalVideos && showLoadMore && !stillFetching) {
                  page = page + 1;
                  await getUsersProfile(page);
                }
              }
            });
          }
          return "";
        } else {
          return jsonData['msg'];
        }
      } else {
        return "Error fetching user profile";
      }
    } catch (e) {
      print("error fetching user profile $e");
      return "";
    }
  }

  launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getMyProfile([bool showLoaderOp = true]) async {
    print("getMyProfile $page");
    if (showLoaderOp) {
      EasyLoading.show(
        status: "loading..",
        maskType: EasyLoadingMaskType.black,
      );
    }
    videosLoader.value = true;
    videosLoader.refresh();
    if (page == 1) {
      scrollController1 = new ScrollController();
    }
    bool stillFetching = true;
    var response = await CommonHelper.sendRequestToServer(endPoint: 'fetch-login-user-info', requestData: {'skip': authService.currentUser.value.userVideos.length.toString()}, method: "post");
    stillFetching = false;

    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<Video> videosList = [];
      UserProfileModel? responseData;
      if (jsonData['status'] == 'success') {
        print("jsonData['data'] $jsonData ${jsonData['data']}");
        responseData = UserProfileModel.fromJSON(jsonData);
        videosList = responseData.userVideos;
        print("videosList $videosList ${videosList.length}");
        if (authService.currentUser.value.userVideos.length > 0) {
          authService.currentUser.value.userVideos.addAll(videosList);
        } else {
          authService.currentUser.value.userVideos = videosList;
        }
        authService.currentUser.value.totalVideos = responseData.totalVideos;
        authService.currentUser.value.totalFollowers = responseData.totalFollowers;
        authService.currentUser.value.totalFollowings = responseData.totalFollowings;
        authService.currentUser.value.totalVideosLike = responseData.totalVideosLike;
        authService.currentUser.refresh();
        videosLoader.value = false;
        videosLoader.refresh();
        print("${authService.currentUser.value.userVideos.length} == ${responseData.totalVideos}");
        if (authService.currentUser.value.userVideos.length == responseData.totalVideos) {
          showLoadMore = false;
        }
        if (page == 1) {
          scrollController1.addListener(() {
            if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
              print(
                  "scrollController1.positionasdasdasd ${scrollController1.position.pixels == scrollController1.position.maxScrollExtent} ${scrollController1.position.pixels} == ${scrollController1.position.maxScrollExtent}");
              if (activeTab.value == 1) {
                if (showLoadMore && !stillFetching) {
                  getMyProfile();
                }
              }
            }
          });
        }
      }
    }
  }

  Future getLikedVideos() async {
    showLoadMore = true;
    videosLoader.value = true;
    videosLoader.refresh();
    scrollController1 = new ScrollController();
    try {
      EasyLoading.show(status: "Loading".tr + "...");
      var response = await CommonHelper.sendRequestToServer(endPoint: 'fetch-login-user-fav-videos', requestData: {'skip': authService.currentUser.value.userFavoriteVideos.length}, method: "post");
      EasyLoading.dismiss();
      videosLoader.value = false;
      videosLoader.refresh();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          UserProfileModel favUser = UserProfileModel.fromJSON(jsonData);
          if (authService.currentUser.value.userFavoriteVideos.isNotEmpty) {
            authService.currentUser.value.userFavoriteVideos.addAll(favUser.userVideos);
            authService.currentUser.value.totalUserFavoriteVideos = favUser.totalVideos;
          } else {
            authService.currentUser.value.userFavoriteVideos = favUser.userVideos;
            authService.currentUser.value.totalUserFavoriteVideos = favUser.totalVideos;
          }
          authService.currentUser.refresh();
          if (authService.currentUser.value.userFavoriteVideos.length == authService.currentUser.value.totalUserFavoriteVideos) {
            showLoadMore = false;
          }
          scrollController1.addListener(() {
            if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
              if (authService.currentUser.value.userFavoriteVideos.length != authService.currentUser.value.totalUserFavoriteVideos && showLoadMore) {
                if (activeTab.value == 2) {
                  getLikedVideos();
                }
              }
            }
          });
        } else {
          videosLoader.value = false;
          videosLoader.refresh();
          return UserProfileModel.fromJSON({});
        }
      } else {
        videosLoader.value = false;
        videosLoader.refresh();
        return UserProfileModel.fromJSON({});
      }
    } catch (e, s) {
      print("getLikedVideos error");
      EasyLoading.dismiss();
      print(e);
      print(s);
      videosLoader.value = false;
      videosLoader.refresh();
      return UserProfileModel.fromJSON({});
    }
  }

  openUserProfile(userId) async {
    if (userId.runtimeType == int) {
      userService.userId.value = userId;
    } else {
      SearchService searchService = Get.find();
      searchService.searchUsername.value = userId;
    }
    String errorString = await getUsersProfile(1);
    if (errorString == "") {
      Get.toNamed("/user-profile");
    } else {
      Fluttertoast.showToast(msg: "$errorString");
    }
  }

  Future<void> refreshUserProfile() async {
    if (userService.userId.value > 0) {
      await getUsersProfile(1);
    }
    return Future.value();
  }

  Future<void> refreshMyProfile() async {
    // await getMyProfile(1);
    return Future.value();
  }

  blockUser({report = false}) async {
    showLoader.value = true;
    showLoader.refresh();
    var resp = await CommonHelper.sendRequestToServer(endPoint: 'block-user', method: "post", requestData: {
      "user_id": userService.userId.toString(),
      "report": report ? 1 : 0,
    });

    if (resp.statusCode == 200) {
      showLoader.value = false;
      showLoader.refresh();
      dashboardService.showFollowingPage.value = false;
      dashboardService.showFollowingPage.refresh();
      var response = json.decode(resp.body);
      if (response['status'] == 'success') {
        userService.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userService.userProfile.refresh();
        Fluttertoast.showToast(msg: response['msg']);
        dashboardController.getVideos().whenComplete(() {
          Get.offNamed('/home');
        });
      } else {
        Fluttertoast.showToast(msg: "There is some error");
      }
    } else {
      throw new Exception(resp.body);
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Wrap(
      children: [
        Align(
            alignment: Alignment.center,
            child: Text(
              "Loading...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'RockWellStd',
              ),
            )),
      ],
    ));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  validateField(String value, String field) {
    Pattern pattern = r'^[0-9A-Za-z.\-_]*$';
    RegExp regex = new RegExp(pattern.toString());

    if (value.length == 0) {
      return "$field is required!";
    } else if (field == "Confirm Password" && value != password) {
      return "Confirm Password doesn't match!";
    } else if (field == "Username" && !regex.hasMatch(value)) {
      return "It must contain only _ . and alphanumeric";
    } else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
    if (value.length == 0) {
      isValidEmail.value = false;
      return "Email field is required!";
    } else if (!emailValid) {
      isValidEmail.value = false;
      return "Email field is not valid!";
    } else {
      isValidEmail.value = true;
      // isValidEmail.refresh();
      return null;
    }
  }

  Future<bool> register() async {
    print("register ");
    if (completeProfileFormKey.currentState!.validate()) {
      EasyLoading.show(status: "Please wait.");

      List name = fullName.value.split(' ');
      String fName = name[0];
      String lName = "";
      if (name.length > 1) {
        name.removeAt(0);
        lName = name.join(' ');
      }
      print("aaaaaa");
      final Map<String, dynamic> userProfile = {
        'fname': fName,
        'lname': lName,
        'email': email.value,
        'password': password,
        'confirm_password': confirmPassword,
        'username': username,
        'time_zone': timezone,
        'gender': selectedGender.value,
        'dob': profileDOBString,
        'login_type': "O",
      };
      if (selectedDp.value.path != "") {
        userProfile['profile_pic_file'] = selectedDp.value.path;
      } else {
        userProfile['profile_pic'] = completeProfile.userDP;
      }
      print("aaaaaa");
      UploadFile? profilePicFile;
      final List<UploadFile> files = [];
      try {
        if (userProfile['profile_pic_file'] != null && userProfile['profile_pic_file'] != "") {
          profilePicFile = UploadFile(fileName: userProfile['profile_pic_file']!.split('/').last, filePath: selectedDp.value.path != "" ? selectedDp.value.path : "", variableName: "profile_pic_file");
          print("bbbbbb");
          files.add(profilePicFile);
          print("userProfile $userProfile");
        }
      } catch (e, s) {
        print("profilePicFile failed $e $s");
      }

      try {
        var apiResponse = await CommonHelper.sendRequestToServer(endPoint: 'register', requestData: userProfile, files: files, method: "post");
        EasyLoading.dismiss();
        var value;
        if (files.isEmpty) {
          value = apiResponse.body;
        } else {
          value = json.encode(apiResponse.data);
        }
        // print("response.data ${response.data} $value");
        if (value != null) {
          var response = json.decode(value);
          print("response['status'] ${response['status']} ");
          if (response['status'] != 'success') {
            print("response $response $response['msg'] ");
            String msg = response['msg'];
            showAlertDialog(errorTitle: "Error Registering User", errorString: msg, fromLogin: false);
            return false;
          } else {
            var content = json.decode(json.encode(response['content']));
            print("content $content $content['user_id'] $content['app_token']");
            await GetStorage().write("otp_user_id", content['user_id'].toString());
            await GetStorage().write("otp_app_token", content['app_token']);
            Get.toNamed('/verify-otp');
            return true;
          }
        } else {
          return false;
        }
        // } on DioException catch (e) {
      } catch (e, s) {
        EasyLoading.dismiss();
        print("asdfsdfsdfsdfsdf");

        print(e);
        print(s);
        // print(e.stackTrace);
        return false;
      }
    } else {
      print("sdadsasdads");
      return false;
    }
  }

  Future<bool> registerSocial() async {
    if (completeProfileFormKey.currentState!.validate()) {
      completeProfileFormKey.currentState!.save();
      showLoader.value = true;
      showLoader.refresh();
      List name = completeProfile.name.split(' ');
      String fName = name[0];
      String lName = "";
      if (name.length > 1) {
        name.removeAt(0);
        lName = name.join(' ');
      }
      final Map<String, String> userProfile = {
        'fname': fName,
        'lname': lName,
        'email': completeProfile.email == '' ? email.value : completeProfile.email,
        'password': password,
        'confirm_password': confirmPassword,
        'username': username,
        'gender': selectedGender.value,
        'time_zone': timezone,
        'login_type': loginType,
        'profile_pic': completeProfile.userDP,
      };
      if (selectedDp.value.path != "") {
        userProfile['profile_pic_file'] = selectedDp.value.path;
      } else {
        userProfile['profile_pic'] = completeProfile.userDP;
      }

      var formData = {
        'fname': (fName == '') ? authService.socialUserProfile.value.name.split(" ")[0] : fName,
        'lname': (lName == '') ? authService.socialUserProfile.value.name.split(" ")[1] : lName,
        'email': (userProfile['email'] == '' || userProfile['email'] == null) ? authService.socialUserProfile.value.email : userProfile['email'],
        'password': userProfile['password'],
        'confirm_password': userProfile['confirm_password'],
        'username': userProfile['username'],
        'time_zone': userProfile['time_zone'],
        'login_type': userProfile['login_type'],
        'gender': userProfile['gender'],
        'profile_pic': userProfile['profile_pic'],
        "user_id": authService.currentUser.value.id.toString(),
        "app_token": authService.currentUser.value.accessToken
      };
      final List<UploadFile> files = [];
      if (userProfile['profile_pic_file'] != null) {
        String fileName = userProfile['profile_pic_file']!.split('/').last;
        UploadFile profilePicFile = UploadFile(fileName: fileName, filePath: selectedDp.value.path != "" ? selectedDp.value.path : "", variableName: "profile_pic_file");
        files.add(profilePicFile);
      }
      try {
        var response = await CommonHelper.sendRequestToServer(endPoint: "social-register", requestData: formData, files: files);
        showLoader.value = false;
        showLoader.refresh();

        setCurrentUser(response.body);
        authService.currentUser.value = User.fromJSON(json.decode(response.body)['content']);
        authService.currentUser.refresh();
        dashboardService.showFollowingPage.value = false;
        dashboardService.showFollowingPage.refresh();
        Get.offNamed("/home");
        dashboardController.getVideos();
      } catch (e) {
        json.encode({'status': 'failed', 'msg': 'There is some error'});
      }

      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future<String> login() async {
    loginFormKey.currentState!.save();
    final Map<String, String> userProfile = {
      'email': email.value,
      'password': password,
      'time_zone': timezone,
      'login_type': "O",
    };

    EasyLoading.show(status: 'loading...');
    var value = await CommonHelper.sendRequestToServer(endPoint: 'login', requestData: userProfile, method: "post");
    EasyLoading.dismiss();
    var response = json.decode(value.body);

    if (response["status"] != true) {
      if (response['status'] == 'email_not_verified') {
        var content = json.decode(json.encode(response['content']));
        await GetStorage().write("otp_user_id", content['user_id'].toString());
        await GetStorage().write("otp_app_token", content['app_token']);
        String msg = response['msg'];
        showSendOtp.value = true;
        showSendOtp.refresh();
        showAlertDialog(errorTitle: 'Error Logging OTP', errorString: msg, fromLogin: true, showSendOtp: true);
        return "Otp";
      } else if (response['content'] != null) {
        setCurrentUser(value.body);
        updateFCMTokenForUser();
        authService.currentUser.value = User.fromJSON(response['content']);
        dashboardService.showFollowingPage.value = false;
        dashboardService.showFollowingPage.refresh();
        Get.offNamed('/home');
        dashboardController.getVideos();
        return "Done";
      } else {
        String msg = response['msg'];
        showAlertDialog(errorTitle: 'Error', errorString: msg, fromLogin: true, showSendOtp: false);
        return "Error";
      }
    } else {
      return "Error";
    }
  }

  verifyOtp() async {
    String userId = GetStorage().read("otp_user_id")!;
    String userToken = GetStorage().read("otp_app_token")!;
    EasyLoading.show(status: 'loading...');

    final Map<String, String> data = {
      'user_id': userId,
      'app_token': userToken,
      'otp': otp,
    };

    var value = await CommonHelper.sendRequestToServer(endPoint: "verify-otp", requestData: data, method: "post");
    EasyLoading.dismiss();
    var response = json.decode(value.body);
    if (response['status'] != 'success') {
      String msg = response['msg'];
      showAlertDialog(errorTitle: 'Error Verifying OTP', errorString: msg, fromLogin: false);
    } else {
      setCurrentUser(value.body);
      updateFCMTokenForUser();
      print("response['content'] ${response['content']}");
      authService.currentUser.value = User.fromJSON(response['content']);
      authService.currentUser.refresh();
      dashboardService.showFollowingPage.value = false;
      dashboardService.showFollowingPage.refresh();
      Get.offNamed('/home');
      dashboardController.getVideos();
    }
  }

  resendOtp({verifyPage}) async {
    if (verifyPage != null) {
      startTimer();

      bHideTimer.value = true;
      bHideTimer.refresh();
      reload.value = true;
      reload.refresh();
      countTimer.value = 60;
      countTimer.refresh();
    }

    String userId = GetStorage().read("otp_user_id")!;
    String userToken = GetStorage().read("otp_app_token")!;
    showLoader.value = true;
    showLoader.refresh();

    final Map<String, String> data = {
      'user_id': userId,
      'app_token': userToken,
    };
    var resp = await CommonHelper.sendRequestToServer(endPoint: 'resend-otp', requestData: data, method: "post");

    showLoader.value = false;
    showLoader.refresh();
    var response = json.decode(resp.body);
    if (response['status'] != 'success') {
      String msg = response['msg'];
      showSendOtp.value = true;
      showSendOtp.refresh();
      showAlertDialog(errorTitle: 'Error Verifying OTP', errorString: msg, fromLogin: false, showSendOtp: true);
    } else {
      if (verifyPage == null) {
        Get.toNamed(
          '/verify-otp',
        );
      }
    }
  }

  showAlertDialog({String errorTitle = '', String errorString = '', fromLogin, showSendOtp = false}) {
    print("showAlertDialog");
    AwesomeDialog(
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogBackgroundColor: Get.theme.primaryColor,
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            errorTitle.text.textStyle(Get.theme.textTheme.headlineMedium).make().pOnly(bottom: 5),
            errorString.text.textStyle(Get.theme.textTheme.titleMedium).make().pOnly(bottom: 10),
            showSendOtp
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          ),
                          child: "Resend OTP".text.center.make(),
                          onPressed: () {
                            CommonHelper.showLoaderSpinner(Get.theme.indicatorColor);
                            Get.back();
                            showSendOtp = false;
                            if (fromLogin) {
                              resendOtp();
                            } else {
                              resendOtp(verifyPage: true);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          ),
                          child: "Ok".text.center.make(),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: Get.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                      child: "Ok".text.center.make(),
                      onPressed: () => Get.back(),
                    ),
                  )
          ],
        ),
      ),
    )..show();
  }

  startTimer() {
    Timer.periodic(new Duration(seconds: 1), (timer) {
      // setState(() {
      countTimer.value--;
      countTimer.refresh();
      if (countTimer.value == 0) {
        bHideTimer.value = false;
        bHideTimer.refresh();
        reload.value = true;
        reload.refresh();
      }
      if (countTimer.value <= 0) timer.cancel();
      // });
    });
  }

  getLoginPageData() async {
    showLoader.value = true;
    showLoader.refresh();
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'app-login', requestData: {"data_var": "data"});
      showLoader.value = false;
      showLoader.refresh();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          mainService.loginPageData.value = LoginScreenData.fromJSON(json.decode(response.body)['data']);
          mainService.loginPageData.refresh();
        }
      }
    } catch (e, s) {
      print("fetchLoginPageInfo error" + e.toString());
      print(s);
      return LoginScreenData.fromJSON({});
    }
  }

  Future ifEmailExists(String email) async {
    showLoader.value = true;
    showLoader.refresh();
    print("ifEmailExists $email");
    var response = await CommonHelper.sendRequestToServer(endPoint: "is-email-exist", requestData: {"email": email}, method: "post");
    showLoader.value = false;
    showLoader.refresh();
    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'] == "success") {
        authService.errorString.value = "";
        authService.errorString.refresh();

        if (json.decode(response.body)['isEmailExist'] == 1) {
          AwesomeDialog(
            dialogBackgroundColor: mainService.setting.value.buttonColor,
            context: Get.context!,
            animType: AnimType.scale,
            dialogType: DialogType.warning,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Email Already Exists',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.indicatorColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Use another email to register or login using existing email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Get.theme.indicatorColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Get.theme.highlightColor,
                      ),
                      child: "Ok".text.size(18).center.color(Get.theme.indicatorColor).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  )
                ],
              ),
            ),
          )..show();
        } else {
          loginType = "O";
          Get.toNamed("/complete-profile");
        }
      } else {
        return false;
      }
    } else {
      throw new Exception(response.body);
    }
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        selectedDp.value = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        selectedDp.value = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
      // });
    }
    reload.value = true;
    reload.refresh();
  }

  sendPasswordResetOTP() async {
    EasyLoading.show(status: "Loading....");
    showLoader.value = true;
    showLoader.refresh();
    formKey.currentState!.save();
    var value = await CommonHelper.sendRequestToServer(endPoint: 'forgot-password', requestData: {'email': email.value}, method: "post");
    EasyLoading.dismiss();
    showLoader.value = false;
    showLoader.refresh();
    var response = json.decode(value.body);
    if (response['status'] != 'success') {
      AwesomeDialog(
        dialogBackgroundColor: mainService.setting.value.buttonColor,
        context: Get.context!,
        animType: AnimType.scale,
        dialogType: DialogType.info,
        body: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Sorry this email account does not exists.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Get.theme.indicatorColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Get.theme.highlightColor,
                  ),
                  child: "Ok".text.size(18).center.color(Get.theme.indicatorColor).make().centered().pSymmetric(h: 10, v: 10),
                ),
              )
            ],
          ),
        ),
      )..show();
    } else {
      Fluttertoast.showToast(msg: "An OTP is sent to your email please check your email.");
      await Future.delayed(
        Duration(seconds: 2),
      );
      authService.resetPasswordEmail.value = email.value;
      Get.offNamed('/reset-forgot-password');
    }
  }

  updateForgotPassword() async {
    EasyLoading.show(status: "Loading....");
    showLoader.value = true;
    showLoader.refresh();
    resetForgotPassword.currentState!.save();
    final Map<String, String> data = {
      'email': authService.resetPasswordEmail.value,
      'otp': otp,
      'password': password,
      'confirm_password': confirmPassword,
    };

    var value = await CommonHelper.sendRequestToServer(endPoint: 'update-forgot-password', requestData: data, method: "post");
    EasyLoading.dismiss();
    showLoader.value = false;
    showLoader.refresh();

    var response = json.decode(value.body);
    if (response['status'] != 'success') {
      AwesomeDialog(
        dialogBackgroundColor: mainService.setting.value.buttonColor,
        context: Get.context!,
        animType: AnimType.scale,
        dialogType: DialogType.info,
        body: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    response['msg'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Get.theme.indicatorColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Get.theme.highlightColor,
                  ),
                  child: "Ok".text.size(18).center.color(Get.theme.indicatorColor).make().centered().pSymmetric(h: 10, v: 10),
                ),
              )
            ],
          ),
        ),
      )..show();
    } else {
      Fluttertoast.showToast(msg: "Password updated Successfully");
      // FocusScope.of(resetForgotPasswordScaffoldKey.currentContext!).requestFocus(FocusNode());
      await Future.delayed(
        Duration(seconds: 2),
      );
      Get.offNamed("/login");
    }
  }

  deleteVideo(videoId) async {
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'delete-video', requestData: {"video_id": videoId}, method: "post");
      showLoader.value = false;
      showLoader.refresh();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          authService.currentUser.value.userVideos.removeWhere((item) => item.videoId == videoId);
          authService.currentUser.refresh();
          // String msg = response['msg'];
          Fluttertoast.showToast(msg: "Video deleted Successfully");
        } else {
          Fluttertoast.showToast(msg: "There's some error deleting video");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "There's some error deleting video");

      print(e.toString());
    }
  }

  showDeleteAlert(errorTitle, errorString, videoId) {
    AwesomeDialog(
      dialogBackgroundColor: mainService.setting.value.buttonColor,
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.info,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Get.theme.highlightColor,
                      ),
                      child: "No".text.size(18).center.color(Get.theme.indicatorColor).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      deleteVideo(videoId);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Get.theme.highlightColor,
                      ),
                      child: "Yes".text.size(18).center.color(Get.theme.indicatorColor).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )..show();
  }

  editVideo(videoId, videoDescription, privacy) async {
    showLoader.value = true;
    showLoader.refresh();
    EasyLoading.show(status: "Updating Video".tr);
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'update-video-description', method: "post", requestData: {
        "video_id": videoId,
        "description": videoDescription,
        "privacy": privacy,
      });
      EasyLoading.dismiss();
      showLoader.value = false;
      showLoader.refresh();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          authService.currentUser.value.userVideos = [];
          var response = await CommonHelper.sendRequestToServer(endPoint: 'fetch-login-user-info', requestData: {'page': page.toString()}, method: "post");
          if (response.statusCode == 200) {
            var jsonData = json.decode(response.body);
            List<Video> videosList = [];
            UserProfileModel? responseData;
            if (jsonData['status'] == 'success') {
              print("jsonData['data'] $jsonData ${jsonData['data']}");
              responseData = UserProfileModel.fromJSON(jsonData);
              videosList = responseData.userVideos;
              print("videosList $videosList ${videosList.length}");
              if (authService.currentUser.value.userVideos.length > 0) {
                authService.currentUser.value.userVideos.addAll(videosList);
              } else {
                authService.currentUser.value.userVideos = videosList;
                authService.currentUser.value.totalVideos = responseData.totalVideos;
                authService.currentUser.value.totalFollowers = responseData.totalFollowers;
                authService.currentUser.value.totalFollowings = responseData.totalFollowings;
                authService.currentUser.value.totalVideosLike = responseData.totalVideosLike;
              }
              authService.currentUser.refresh();
              videosLoader.value = false;
              videosLoader.refresh();
              print("${authService.currentUser.value.userVideos.length} == ${responseData.totalVideos}");
              if (authService.currentUser.value.userVideos.length == responseData.totalVideos) {
                showLoadMore = false;
              }
            }
          }
          Fluttertoast.showToast(msg: "Video Updated Successfully");
          await Future.delayed(
            Duration(seconds: 1),
          );
          VideoRecorderController videoRecorderController = Get.find();
          videoRecorderController.detectableTextVideoDescriptionController.value.text = "";
          Get.back();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      showLoader.value = false;
      showLoader.refresh();
      print(e.toString());
    }
  }

  deleteProfile() async {
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'delete-user-profile', requestData: {"otp": otp}, method: "post");
      print("deleteProfile response ${response.body}");
      if (response.statusCode != 200) {
        var resp = jsonDecode(response.body);
        Fluttertoast.showToast(msg: resp["msg"], backgroundColor: Get.theme.highlightColor);
        return false;
      } else {
        authService.pusher.disconnect();
        if (authService.currentUser.value.loginType == 'FB') {
          FacebookAuth.instance.logOut();
        } else if (authService.currentUser.value.loginType == 'G') {
          await authService.googleSignIn.signOut();
        }
        print("Success response ${response.body}");
        var resp = jsonDecode(response.body);
        if (resp['status'] != "error") {
          authService.currentUser.value = new User();
          await GetStorage().remove('current_user');
          await GetStorage().remove('EULA_agree');
          authService.currentUser.value = User.fromJSON({});
          authService.currentUser.refresh();
          dashboardService.showFollowingPage.value = false;
          dashboardService.showFollowingPage.refresh();
          dashboardController.getVideos();
          Get.offNamed('/home');
        } else {
          Fluttertoast.showToast(msg: resp["msg"], backgroundColor: Get.theme.highlightColor);
          return false;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error verifying OTP", backgroundColor: Get.theme.highlightColor);
      print("files error $e");
      return false;
    }
  }

  deleteProfileConfirmation() {
    AwesomeDialog(
      dialogBackgroundColor: Get.theme.primaryColor.withOpacity(0.7),
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Caution!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.highlightColor,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Profile deletion will permanently delete user's profile and all its data, it can not be recovered in future. For confirmation we'll send an OTP to your registered email Id.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Get.theme.highlightColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Get.theme.highlightColor,
                        border: Border.all(color: Get.theme.indicatorColor, width: 0.5),
                      ),
                      child: "No".text.size(18).center.color(mainService.setting.value.buttonTextColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      try {
                        var response = await CommonHelper.sendRequestToServer(endPoint: 'delete-user-confirmation', method: "post", requestData: {"data_var": "data"});
                        print("deleteProfileConfirmation response ${response.body}");
                        if (response.statusCode != 200) {
                          // Fluttertoast.showToast(msg: "error_while_action".trParams({"action": "updating".tr, "entity": "profile".tr}), backgroundColor: Get.theme.errorColor);
                        } else {
                          Fluttertoast.showToast(msg: "An OTP has been sent to your Mobile or Email", backgroundColor: Get.theme.highlightColor, textColor: Get.theme.indicatorColor);
                          print("Success response ${response.body}");
                          showDeleteConfirmation();
                        }
                      } catch (e) {
                        print("files error $e");
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Get.theme.indicatorColor, width: 0.5),
                        color: mainService.setting.value.buttonColor,
                      ),
                      child: "Send OTP".text.size(18).center.color(mainService.setting.value.buttonTextColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )..show();
  }

  showDeleteConfirmation() {
    Get.back();
    AwesomeDialog(
      dialogBackgroundColor: Get.theme.primaryColor.withOpacity(0.7),
      context: Get.context!,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Verify OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.highlightColor,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Verify OTP and delete profile.\nProfile deletion will permanently delete user's profile and all its data, it can not be recovered in future.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Get.theme.highlightColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            PinCodeTextField(
              backgroundColor: Get.theme.primaryColor,
              appContext: Get.context!,
              pastedTextStyle: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              length: 6,
              obscureText: true,
              obscuringCharacter: '*',
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                inactiveColor: Get.theme.indicatorColor,
                disabledColor: Get.theme.indicatorColor,
                inactiveFillColor: Get.theme.indicatorColor,
                selectedFillColor: Get.theme.indicatorColor,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(0),
                fieldHeight: Get.width * 0.08,
                fieldWidth: Get.width * 0.08,
                activeFillColor: Get.theme.indicatorColor,
              ),
              cursorColor: Get.theme.shadowColor,
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              // errorAnimationController: otpErrorController,
              // controller: otpTextEditingController,
              keyboardType: TextInputType.number,
              boxShadows: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Get.theme.shadowColor,
                  blurRadius: 10,
                )
              ],
              onCompleted: (v) {
                deleteProfileOtp = v;
              },
              onChanged: (value) {
                deleteProfileOtp = value;
              },
              beforeTextPaste: (text) {
                return true;
              },
            ),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Get.theme.highlightColor,
                        border: Border.all(color: Get.theme.indicatorColor, width: 0.5),
                      ),
                      child: "No".text.size(18).center.color(mainService.setting.value.buttonTextColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      deleteProfile();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Get.theme.indicatorColor, width: 0.5),
                        color: mainService.setting.value.buttonColor,
                      ),
                      child: "Verify and Delete".text.size(18).center.color(mainService.setting.value.buttonTextColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )..show();
  }

  Future<void> updateFCMTokenForUser() async {
    FirebaseMessaging.instance.getToken().then((value) {
      if (value != "" && value != null) {
        updateFcmToken(value);
      }
    });
  }

  updateFcmToken(token) async {
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'update-fcm-token', requestData: {"fcm_token": token.toString()}, method: "post");
      if (response.statusCode == 200) {
        AuthService authService = Get.find();
        var jsonData = json.decode(response.body);
        print("updateFcmToken $jsonData");
        authService.notificationsCount.value = jsonData['count'] ?? 0;
        authService.notificationsCount.refresh();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getCurrentUser() async {
    print("getCurrentUser");
    String? prefCurrentUser = GetStorage().read('current_user');
    print("prefCurrentUser");
    print(prefCurrentUser);
    if ((authService.currentUser.value.accessToken == '') && GetStorage().hasData('current_user')) {
      String? prefCurrentUser = GetStorage().read('current_user');
      print("prefCurrentUser");
      print(prefCurrentUser);
      try {
        var decodedUser = json.decode(prefCurrentUser!);
        authService.currentUser.value = LoginModel.fromJSON(decodedUser).data!;
      } catch (e) {
        print("error user $e");
      }
      print("currentUser.value.username");
      print(authService.currentUser.value.username);
      print(authService.currentUser.value.id);
      print(authService.currentUser.value.id);
      print(authService.currentUser.value.accessToken);
    }
    authService.currentUser.refresh();
    /*else {
      currentUser.value.auth = false;
    }*/
    return authService.currentUser.value;
  }

  Future<void> setCurrentUser(responseBody, [bool isEdit = false]) async {
    log("json.decode(jsonString)['content'] ${json.decode(responseBody)['content']} $responseBody ");
    try {
      await GetStorage().write('current_user', json.encode(json.decode(responseBody)['content'])).whenComplete(() => print("Current User Storage Written Successfully"));
      authService.currentUser.value = User.fromJSON(json.decode(responseBody)['content']);
      authService.currentUser.refresh();
      if (!isEdit) {
        ChatController chatController = Get.find();
        chatController.connectPusher();
      }
    } catch (e, s) {
      print("setCurrentUser error: $e");
      print(s);
    }
  }

  Future logout() async {
    try {
      await authService.pusher.disconnect();
    } catch (e) {
      print("error disconnecting echo $e");
    }
    if (authService.currentUser.value.loginType == 'FB') {
      FacebookAuth.instance.logOut();
    } else if (authService.currentUser.value.loginType == 'G') {
      await authService.googleSignIn.signOut();
    }

    Uri uri = CommonHelper.getUri('logout');
    /*CommonHelper.printUserLog(*/
    print(uri.toString());

    /*try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
    );
    print("Logout response ${response.body}");
    if (response.statusCode != 200) {
      // Fluttertoast.showToast(msg: "error_while_action".trParams({"action": "updating".tr, "entity": "profile".tr}), backgroundColor: Get.theme.errorColor);
    } else {
      print("Success response ${response.body}");
    }
  } catch (e) {
    // Fluttertoast.showToast(msg: "error_while_action".trParams({"action": "updating".tr, "entity": "profile".tr}), backgroundColor: Get.theme.errorColor);
    print("files error $e");
  }*/

    await GetStorage().remove('current_user');
    await GetStorage().remove('EULA_agree');

    page = 0;
    activeTab.value = 1;
    authService.currentUser.value = User();
    authService.currentUser.refresh();
  }

  Future<void> userUniqueId() async {
    uniqueId = (GetStorage().read('unique_id') == null) ? "" : GetStorage().read('unique_id').toString();
    if (uniqueId == "") {
      try {
        var response = await CommonHelper.sendRequestToServer(endPoint: 'get-unique-id', method: "post", requestData: {"data_var": "data"});
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData['status'] == 'success') {
            await GetStorage().write("unique_id", jsonData['unique_token']);
            uniqueId = jsonData['unique_token'];
          }
        }
      } catch (e, s) {
        print(e.toString());
        print(s.toString());
      }
    }
  }

  Future<void> checkIfAuthenticated() async {
    AuthService authService = Get.find();
    if (GetStorage().hasData('current_user')) {
      String cu = GetStorage().read('current_user').toString();
      authService.currentUser.value = User.fromJSON(json.decode(cu));
    }
    if (authService.currentUser.value.accessToken == '') {
      return;
    }
    HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'refresh', method: "post", requestData: {"data_var": "data"});
    if (response.statusCode == 200) {
      await setCurrentUser(response.body);
    } else {
      authService.currentUser.value = User();
      await GetStorage().remove('current_user');
    }
  }
}
