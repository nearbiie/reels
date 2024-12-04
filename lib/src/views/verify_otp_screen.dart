import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../core.dart';

class VerifyOTPView extends StatefulWidget {
  @override
  _VerifyOTPViewState createState() => _VerifyOTPViewState();
}

class _VerifyOTPViewState extends State<VerifyOTPView> {
  ScaffoldState scaffold = ScaffoldState();
  UserController userController = Get.find();
  MainService mainService = Get.find();

  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  @override
  void initState() {
    userController.startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.bHideTimer.value = true;
      userController.bHideTimer.refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 16,
          color: Get.theme.indicatorColor, //change your color here
        ),
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
        title: "Email Verification".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
        centerTitle: true,
      ),
      body: Container(
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: Get.height / 3,
                width: Get.height / 3,
                margin: EdgeInsets.only(bottom: 50),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new AssetImage(
                      "assets/images/video-logo.png",
                    ),
                  ),
                ),
              ),
              "Enter 6 digits verification code has sent in your registered email account.".text.color(Get.theme.indicatorColor).lineHeight(1.4).size(16).wide.center.make().centered(),
              SizedBox(
                height: 30,
              ),
              PinCodeTextField(
                backgroundColor: Get.theme.primaryColor,
                appContext: context,
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
                  inactiveColor: Get.theme.highlightColor.withOpacity(0.3),
                  disabledColor: Get.theme.primaryColor,
                  inactiveFillColor: Get.theme.primaryColor,
                  selectedFillColor: Get.theme.primaryColor,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(0),
                  fieldHeight: Get.width * 0.15,
                  fieldWidth: Get.width * 0.15,
                  activeFillColor: Get.theme.primaryColor,
                ),
                cursorColor: Get.theme.shadowColor,
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                // errorAnimationController: errorController,
                // controller: textEditingController,
                keyboardType: TextInputType.number,
                boxShadows: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Get.theme.shadowColor,
                    blurRadius: 10,
                  )
                ],
                onCompleted: (v) {
                  userController.otp = v;

                  userController.verifyOtp();
                },
                onChanged: (value) {
                  userController.otp = value;
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Obx(() => userController.bHideTimer.value
                  ? 'Resend OTP in ${userController.countTimer.value} seconds'.text.color(Get.theme.indicatorColor).lineHeight(1.4).size(16).wide.center.make().centered()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        "Did not get OTP?".text.color(Get.theme.indicatorColor).size(16).wide.center.make(),
                        SizedBox(
                          width: 10,
                        ),
                        "Resend OTP".text.color(mainService.setting.value.buttonColor!).size(16).wide.center.make().onTap(() {
                          userController.resendOtp(verifyPage: true);
                        }),
                      ],
                    )),
            ],
          ),
        ),
      ).pSymmetric(h: 10),
    );
  }
}
