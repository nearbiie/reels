import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class ChangePasswordView extends StatefulWidget {
  // final GlobalKey<ScaffoldState> parentScaffoldKey;
  ChangePasswordView({Key? key}) : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  UserProfileController userProfileController = Get.find();
  MainService mainService = Get.find();
  int page = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    final currentPasswordField = Obx(
      () => TextFormField(
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Get.theme.indicatorColor,
          fontSize: 14.0,
        ),
        obscureText: userProfileController.hideCurrentPassword.value,
        validator: (input) {
          if (input!.isEmpty) {
            return "Current Password field is required!";
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.text,
        controller: userProfileController.currentPasswordController,
        onSaved: (String? val) {
          userProfileController.currentPassword = val!;
        },
        onChanged: (String val) {
          userProfileController.currentPassword = val;
        },
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              userProfileController.hideCurrentPassword.value = !userProfileController.hideCurrentPassword.value;
              userProfileController.hideCurrentPassword.refresh();
            },
            color: Get.theme.highlightColor,
            icon: Icon(!userProfileController.hideCurrentPassword.value ? Icons.visibility : Icons.visibility_off),
          ),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          labelText: "Current Password",
          labelStyle: TextStyle(
            color: Get.theme.indicatorColor.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
    final newPasswordField = Obx(
      () => TextFormField(
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Get.theme.indicatorColor,
          fontSize: 14.0,
        ),
        obscureText: userProfileController.hideNewPassword.value,
        validator: (input) {
          if (input!.isEmpty) {
            return "New Password field is required!";
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.text,
        controller: userProfileController.newPasswordController,
        onSaved: (String? val) {
          userProfileController.newPassword = val!;
        },
        onChanged: (String val) {
          userProfileController.newPassword = val;
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
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          labelText: "New Password",
          labelStyle: TextStyle(
            color: Get.theme.indicatorColor.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              userProfileController.hideNewPassword.value = !userProfileController.hideNewPassword.value;
              userProfileController.hideNewPassword.refresh();
            },
            color: Get.theme.highlightColor,
            icon: Icon(!userProfileController.hideNewPassword.value ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
    );
    final confirmPasswordField = Obx(
      () => TextFormField(
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Get.theme.indicatorColor,
          fontSize: 14.0,
        ),
        obscureText: userProfileController.hideConfirmPassword.value,
        validator: (input) {
          if (input!.isEmpty) {
            return "Confirm Password field is required!";
          } else if (input != userProfileController.newPassword) {
            return "Password doesn't match!";
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.text,
        controller: userProfileController.confirmPasswordController,
        onSaved: (String? val) {
          userProfileController.confirmPassword = val!;
        },
        onChanged: (String val) {
          userProfileController.confirmPassword = val;
        },
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              userProfileController.hideConfirmPassword.value = !userProfileController.hideConfirmPassword.value;
              userProfileController.hideConfirmPassword.refresh();
            },
            color: Get.theme.highlightColor,
            icon: Icon(!userProfileController.hideConfirmPassword.value ? Icons.visibility : Icons.visibility_off),
          ),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: mainService.setting.value.buttonColor!,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          labelText: "Confirm Password",
          labelStyle: TextStyle(
            color: Get.theme.indicatorColor.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () {
        userProfileController.hideNewPassword.value = true;
        userProfileController.hideConfirmPassword.value = true;
        userProfileController.hideCurrentPassword.value = true;
        userProfileController.currentPassword = "";
        userProfileController.currentPasswordController = TextEditingController(text: "");
        userProfileController.newPassword = "";
        userProfileController.newPasswordController = TextEditingController(text: "");
        userProfileController.confirmPassword = "";
        userProfileController.confirmPasswordController = TextEditingController(text: "");
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Get.theme.primaryColor,
        key: userProfileController.scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          leading: InkWell(
            onTap: () {
              userProfileController.hideNewPassword.value = true;
              userProfileController.hideConfirmPassword.value = true;
              userProfileController.hideCurrentPassword.value = true;
              userProfileController.currentPassword = "";
              userProfileController.currentPasswordController = TextEditingController(text: "");
              userProfileController.newPassword = "";
              userProfileController.newPasswordController = TextEditingController(text: "");
              userProfileController.confirmPassword = "";
              userProfileController.confirmPasswordController = TextEditingController(text: "");
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Get.theme.iconTheme.color,
            ),
          ),
          title: "Change Password".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.all(13),
              onPressed: () {
                if (userProfileController.formKey.currentState!.validate()) {
                  userProfileController.changePassword();
                }
              },
              icon: SvgPicture.asset(
                'assets/icons/update.svg',
                colorFilter: ColorFilter.mode(Get.theme.highlightColor, BlendMode.srcIn),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: Get.theme.primaryColor,
              height: Get.height,
              child: Column(
                children: <Widget>[
                  ClipPath(
                    clipper: CurveDownClipper(),
                    child: Container(
                      color: Get.theme.shadowColor,
                      height: Get.height * (0.20),
                      width: Get.width,
                      child: SvgPicture.asset(
                        'assets/icons/lock.svg',
                        width: 80,
                        colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                      ).centered(),
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
                            SizedBox(
                              height: 20,
                            ),
                            currentPasswordField,
                            SizedBox(
                              height: 20,
                            ),
                            newPasswordField,
                            SizedBox(
                              height: 20,
                            ),
                            confirmPasswordField
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
  }
}
