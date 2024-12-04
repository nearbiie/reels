import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datePick;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class EditProfileView extends StatefulWidget {
  EditProfileView({Key? key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  UserProfileController userProfileController = Get.find();
  MainService mainService = Get.find();
  UserService userService = Get.find();
  AuthService authService = Get.find();
  int page = 1;
  var minDate = new DateTime.now().subtract(Duration(days: 29200));
  var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
  var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
  var formatterYear = new DateFormat('yyyy');
  var formatterDate = new DateFormat('dd MMM yyyy');

  String minYear = "";
  String maxYear = "";
  String initDatetime = "";

  @override
  initState() {
    print("StartForeach");
    minYear = formatterYear.format(minDate);
    maxYear = formatterYear.format(yearBefore);
    initDatetime = formatter.format(yearBefore);

    userProfileController.genders.forEach((element) {
      print(element.value + " " + element.name);
    });
    print("EndForeach");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      key: userProfileController.scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
        title: "Edit Profile".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            onTap: () {
              if (userProfileController.formKey.currentState!.validate()) {
                userProfileController.updateProfile();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Get.theme.highlightColor,
              ),
              child: "Update".text.size(10).uppercase.center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 8, v: 0),
            ).pSymmetric(h: 15, v: 12),
          )
        ],
      ),
      body: Obx(
        () => !userProfileController.showLoader.value
            ? SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    color: Get.theme.primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipPath(
                          clipper: CurveDownClipper(),
                          child: Container(
                            color: Get.theme.shadowColor.withOpacity(0.3),
                            height: Get.height * (0.20),
                            width: Get.width,
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                          backgroundColor: Get.theme.shadowColor,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: Get.height * (0.15),
                                              width: Get.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () {
                                                          userProfileController.getImageOption(true);
                                                          Get.back();
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                              'assets/icons/camera.svg',
                                                              colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                              child: Text(
                                                                "Camera",
                                                                style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          userProfileController.getImageOption(false);
                                                          Get.back();
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                              'assets/icons/image-gallery.svg',
                                                              colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                              child: Text(
                                                                "Gallery",
                                                                style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                            return Scaffold(
                                                                appBar: PreferredSize(
                                                                  preferredSize: Size.fromHeight(45.0),
                                                                  child: AppBar(
                                                                    leading: InkWell(
                                                                      onTap: () {
                                                                        Get.back();
                                                                      },
                                                                      child: Icon(
                                                                        Icons.arrow_back_ios,
                                                                        size: 20,
                                                                        color: Get.theme.iconTheme.color,
                                                                      ),
                                                                    ),
                                                                    iconTheme: IconThemeData(
                                                                      color: Colors.black, //change your color here
                                                                    ),
                                                                    backgroundColor: Get.theme.primaryColor,
                                                                    title: Text(
                                                                      "PROFILE PICTURE",
                                                                      style: TextStyle(
                                                                        fontSize: 18.0,
                                                                        fontWeight: FontWeight.w400,
                                                                        color: mainService.setting.value.headingColor,
                                                                      ),
                                                                    ),
                                                                    centerTitle: true,
                                                                  ),
                                                                ),
                                                                backgroundColor: Get.theme.primaryColor,
                                                                body: Center(
                                                                  child: PhotoView(
                                                                    enableRotation: true,
                                                                    imageProvider: CachedNetworkImageProvider((authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                            authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                        ? authService.currentUser.value.largeProfilePic
                                                                        : '$baseUrl' + "default/user-dummy-pic.png"),
                                                                  ),
                                                                ));
                                                          }));
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                              'assets/icons/views.svg',
                                                              colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                              child: Text(
                                                                "View Picture",
                                                                style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                        border: new Border.all(
                                          color: mainService.setting.value.dpBorderColor!,
                                          width: 5.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new CachedNetworkImageProvider(
                                                (authService.currentUser.value.userDP.toLowerCase().contains(".jpg") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains(".jpeg") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains(".png") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains(".gif") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains(".bmp") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains("fbsbx.com") ||
                                                        authService.currentUser.value.userDP.toLowerCase().contains("googleusercontent.com"))
                                                    ? authService.currentUser.value.userDP
                                                    : '$baseUrl' + "default/user-dummy-pic.png",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet<void>(
                                              backgroundColor: Get.theme.shadowColor,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: Get.height * (0.15),
                                                  width: Get.width,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () {
                                                              userProfileController.getImageOption(true);
                                                              Get.back();
                                                            },
                                                            child: Column(
                                                              children: <Widget>[
                                                                SvgPicture.asset(
                                                                  'assets/icons/camera.svg',
                                                                  colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                  child: Text(
                                                                    "Camera",
                                                                    style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              userProfileController.getImageOption(false);
                                                              Get.back();
                                                            },
                                                            child: Column(
                                                              children: <Widget>[
                                                                SvgPicture.asset(
                                                                  'assets/icons/image-gallery.svg',
                                                                  colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                  child: Text(
                                                                    "Gallery",
                                                                    style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Get.back();
                                                              Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                  builder: (context) {
                                                                    return Scaffold(
                                                                      appBar: PreferredSize(
                                                                        preferredSize: Size.fromHeight(45.0),
                                                                        child: AppBar(
                                                                          leading: InkWell(
                                                                            onTap: () {
                                                                              Get.back();
                                                                            },
                                                                            child: Icon(
                                                                              Icons.arrow_back_ios,
                                                                              size: 20,
                                                                              color: Get.theme.iconTheme.color,
                                                                            ),
                                                                          ),
                                                                          iconTheme: IconThemeData(
                                                                            color: Colors.black, //change your color here
                                                                          ),
                                                                          backgroundColor: Get.theme.primaryColor,
                                                                          title: Text(
                                                                            "PROFILE PICTURE",
                                                                            style: TextStyle(
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: mainService.setting.value.headingColor,
                                                                            ),
                                                                          ),
                                                                          centerTitle: true,
                                                                        ),
                                                                      ),
                                                                      backgroundColor: Get.theme.primaryColor,
                                                                      body: Center(
                                                                        child: PhotoView(
                                                                          enableRotation: true,
                                                                          imageProvider: CachedNetworkImageProvider((authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                                  authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                              ? authService.currentUser.value.largeProfilePic
                                                                              : '$baseUrl' + "default/user-dummy-pic.png"),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Column(
                                                              children: <Widget>[
                                                                SvgPicture.asset(
                                                                  'assets/icons/views.svg',
                                                                  colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                  child: Text(
                                                                    "View Picture",
                                                                    style: TextStyle(color: Get.theme.indicatorColor, fontSize: 14),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Get.theme.primaryColor,
                                          size: 25.0,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Container(
                            child: Form(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              key: userProfileController.formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Username",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Get.theme.indicatorColor,
                                        ),
                                      ),
                                      TextFormField(
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 14.0,
                                        ),
                                        obscureText: false,
                                        validator: (input) {
                                          if (input!.isEmpty) {
                                            return "Username field is required!";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        controller: userProfileController.usernameController,
                                        onSaved: (String? val) {
                                          userService.userProfile.value.username = val!;
                                        },
                                        onChanged: (String val) {
                                          userService.userProfile.value.username = val;
                                        },
                                        decoration: new InputDecoration(
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter Username",
                                          hintStyle: TextStyle(
                                            color: Get.theme.indicatorColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 30.0,
                                        width: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                          child: Text(
                                            "Name",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Get.theme.indicatorColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: userProfileController.nameController,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 14.0,
                                        ),
                                        obscureText: false,
                                        validator: (input) {
                                          String patttern = r'^[a-z A-Z,.\-]+$';
                                          RegExp regExp = new RegExp(patttern);
                                          if (input!.isEmpty) {
                                            return "Name field is required!";
                                          } else if (!regExp.hasMatch(input)) {
                                            return "Please enter valid full name";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        onSaved: (String? val) {
                                          userService.userProfile.value.name = val!;
                                        },
                                        onChanged: (String val) {
                                          userService.userProfile.value.name = val;
                                          print(userService.userProfile.value.name);
                                        },
                                        decoration: new InputDecoration(
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter Your Name",
                                          hintStyle: TextStyle(
                                            color: Get.theme.indicatorColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                            child: Text(
                                              "Email",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Get.theme.indicatorColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 14.0,
                                        ),
                                        obscureText: false,
                                        readOnly: true,
                                        validator: (input) {
                                          Pattern pattern =
                                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                          RegExp regex = new RegExp(pattern.toString());
                                          if (input!.isEmpty) {
                                            return "Email field is required!";
                                          } else if (!regex.hasMatch(input)) {
                                            return "Please enter valid email";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.emailAddress,
                                        controller: userProfileController.emailController,
                                        onSaved: (String? val) {
                                          userService.userProfile.value.email = val!;
                                        },
                                        onChanged: (String val) {
                                          userService.userProfile.value.email = val;
                                        },
                                        decoration: new InputDecoration(
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter Email",
                                          hintStyle: TextStyle(
                                            color: Get.theme.indicatorColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                            child: Text(
                                              "Gender",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Get.theme.indicatorColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          canvasColor: Get.theme.primaryColor,
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: DropdownButtonHideUnderline(
                                            child: new DropdownButton<Gender>(
                                              key: UniqueKey(),
                                              iconEnabledColor: Colors.white,
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                              value: userProfileController.selectedGender,
                                              onChanged: (Gender? newValue) {
                                                userService.userProfile.value.gender = newValue!.value;
                                                setState(() {
                                                  userProfileController.selectedGender = newValue;
                                                });
                                              },
                                              items: userProfileController.genders.map((Gender userGender) {
                                                return new DropdownMenuItem<Gender>(
                                                  value: userGender,
                                                  child: new Text(
                                                    userGender.name,
                                                    textAlign: TextAlign.right,
                                                    style: new TextStyle(
                                                      color: Get.theme.indicatorColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 30.0,
                                        width: 100,
                                        child: Text(
                                          "Mobile",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Get.theme.indicatorColor,
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(13),
                                        ],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 14.0,
                                        ),
                                        validator: (input) {
                                          Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                          RegExp regex = new RegExp(pattern.toString());
                                          /*if (input!.isEmpty) {
                                            return "Mobile field is required!";
                                          } else*/

                                          if (input != "" && !regex.hasMatch(input!)) {
                                            return "Please enter valid mobile no";
                                          } else {
                                            return null;
                                          }
                                        },
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        obscureText: false,
                                        keyboardType: TextInputType.phone,
                                        controller: userProfileController.mobileController,
                                        onSaved: (String? val) {
                                          userService.userProfile.value.mobile = val!;
                                        },
                                        onChanged: (String val) {
                                          userService.userProfile.value.mobile = val;
                                        },
                                        decoration: new InputDecoration(
                                          counterText: '',
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          hintText: "Enter Mobile No.",
                                          hintStyle: TextStyle(
                                            color: Get.theme.indicatorColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 30.0,
                                        width: 100,
                                        child: Text(
                                          "DOB",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Get.theme.indicatorColor,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          DatePicker.showDatePicker(
                                            context,
                                            theme: datePick.DatePickerTheme(
                                              headerColor: Get.theme.indicatorColor,
                                              backgroundColor: Get.theme.highlightColor,
                                              itemStyle: TextStyle(color: Get.theme.indicatorColor, fontWeight: FontWeight.w400, fontSize: 18),
                                              doneStyle: TextStyle(
                                                color: Get.theme.iconTheme.color,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              cancelStyle: TextStyle(
                                                color: Get.theme.iconTheme.color,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            showTitleActions: true,
                                            minTime: minDate,
                                            maxTime: yearBefore,
                                            onConfirm: (date) {
                                              DateTime result;
                                              if (date.year > 0) {
                                                result = DateTime(date.year, date.month, date.day, userService.userProfile.value.dob.hour, userService.userProfile.value.dob.minute);
                                                userService.userProfile.value.dob = result;
                                                userService.userProfile.refresh();
                                              } else {
                                                // The user has hit the cancel button.
                                                result = userService.userProfile.value.dob;
                                              }

                                              userProfileController.onChanged(result);
                                            },
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.en,
                                          );
                                          /*showCupertinoDatePicker(context,
                                                    mode: CupertinoDatePickerMode.date,
                                                    initialDateTime:authService.   userService.userProfile.value.dob,
                                                    leftHanded: false,
                                                    maximumDate: minDate,
                                                    minimumYear: int.parse(minYear),
                                                    maximumYear: int.parse(maxYear), onDateTimeChanged: (DateTime date) {
                                                  DateTime result;
                                                  if (date.year > 0) {
                                                    result = DateTime(date.year, date.month, date.day,authService.   userService.userProfile.value.dob.hour,authService.   userService.userProfile.value.dob.minute);
                                                   authService.   userService.userProfile.value.dob = result;
                                                   authService.   userProfile.refresh();
                                                  } else {
                                                    // The user has hit the cancel button.
                                                    result =authService.   userService.userProfile.value.dob;
                                                  }

                                                });*/
                                        },
                                        child: /*(userService.userProfile.value.dob != null)
                                            ? */
                                            Text(formatterDate.format(userService.userProfile.value.dob),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Get.theme.indicatorColor,
                                                )) /*: Container()*/,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        width: 100,
                                        child: Text(
                                          "Bio",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Get.theme.indicatorColor,
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        textAlign: TextAlign.left,
                                        maxLength: 80,
                                        maxLines: null,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 14.0,
                                        ),
                                        obscureText: false,
                                        keyboardType: TextInputType.multiline,
                                        controller: userProfileController.bioController,
                                        onSaved: (String? val) {
                                          userService.userProfile.value.bio = val!;
                                        },
                                        onChanged: (String val) {
                                          userService.userProfile.value.bio = val;
                                        },
                                        decoration: new InputDecoration(
                                          counterText: "",
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Get.theme.highlightColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          hintText: "Enter Bio (80 chars)",
                                          hintStyle: TextStyle(
                                            color: Get.theme.indicatorColor.withOpacity(0.70),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                child: Center(
                  child: CommonHelper.showLoaderSpinner(
                    Colors.black,
                  ),
                ),
              ),
      ),
    );
  }
}
