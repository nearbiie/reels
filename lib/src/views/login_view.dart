import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class LoginView extends GetView<UserController> {
  LoginView({Key? key}) : super(key: key);
  final MainService mainService = Get.find();
  final AuthService authService = Get.find();
  final DashboardController dashboardController = Get.find();
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );

    return GetBuilder<UserController>(
      initState: (_) => controller.getLoginPageData(),
      builder: (logic) {
        return WillPopScope(
          onWillPop: () {
            dashboardController.getVideos();
            Get.offNamed('/home');
            return Future.value(false);
          },
          child: Container(
            color: Get.theme.primaryColor,
            child: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Get.theme.primaryColor,
                  titleSpacing: 0.0,
                  automaticallyImplyLeading: true,
                  title: "Log In".text.uppercase.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
                  centerTitle: true,
                  leading: InkWell(
                    onTap: () {
                      dashboardController.getVideos();
                      Get.offNamed('/home');
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Get.theme.iconTheme.color,
                    ),
                  ),
                ),
                backgroundColor: Get.theme.primaryColor,
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: SingleChildScrollView(
                    controller: controller.scrollController1,
                    child: Obx(
                      () => Container(
                        color: Get.theme.primaryColor,
                        width: Get.width,
                        height: Get.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              color: glShadeColor,
                              width: Get.width,
                              child: Obx(
                                () => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height:
                                          mainService.loginPageData.value.appleLogin == true || mainService.loginPageData.value.googleLogin == true || mainService.loginPageData.value.fbLogin == true
                                              ? 12
                                              : 0,
                                    ),
                                    mainService.loginPageData.value.fbLogin == true
                                        ? ButtonTheme(
                                            height: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Color(0xff4064AC),
                                                backgroundColor: Color(0xff4064AC),
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/small-fb.png',
                                                    width: 22,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  "Sign up with Facebook".text.textStyle(Get.theme.textTheme.titleMedium).color(Colors.white).center.make(),
                                                ],
                                              ),
                                              onPressed: () {
                                                controller.loginWithFB();
                                              },
                                            ),
                                          ).pOnly(bottom: 12)
                                        : SizedBox(),
                                    mainService.loginPageData.value.googleLogin == true
                                        ? ButtonTheme(
                                            height: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/small-google.png',
                                                    width: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  "Sign up with Google".text.center.make(),
                                                ],
                                              ),
                                              onPressed: () {
                                                controller.loginWithGoogle();
                                              },
                                            ),
                                          ).pOnly(bottom: 12)
                                        : SizedBox(),
                                    Platform.isIOS && mainService.loginPageData.value.appleLogin == true
                                        ? ButtonTheme(
                                            height: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                // backgroundColor: Color(0xff000000),
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                    'assets/icons/apple.svg',
                                                    width: 25.0,
                                                    colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcATop),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  "Sign up with Apple".text.center.make(),
                                                ],
                                              ),
                                              onPressed: () {
                                                controller.signInWithApple();
                                              },
                                            ),
                                          ).pOnly(bottom: 12)
                                        : SizedBox()
                                  ],
                                ).px16(),
                              ),
                            ),
                            Container(
                              color: Get.theme.primaryColor,
                              width: Get.width,
                              // height: Get.height * 0.66,
                              child: Form(
                                autovalidateMode: AutovalidateMode.always,
                                key: controller.loginFormKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Obx(
                                      () => TextFormField(
                                        style: Get.textTheme.titleMedium,
                                        keyboardType: TextInputType.emailAddress,
                                        onChanged: (input) {
                                          controller.email.value = input;
                                        },
                                        validator: controller.validateEmail,
                                        decoration: InputDecoration(
                                          labelText: "Email",
                                          labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                                          contentPadding: EdgeInsets.zero,
                                          suffixIcon: controller.isValidEmail.value
                                              ? Icon(
                                                  Icons.check,
                                                  color: glSuccessColor,
                                                )
                                              : null,
                                          border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    TextFormField(
                                      style: Get.textTheme.titleMedium,
                                      keyboardType: TextInputType.text,
                                      onChanged: (input) {
                                        controller.password = input;
                                      },
                                      validator: (input) {
                                        if (input!.isEmpty) {
                                          return "Please enter your password!";
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: controller.hidePassword.value,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                                        contentPadding: EdgeInsets.zero,
                                        hintStyle: TextStyle(color: Get.theme.hintColor),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            controller.hidePassword.value = !controller.hidePassword.value;
                                            controller.hidePassword.refresh();
                                          },
                                          color: Get.theme.highlightColor,
                                          icon: Icon(!controller.hidePassword.value ? Icons.visibility : Icons.visibility_off),
                                        ),
                                        border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: "Continue".text.center.make(),
                                      onPressed: () {
                                        if (controller.loginFormKey.currentState!.validate()) {
                                          controller.login();
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: "Forgot Password?".text.textStyle(Get.theme.textTheme.titleSmall).letterSpacing(1).make().onTap(() {
                                            Get.offNamed('/forgot-password');
                                          }),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/skip.svg",
                                                width: 18,
                                                height: 18,
                                              ).pOnly(right: 6),
                                              "Skip".text.textStyle(Get.theme.textTheme.titleSmall).make().centered().onTap(() {
                                                dashboardController.getVideos();
                                                Get.offNamed('/home');
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        "Don't have an account?".text.textStyle(Get.theme.textTheme.titleSmall).make().pOnly(right: 5),
                                        "Create an account".text.textStyle(Get.theme.textTheme.titleSmall).bold.make().onTap(() {
                                          Get.offNamed('/register');
                                        }),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        GestureDetector(
                                            onTap: () {
                                              controller.launchURL("${baseUrl}terms");
                                            },
                                            child: "Terms of use".text.textStyle(Get.theme.textTheme.titleSmall).make().centered()),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 17,
                                          color: Get.theme.dividerColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              controller.launchURL(baseUrl + "privacy-policy");
                                            },
                                            child: "Privacy Policy".text.textStyle(Get.theme.textTheme.titleSmall).make().centered()),
                                      ],
                                    ),
                                  ],
                                ),
                              ).px20(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }
}
