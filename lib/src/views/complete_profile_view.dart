import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datePick;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class CompleteProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey = GlobalKey<ScaffoldState>();

  CompleteProfileView({
    Key? key,
  }) : super(key: key);

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> with SingleTickerProviderStateMixin {
  UserController userController = Get.find();
  AuthService authService = Get.find();
  MainService mainService = Get.find();

  late AnimationController animationController;
  var minDate = new DateTime.now().subtract(Duration(days: 29200));
  var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
  var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
  var formatterYear = new DateFormat('yyyy');
  var formatterDate = new DateFormat('dd MMM yyyy');

  String minYear = "";
  String maxYear = "";
  String initDatetime = "";

  @override
  void initState() {
    minYear = formatterYear.format(minDate);
    maxYear = formatterYear.format(yearBefore);
    initDatetime = formatterDate.format(yearBefore);
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    // if (authService.socialUserProfile.value.name != "") {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("widget.email ${userController.email.value} widget.fullName ${userController.fullName.value}");
      // setState(() {
      userController.showLoader.value = false;
      userController.showLoader.refresh();
      userController.completeProfile = authService.socialUserProfile.value;
      userController.fullName = userController.fullName;
      userController.fullNameController.value = TextEditingController(text: userController.fullName.value);
      userController.email = userController.email;
      userController.profileEmailController.value = TextEditingController(text: userController.email.value);
      userController.loginType = userController.loginType;
      if (authService.socialUserProfile.value.email == "") {
      } else {
        userController.profileEmailController.value = TextEditingController(text: authService.socialUserProfile.value.email);
      }
      setState(() {});
      // });
    });
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () {
        if (EasyLoading.isShow || userController.showLoader.value) {
          EasyLoading.dismiss();
          userController.showLoader.value = false;
          userController.showLoader.refresh();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: Get.theme.primaryColor,
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
            title: "Complete Profile".text.uppercase.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus!.unfocus();
                  print("userController.loginType ${userController.loginType}");
                  if (userController.loginType == 'O') {
                    await userController.register();
                  } else {
                    userController.registerSocial();
                  }
                },
                icon: Icon(
                  Icons.check,
                  color: mainService.setting.value.buttonColor,
                ),
              ),
            ],
          ),
          key: userController.completeProfileScaffoldKey,
          body: editProfilePanel(),
        ),
      ),
    );
  }

  Widget editProfilePanel() {
    return SingleChildScrollView(
      child: Container(
        color: Get.theme.primaryColor,
        child: Form(
          key: userController.completeProfileFormKey,
          child: Column(
            children: <Widget>[
              Container(
                height: Get.height * (0.25),
                width: Get.width,
                color: Get.theme.shadowColor.withOpacity(0.3),
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                              backgroundColor: Get.theme.primaryColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 75,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 0.5,
                                        color: Get.theme.dividerColor,
                                      ),
                                    ),
                                    color: Get.theme.primaryColor,
                                  ),
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Get.back();
                                              userController.getImageOption(true);
                                            },
                                            child: SvgPicture.asset(
                                              'assets/icons/camera.svg',
                                              width: 40.0,
                                              colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.back();
                                              userController.getImageOption(false);
                                            },
                                            child: SvgPicture.asset(
                                              'assets/icons/image-gallery.svg',
                                              width: 40.0,
                                              colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
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
                                                          iconTheme: IconThemeData(
                                                            color: Get.theme.iconTheme.color, //change your color here
                                                          ),
                                                          backgroundColor: Get.theme.primaryColor,
                                                          title: "Profile Picture".text.textStyle(Get.theme.textTheme.bodyLarge!.copyWith(fontSize: 18)).make(),
                                                          centerTitle: true,
                                                        ),
                                                      ),
                                                      backgroundColor: Get.theme.primaryColor,
                                                      body: Center(
                                                        child: PhotoView(
                                                          enableRotation: true,
                                                          imageProvider: authService.socialUserProfile.value.userDP != ''
                                                              ? CachedNetworkImageProvider(authService.socialUserProfile.value.userDP)
                                                              : AssetImage("assets/images/default-user.png") as ImageProvider,
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
                                                  width: 40.0,
                                                  colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                                ),
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
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                            border: new Border.all(
                              color: Get.theme.dividerColor,
                              width: 5.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              height: Get.height * 0.2,
                              width: Get.height * 0.2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: userController.selectedDp.value.path != ''
                                      ? FileImage(
                                          userController.selectedDp.value,
                                        )
                                      : authService.socialUserProfile.value.userDP != ''
                                          ? CachedNetworkImageProvider(
                                              authService.socialUserProfile.value.userDP,
                                            )
                                          : AssetImage("assets/images/default-user.png") as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 15,
                        child: SvgPicture.asset(
                          'assets/icons/camera.svg',
                          width: 28.0,
                          colorFilter: ColorFilter.mode(Get.theme.dividerColor, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => TextFormField(
                  controller: userController.fullNameController.value,
                  style: Get.textTheme.titleMedium,
                  validator: (value) {
                    return userController.validateField(value!, "Full Name");
                  },
                  keyboardType: TextInputType.text,
                  onChanged: (String val) {
                    userController.fullName.value = val;
                  },
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 2.0,
                    ),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                  ),
                ).pSymmetric(h: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.multiline,
                  controller: userController.profileEmailController.value,
                  enabled: userController.email == "" ? true : false,
                  style: Get.textTheme.titleMedium,
                  validator: (value) {
                    return userController.validateEmail(value!);
                  },
                  onSaved: (String? val) {
                    userController.email.value = val!;
                  },
                  onChanged: (String val) {
                    userController.email.value = val;
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                  ),
                ).pSymmetric(h: 20),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                controller: userController.profileUsernameController,
                style: Get.textTheme.titleMedium,
                validator: (value) {
                  return userController.validateField(value!, "Username");
                },
                onSaved: (String? val) {
                  userController.username = val!;
                },
                onChanged: (String val) {
                  userController.username = val;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  labelText: "Username",
                  labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                ),
              ).pSymmetric(h: 20),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                readOnly: true,
                controller: userController.conDob..text,
                style: Get.textTheme.titleMedium,
                keyboardType: TextInputType.text,
                validator: (input) {
                  if (userController.profileDOBString == '') {
                    return "Date of birth field is required!";
                  } else {
                    return null;
                  }
                },
                onTap: () {
                  FocusScope.of(context).unfocus();
                  DatePicker.showDatePicker(
                    context,
                    theme: datePick.DatePickerTheme(
                      headerColor: Get.theme.primaryColor,
                      backgroundColor: Get.theme.primaryColor,
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
                      userController.conDob..text = userController.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                      userController.profileDOBString = userController.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                    },
                    currentTime: DateTime.now(),
                    locale: LocaleType.en,
                  );
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  labelText: "Date of Birth",
                  labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                ),
              ).pSymmetric(h: 20),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                controller: userController.passwordController,
                style: Get.textTheme.titleMedium,
                validator: (value) {
                  return userController.validateField(value!, "Password");
                },
                obscureText: true,
                onSaved: (String? val) {
                  userController.password = val!;
                },
                onChanged: (String val) {
                  userController.password = val;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  labelText: "Password",
                  labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                ),
              ).pSymmetric(h: 20),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                controller: userController.confirmPasswordController,
                style: Get.textTheme.titleMedium,
                validator: (value) {
                  return userController.validateField(value!, "Confirm Password");
                },
                onSaved: (String? val) {
                  userController.confirmPassword = val!;
                },
                onChanged: (String val) {
                  userController.confirmPassword = val;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                  labelText: "Confirm Password",
                  labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                ),
              ).pSymmetric(h: 20),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Theme(
                  data: ThemeData(
                    // backgroundColor: Get.theme.primaryColor,
                    textTheme: TextTheme(
                      titleMedium: TextStyle(
                        // color: mainService.setting.value.dividerColor,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      fillColor: Get.theme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DropdownSearch<Gender>(
                      popupProps: PopupProps.bottomSheet(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: Get.theme.dividerColor)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Get.theme.dividerColor)),
                          labelText: "Select Gender",
                          labelStyle: TextStyle(color: Get.theme.hintColor, fontSize: 16),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      items: userController.gender,
                      // mode: Mode.BOTTOM_SHEET,
                      // popupBackgroundColor: Get.theme.shadowColor,
                      // popupBarrierColor: mainService.setting.value.dividerColor != null ? mainService.setting.value.dividerColor!.withOpacity(0.2) : Colors.grey[200],
                      itemAsString: (Gender? u) => u!.name,
                      onChanged: (Gender? data) {
                        userController.selectedGender.value = data!.value;
                        userController.selectedGender.refresh();
                      },
                    ),
                  ),
                ).pSymmetric(h: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
