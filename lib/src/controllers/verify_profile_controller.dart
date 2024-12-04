import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../core.dart';

class VerifyProfileController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PanelController pc = new PanelController();
  var showLoader = false.obs;
  final picker = ImagePicker();

  Gender selectedGender = Gender("M", "Male");
  String name = '';
  String address = '';
  String document1 = '';
  String document2 = '';
  String verified = '';
  String verifiedText = '';
  String submitText = 'Submit';
  String emailErr = '';
  String nameErr = '';
  String addressErr = '';
  String document1Err = '';
  String reason = '';
  ScrollController scrollController = ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  UserController userCon = UserController();
  VerifyProfileModel verifyProfileCon = new VerifyProfileModel();
  var reload = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
