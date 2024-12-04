import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as DIO;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../core.dart';

class UserProfileController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PanelController pc = new PanelController();
  var showLoader = false.obs;
  final picker = ImagePicker();
  File image = File("");
  String emailErr = '';
  String nameErr = '';
  String mobileErr = '';
  String genderErr = '';
  String currentPasswordErr = '';
  String newPasswordErr = '';
  String confirmPasswordErr = '';
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  ScrollController scrollController = new ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<ScaffoldState> blockedUserScaffoldKey = GlobalKey<ScaffoldState>();
  UserController userCon = Get.find();
  User userProfileCon = new User();
  List<Gender> genders = <Gender>[const Gender('', 'Select'), const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')];
  Gender selectedGender = Gender('', 'Select');
  bool showLoadMore = true;
  bool blockUnblockLoader = false;
  AuthService authService = Get.find();
  UserService userService = Get.find();
  MainService mainService = Get.find();
  /*GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PanelController pc = new PanelController();
  var showLoader = false.obs;
  final picker = ImagePicker();

  Gender selectedGender = Gender("M", "Male");*/
  String name = '';
  String address = '';
  var document1 = ''.obs;
  var document2 = ''.obs;
  String verified = '';
  String verifiedText = '';
  String submitText = 'Submit';

  String addressErr = '';
  String document1Err = '';
  String reason = '';
  VerifyProfileModel verifyProfileCon = new VerifyProfileModel();
  var reload = false.obs;
  TextEditingController addressController = TextEditingController();

  var hideNewPassword = true.obs;
  var hideConfirmPassword = true.obs;
  var hideCurrentPassword = true.obs;
  /*UserProfileController() {
    fetchLoggedInUserInformation();
  }*/

  @override
  void onInit() {
    // TODO: implement onInit
    scrollController = new ScrollController();
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editProfilePage');
    formKey = new GlobalKey<FormState>();
    blockedUserScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_blockedUserScaffoldPage');
    scrollController = new ScrollController();
    super.onInit();
  }

  fetchLoggedInUserInformation() async {
    showLoader.value = true;
    showLoader.refresh();
    EasyLoading.show(status: "Loading....".tr);
    scrollController = new ScrollController();
    // authService.currentUser.value = User.fromJSON({});
    // userService.userProfile.refresh();

    // var response = await CommonHelper.sendRequestToServer(endPoint: 'user_information');
    // if (response.statusCode == 200) {
    //   var jsonData = json.decode(response.body);
    //   if (jsonData['status'] == 'success') {

    print(
        "userValue.gender ${authService.currentUser.value.gender} ${authService.currentUser.value.gender.length} ${authService.currentUser.value.username} ${authService.currentUser.value.name} ${authService.currentUser.value.email} ${authService.currentUser.value.mobile} ${authService.currentUser.value.bio}");
    selectedGender = authService.currentUser.value.gender == 'm'
        ? genders[1]
        : authService.currentUser.value.gender == 'f'
            ? genders[2]
            : authService.currentUser.value.gender == 'o'
                ? genders[3]
                : genders[0];

    usernameController = new TextEditingController(text: authService.currentUser.value.username);
    nameController = new TextEditingController(text: authService.currentUser.value.name);
    emailController = new TextEditingController(text: authService.currentUser.value.email);
    mobileController = new TextEditingController(text: authService.currentUser.value.mobile);
    bioController = new TextEditingController(text: authService.currentUser.value.bio);
    userService.userProfile.value = authService.currentUser.value;
    userService.userProfile.refresh();
    showLoader.value = false;
    EasyLoading.dismiss();
    showLoader.refresh();
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      print("pickedFile $pickedFile");
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
      // });
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
      // });
    }
    if (image.path == "") {
      Fluttertoast.showToast(msg: "No Image Selected".tr);
    } else {
      updateProfilePic(image);
      image = File("");
    }
  }

  Future updateProfilePic(File file) async {
    userCon = UserController();
    EasyLoading.show(status: "Loading....".tr);
    // showLoader.value = true;
    // showLoader.refresh();
    try {
      String fileName = file.path.split('/').last;
      UploadFile profilePicFile = UploadFile(fileName: fileName, filePath: file.path, variableName: "profile_pic");

      final List<UploadFile> files = [profilePicFile];

      var response = await CommonHelper.sendRequestToServer(endPoint: 'update_profile_pic', method: "post", files: files, requestData: {"data_var": "data"});
      print("updateProfilePicResponse ${response.data}");
      if (response.statusCode == 200) {
        var value = json.decode(json.encode(response.data));
        if (value['status'] == 'success') {
          // setState(() {
          authService.currentUser.value.smallProfilePic = value['small_pic'];
          authService.currentUser.value.largeProfilePic = value['large_pic'];
          userService.userProfile.refresh();
          authService.currentUser.value.userDP = value['large_pic'];
          authService.currentUser.refresh();
          userCon.refreshMyProfile();
          EasyLoading.dismiss();
          // showLoader.value = false;
          // showLoader.refresh();
        } else {
          showLoader.value = false;
          EasyLoading.dismiss();
          showLoader.refresh();
          Fluttertoast.showToast(msg: "There are some error to upload file");
        }
      } else {
        return "";
      }
    } catch (e, s) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "There are some error to upload file");
      print("profilePicError $e ");
      print("profilePicErrorStack $s");
      return "";
    }
  }

  updateProfile() async {
    if (userService.userProfile.value.name.contains(" ")) {
      var nameArr = userService.userProfile.value.name.split(' ');
      userService.userProfile.value.firstName = nameArr[0];
      userService.userProfile.value.lastName = nameArr[1];
    } else {
      userService.userProfile.value.firstName = userService.userProfile.value.name;
      userService.userProfile.value.lastName = "";
    }
    // authService.currentUser.value.accessToken = authService.currentUser.value.accessToken;
    userService.userProfile.refresh();
    showLoader.value = true;
    EasyLoading.show(status: "Loading....".tr);
    showLoader.refresh();
    var data = userService.userProfile.value.toJson();
    if (data['mobile'] == null) {
      data['mobile'] = "";
    }
    var response = await CommonHelper.sendRequestToServer(endPoint: 'update_user_information', requestData: data, method: "post");
    showLoader.value = false;
    EasyLoading.dismiss();
    showLoader.refresh();
    var responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['status'] == 'success') {
      await userCon.setCurrentUser(response.body, true);

      Get.back();
      Fluttertoast.showToast(msg: "Updated Successfully");
    } else {
      showLoader.value = false;
      EasyLoading.dismiss();
      showLoader.refresh();
      Fluttertoast.showToast(msg: responseData['msg']);
      throw new Exception(response.body);
    }
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (nameErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        nameErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (emailErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        emailErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (mobileErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        mobileErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (genderErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        genderErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (currentPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        currentPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (newPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        newPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (confirmPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        confirmPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: 25,
                    width: 50,
                    decoration: BoxDecoration(color: mainService.setting.value.buttonColor),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "OK",
                            style: TextStyle(
                              color: mainService.setting.value.buttonTextColor,
                              fontSize: 16,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onChanged(value) {
    userProfileCon.dob = value;
  }

  Future<void> changePassword() async {
    showLoader.value = true;
    EasyLoading.show(status: "Loading....".tr);
    showLoader.refresh();

    var data = {
      "user_id": authService.currentUser.value.id.toString(),
      "app_token": authService.currentUser.value.accessToken,
      "old_password": currentPassword,
      "password": newPassword,
      "confirm_password": confirmPassword,
    };
    var response = await CommonHelper.sendRequestToServer(endPoint: 'change-password', method: "post", requestData: data);
    showLoader.value = false;
    EasyLoading.dismiss();
    showLoader.refresh();
    if (response.statusCode == 200) {
      var jsonData = json.decode(json.encode(json.decode(response.body)));
      if (jsonData['status'] == 'success') {
        Fluttertoast.showToast(msg: "Password changed successfully".tr);
        Get.back();
      } else {
        showLoader.value = false;
        EasyLoading.dismiss();
        showLoader.refresh();
        Fluttertoast.showToast(msg: jsonData['msg']);
      }
    } else {
      Fluttertoast.showToast(msg: "There's some error");
      throw new Exception(response.body);
    }
  }

  getBlockedUsers(int page) async {
    showLoader.value = true;
    EasyLoading.show(status: "Loading....".tr);
    showLoader.refresh();
    scrollController = new ScrollController();
    if (page == 1) {
      userService.blockedUsersData.value = BlockedModel.fromJSON({});
      userService.blockedUsersData.refresh();
    }
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'blocked-users-list', requestData: {'page': page.toString()});
      showLoader.value = false;
      EasyLoading.dismiss();
      showLoader.refresh();
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            userService.blockedUsersData.value.users.addAll(BlockedModel.fromJSON(json.decode(response.body)['blockList']).users);
          } else {
            userService.blockedUsersData.value = BlockedModel.fromJSON(json.decode(response.body)['blockList']);
            scrollController.addListener(() {
              if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                if (userService.blockedUsersData.value.users.length != userService.blockedUsersData.value.totalRecords && showLoadMore) {
                  page = page + 1;
                  getBlockedUsers(page);
                }
              }
            });
          }
          if (userService.blockedUsersData.value.users.length == userService.blockedUsersData.value.totalRecords) {
            showLoadMore = false;
          }
          userService.usersData.refresh();
          return userService.blockedUsersData.value;
        } else {
          return BlockedModel.fromJSON({});
        }
      } else {
        return BlockedModel.fromJSON({});
      }
    } catch (e) {
      print(e.toString());
      return BlockedModel.fromJSON({});
    }
  }

  blockUnblockUser(userId, {report = false}) async {
    blockUnblockLoader = true;
    var resp = await CommonHelper.sendRequestToServer(endPoint: 'block-user', requestData: {"user_id": userId.toString(), "report": report ? 1 : 0}, method: "post");
    if (resp.statusCode == 200) {
      var value = json.encode(json.decode(resp.body));
      blockUnblockLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        userService.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userService.userProfile.refresh();
        userService.blockedUsersData.value.users.removeWhere((element) => element.id == userId);
        userService.blockedUsersData.refresh();
        Fluttertoast.showToast(msg: response['msg']);
      } else {
        Fluttertoast.showToast(msg: "There are some error");
        throw new Exception(response.body);
      }
    }
  }

  fetchVerifyInformation() async {
    showLoader.value = true;
    EasyLoading.show(status: "Loading....".tr);
    showLoader.refresh();
    scrollController = new ScrollController();
    VerifyProfileModel userValue = VerifyProfileModel.fromJSON({});
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'verify-status', requestData: {"data_var": "data"});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          userValue = VerifyProfileModel.fromJSON(json.decode(response.body)['data']);
        } else {
          userValue = VerifyProfileModel.fromJSON({});
        }
      } else {
        userValue = VerifyProfileModel.fromJSON({});
      }
    } catch (e) {
      print(e.toString());
      userValue = VerifyProfileModel.fromJSON({});
    }

    showLoader.value = false;
    EasyLoading.dismiss();
    showLoader.refresh();
    // setState(() {
    print("fetchVerifyInformation jsonData $userValue");
    verified = userValue.verified;
    nameController = new TextEditingController(text: userValue.name);
    addressController = new TextEditingController(text: userValue.address);
    name = userValue.name;
    address = userValue.address;
    document1.value = userValue.document1;
    document2.value = userValue.document2;
    if (userValue.verified == "P") {
      verifiedText = "Pending";
      submitText = "Verification Pending";
    } else if (userValue.verified == "A") {
      verifiedText = "Verified";
      submitText = "Verified Already";
    } else if (userValue.verified == "R") {
      verifiedText = "Rejected";
      submitText = "Re-submit";
      reason = userValue.reason;
    } else {
      verifiedText = "Not Applied";
      submitText = "Submit";
    }

    reload.value = true;
    reload.refresh();
    // });
  }

  getDocument1(bool isCamera) async {
    File image = File("");
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.refresh();
      } else {
        print('No image selected.');
      }
      // });
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.refresh();
      } else {
        print('No image selected.');
      }
    }
    document1.value = image.path;
  }

  getDocument2(bool isCamera) async {
    File image = File("");
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.refresh();
      } else {
        print('No image selected.');
      }
      // });
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.refresh();
      } else {
        print('No image selected.');
      }
      // });
    }
    document2.value = image.path;
  }

  updateVerifyProfile() async {
    String regPattern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = new RegExp(regPattern);
    nameErr = "";
    addressErr = "";
    document1Err = "";
    if (name.length == 0) {
      nameErr = 'Please enter full name';
    } else if (!regExp.hasMatch(name)) {
      nameErr = 'Please enter valid full name';
    }
    if (address.length == 0) {
      addressErr = "Address Field is required";
    } else {
      addressErr = "";
    }
    if (document1.value.length == 0) {
      document1Err = "Front Side of ID document is required";
    } else {
      document1Err = "";
    }

    if (nameErr == '' && addressErr == '' && document1Err == '') {
      showLoader.value = true;

      EasyLoading.show(status: "Loading".tr + "...");

      showLoader.refresh();
      Map<String, String> data = {};
      data['name'] = name;
      data['address'] = address;
      data['document1'] = "";
      String fileName1 = "";
      if (!document1.value.contains("http")) {
        data['document1'] = document1.value;
        fileName1 = data['document1']!.split('/').last;
      }
      if (document2.value != '' && !document1.value.contains("http")) {
        data['document2'] = document2.value;
      }
      print("updateVerifyProfile $data");
      Map<String, dynamic> submitData = {
        "name": data['name'],
        "address": data['address'],
      };
      List<UploadFile> files = [];
      if (data['document1'] != "") {
        UploadFile document1 = UploadFile(fileName: fileName1, filePath: data['document1']!, variableName: "document1");
        files.add(document1);
      }
      print("updateVerifyProfile $submitData");
      if (data['document2'] != null) {
        String fileName2 = data['document2']!.split('/').last;
        submitData["document2"] = await DIO.MultipartFile.fromFile(data['document2']!, filename: fileName2);
        UploadFile document1 = UploadFile(fileName: fileName1, filePath: data['document1']!, variableName: "document1");
        files.add(document1);
      }
      print("updateVerifyProfile $submitData");
      try {
        EasyLoading.show(status: "Loading....".tr);
        // DIO.FormData formData = DIO.FormData.fromMap(submitData);

        var response = await CommonHelper.sendRequestToServer(endPoint: 'user-verify', method: "post", requestData: submitData, files: files);

        var value;
        print("error here1");
        if (response.statusCode == 200) {
          value = json.encode(response.data);
        } else {
          print("error here");
          throw new Exception(response.data);
        }
        var responseData = json.decode(value);
        if (responseData['status'] == 'success') {
          EasyLoading.dismiss();
          Fluttertoast.showToast(msg: "Application submitted successfully".tr);
          Get.back();
        } else {
          print("responseData $responseData");
          EasyLoading.dismiss();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text("There is some error"),
            ),
          );
        }
      } catch (e) {
        showLoader.value = false;
        EasyLoading.dismiss();
        showLoader.refresh();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text("There is some error"),
          ),
        );
      }
    } else {
      print("0asdasdasd");
      verifyShowAlertDialog(scaffoldKey.currentContext!);
    }
  }

  verifyShowAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (nameErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        nameErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (addressErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        addressErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (document1Err != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        document1Err,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: 25,
                    width: 50,
                    decoration: BoxDecoration(color: mainService.setting.value.buttonColor),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "OK",
                            style: TextStyle(
                              color: mainService.setting.value.buttonTextColor,
                              fontSize: 16,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
