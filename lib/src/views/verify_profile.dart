import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class VerifyProfileView extends StatefulWidget {
  VerifyProfileView({Key? key}) : super(key: key);

  @override
  _VerifyProfileViewState createState() => _VerifyProfileViewState();
}

class _VerifyProfileViewState extends State<VerifyProfileView> {
  var minDate = new DateTime.now().subtract(Duration(days: 29200));
  var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
  var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
  var formatterYear = new DateFormat('yyyy');
  var formatterDate = new DateFormat('dd MMM yyyy');

  String minYear = "";
  String maxYear = "";
  String initDatetime = "";
  UserProfileController userProfileController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  int page = 1;

  @override
  void initState() {
    userProfileController.fetchVerifyInformation();
    minYear = formatterYear.format(minDate);
    maxYear = formatterYear.format(yearBefore);
    initDatetime = formatter.format(yearBefore);
    userProfileController.scrollController = new ScrollController();
    userProfileController.scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_verifyProfilePage');
    userProfileController.formKey = new GlobalKey<FormState>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(Duration(seconds: 2), () => setState(() {}));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    final nameField = TextFormField(
      enabled: userProfileController.verified == 'A' || userProfileController.verified == 'P' ? false : true,
      controller: userProfileController.nameController,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Get.theme.indicatorColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      onSaved: (String? val) {
        userProfileController.name = val!;
      },
      onChanged: (String val) {
        userProfileController.name = val;
        print(userProfileController.name);
      },
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 8, 0, 0),
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade600, width: 0.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainService.setting.value.dividerColor!, width: 0.5),
        ),
        hintText: "Enter Your Name",
        hintStyle: TextStyle(
          color: mainService.setting.value.dividerColor,
        ),
      ),
    );

    final addressField = TextFormField(
      enabled: userProfileController.verified == 'A' || userProfileController.verified == 'P' ? false : true,
      textAlign: TextAlign.left,
      maxLength: 80,
      maxLines: null,
      minLines: 3,
      style: TextStyle(
        color: Get.theme.indicatorColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: userProfileController.addressController,
      onSaved: (String? val) {
        userProfileController.address = val!;
      },
      onChanged: (String val) {
        userProfileController.address = val;
      },
      decoration: new InputDecoration(
        counterText: "",
        errorStyle: TextStyle(
          color: Color(0xFFf5ae78),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade600, width: 0.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainService.setting.value.dividerColor!, width: 0.5),
        ),
        hintText: "Enter Your Address",
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
    AppBar appBar = AppBar(
      elevation: 0,
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(
        size: 16,
        color: Get.theme.indicatorColor, //change your color here
      ),
      backgroundColor: Get.theme.primaryColor,
      title: "Profile Verification".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
      centerTitle: true,
    );
    return Obx(() {
      return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        key: userProfileController.scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: appBar,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: SingleChildScrollView(
            controller: userProfileController.scrollController,
            child: Center(
              child: Container(
                color: Get.theme.primaryColor,
                height: Get.height + appBar.preferredSize.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            children: [
                              Center(
                                child: "STATUS".text.center.wide.color(Get.theme.highlightColor).size(35).make(),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    color: userProfileController.verified == 'A'
                                        ? Colors.blueAccent
                                        : userProfileController.verified == 'R'
                                            ? Colors.redAccent
                                            : Colors.grey,
                                    size: 40,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Center(
                                    child: Text(
                                      "${userProfileController.verifiedText}",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: userProfileController.verified == 'R' ? Colors.redAccent : Get.theme.indicatorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    userProfileController.reason != ''
                        ? Center(
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: Colors.redAccent,
                              )),
                              child: Text(
                                "${userProfileController.reason}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: userProfileController.verified == 'R' ? Colors.redAccent : Get.theme.indicatorColor,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 10),
                    userProfileController.verified == 'A' ? SizedBox(height: 20) : Container(),
                    userProfileController.verified == 'A'
                        ? Container()
                        : Text(
                            "Apply For Profile Verification now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Get.theme.indicatorColor,
                              // color: Colors.pinkAccent,
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 1,
                      color: mainService.setting.value.dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 0,
                      ),
                      child: Container(
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: userProfileController.formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                            child: Text(
                                              "Name",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Get.theme.indicatorColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: Get.width - 150,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                              child: nameField,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 100.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                            child: Text(
                                              "Address",
                                              style: TextStyle(fontSize: 14, color: Get.theme.indicatorColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 100.0,
                                          width: Get.width - 150,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                              child: addressField,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                "Supporting Document ",
                                style: TextStyle(
                                  fontSize: 14,
                                  // color: Colors.pinkAccent,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.03,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Obx(
                                      () => GestureDetector(
                                        onTap: () {
                                          if (userProfileController.verified == 'A' || userProfileController.verified == 'P') {
                                          } else {
                                            // setState(() {
                                            //   _con.document1 = "";
                                            // });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(builder: (context, setState) {
                                                  return AlertDialog(
                                                    backgroundColor: Get.theme.highlightColor,
                                                    title: Text(
                                                      "Choose File",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: Get.theme.primaryColor,
                                                      ),
                                                    ),
                                                    content: Container(
                                                        height: 70,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 20),
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      userProfileController.getDocument1(true);
                                                                      Get.back();
                                                                    },
                                                                    child: Column(
                                                                      children: <Widget>[
                                                                        Icon(
                                                                          Icons.camera_alt,
                                                                          color: Get.theme.primaryColor,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                          child: Text(
                                                                            "Camera",
                                                                            style: TextStyle(
                                                                              color: Get.theme.primaryColor,
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    userProfileController.getDocument1(false);
                                                                    Get.back();
                                                                  },
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Icon(
                                                                        Icons.perm_media,
                                                                        color: Get.theme.primaryColor,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                        child: Text(
                                                                          "Gallery",
                                                                          style: TextStyle(
                                                                            color: Get.theme.primaryColor,
                                                                            fontSize: 14,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )),
                                                  );
                                                });
                                              },
                                            );
                                          }
                                        },
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          strokeWidth: 1,
                                          dashPattern: [3],
                                          radius: Radius.circular(12),
                                          padding: EdgeInsets.all(6),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(12),
                                            ),
                                            child: userProfileController.document1 == ""
                                                ? Container(
                                                    height: Get.height * (0.30),
                                                    width: Get.width * (0.40),
                                                    color: mainService.setting.value.inactiveButtonColor,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          margin: EdgeInsets.all(10),
                                                          padding: EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(100),
                                                            border: Border.all(
                                                              width: 2,
                                                              color: mainService.setting.value.dividerColor!,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Get.theme.primaryColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "Upload Front Side of Id Proof",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Get.theme.primaryColor,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Icon(
                                                          Icons.add_a_photo_outlined,
                                                          color: Get.theme.primaryColor,
                                                          size: 35,
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    height: Get.height * (0.3),
                                                    width: Get.width * (0.40),
                                                    color: Colors.black54,
                                                    child: Uri.parse(userProfileController.document1.value).isAbsolute
                                                        ? CachedNetworkImage(
                                                            imageUrl: userProfileController.document1.value,
                                                            placeholder: (context, url) => CommonHelper.showLoaderSpinner(Colors.white),
                                                            fit: BoxFit.fitWidth,
                                                            alignment: Alignment.center,
                                                          )
                                                        : Image.file(
                                                            File(
                                                              userProfileController.document1.value,
                                                            ),
                                                          ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width * (0.08),
                                    ),
                                    Obx(
                                      () => GestureDetector(
                                        onTap: () {
                                          if (userProfileController.verified == 'A' || userProfileController.verified == 'P') {
                                          } else {
                                            // setState(() {
                                            //   _con.document2 = "";
                                            // });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(builder: (context, setState) {
                                                  return AlertDialog(
                                                    backgroundColor: Get.theme.highlightColor,
                                                    title: Text(
                                                      "Choose File",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: Get.theme.primaryColor,
                                                      ),
                                                    ),
                                                    content: Container(
                                                        height: 70,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 20),
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      userProfileController.getDocument2(true);
                                                                      Get.back();
                                                                    },
                                                                    child: Column(
                                                                      children: <Widget>[
                                                                        Icon(
                                                                          Icons.camera_alt,
                                                                          color: Get.theme.primaryColor,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                          child: Text(
                                                                            "Camera",
                                                                            style: TextStyle(
                                                                              color: Get.theme.primaryColor,
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    userProfileController.getDocument2(false);
                                                                    Get.back();
                                                                  },
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Icon(
                                                                        Icons.perm_media,
                                                                        color: Get.theme.primaryColor,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                        child: Text(
                                                                          "Gallery",
                                                                          style: TextStyle(
                                                                            color: Get.theme.primaryColor,
                                                                            fontSize: 14,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )),
                                                  );
                                                });
                                              },
                                            );
                                          }
                                        },
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          strokeWidth: 1,
                                          dashPattern: [3],
                                          radius: Radius.circular(12),
                                          padding: EdgeInsets.all(6),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(12),
                                            ),
                                            child: userProfileController.document2 == ""
                                                ? Container(
                                                    height: Get.height * (0.3),
                                                    width: Get.width * (0.40),
                                                    color: mainService.setting.value.inactiveButtonColor,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          margin: EdgeInsets.all(10),
                                                          padding: EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(100),
                                                            border: Border.all(
                                                              width: 2,
                                                              color: mainService.setting.value.dividerColor!,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Get.theme.iconTheme.color,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "Upload Back Side of Id Proof",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Get.theme.primaryColor,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Icon(
                                                          Icons.add_a_photo_outlined,
                                                          color: Get.theme.primaryColor,
                                                          size: 35,
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    height: Get.height * (0.3),
                                                    width: Get.width * (0.40),
                                                    color: Get.theme.primaryColor.withOpacity(0.6),
                                                    child: Uri.parse(userProfileController.document2.value).isAbsolute
                                                        ? Image.network(
                                                            userProfileController.document2.value,
                                                            alignment: Alignment.center,
                                                          )
                                                        : Image.file(
                                                            File(
                                                              userProfileController.document2.value,
                                                            ),
                                                          ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  print("userProfileController.verified ${userProfileController.verified}");
                                  if (userProfileController.verified == 'A' || userProfileController.verified == 'P') {
                                  } else {
                                    userProfileController.updateVerifyProfile();
                                  }
                                },
                                child: Container(
                                  height: 60,
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Get.theme.highlightColor,
                                  ),
                                  child: "${userProfileController.submitText}".text.uppercase.size(20).center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 10, v: 15),
                                ).pSymmetric(h: 20),
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
          ),
        ),
      );
    });
  }
}
