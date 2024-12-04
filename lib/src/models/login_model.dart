import 'package:get/get.dart';

import '../core.dart';

class LoginModel {
  String status = "";
  User? data = User();

  LoginModel({this.data, this.status = ""});

  factory LoginModel.fromJSON(Map<String, dynamic> json) {
    return LoginModel(
      data: json['content'] != null ? User.fromJSON(json['content']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LoginData {
  AuthService authService = Get.find();
  int userId = 0;
  String name = "";
  String accessToken = '';
  String email = "";
  String username = "";
  String userDP = "";
  int isAnyUserFollow = 0;
  bool auth = false;
  bool isVerified = false;
  String loginType = "O";

  LoginData();

  LoginData.fromJSON(Map<String, dynamic> json) {
    if (json != {}) {
      // try {
      userId = json['user_id'] ?? 0;
      name = json['fname'] != null ? json['fname'] + " " + (json['lname'] ?? '') : '';
      username = json['username'] ?? '';
      email = json['email'] ?? '';
      if (json['app_token'] != null) {
        accessToken = json['app_token'] ?? '';
      } else if (authService.currentUser.value.accessToken != '') {
        accessToken = authService.currentUser.value.accessToken;
      } else {
        accessToken = "";
      }
      userDP = json['user_dp'] != null ? json['user_dp'] : '';
      isVerified = json['isVerified'] != null
          ? json['isVerified'] == 1
              ? true
              : false
          : false;
      isAnyUserFollow = json['is_following_videos'] != null ? json['is_following_videos'] : 0;
      loginType = json['login_type'] ?? 'O';
      // } catch (e) {
      //   name = "";
      //   userName = "";
      //   email = "";
      //   token = "";
      //   print(e);
      // }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.username;
    data['token'] = this.accessToken;
    data['email'] = this.email;
    data['name'] = this.name;
    data['userDP'] = this.userDP;
    data['isAnyUserFollow'] = this.isAnyUserFollow;
    data['isVerified'] = this.isVerified;
    return data;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['userName'] = username;
    map['token'] = accessToken;
    map['email'] = email;
    map['name'] = name;
    map['userDP'] = userDP;
    map['isAnyUserFollow'] = isAnyUserFollow;
    map['isVerified'] = isVerified;
    return map;
  }

  Map<String, dynamic> toSocialLoginMap(profile, timezone, type) {
    var map = new Map<String, dynamic>();

    map['fname'] = profile['first_name'] != null ? profile['first_name'] : "";
    map['lname'] = profile['last_name'] != null ? profile['last_name'] : "";
    map['email'] = profile['email'] != null ? profile['email'] : "";
    // map['email'] = "";
    map['gender'] = profile['gender'] != null ? profile['gender'] : "";
    if (type == "FB") {
      map['user_dp'] = profile['picture']['data']['url'] != null ? profile['picture']['data']['url'] : "";
    } else {
      map['user_dp'] = profile['user_dp'] != null ? profile['user_dp'] : "";
    }

    map['dob'] = profile['birthday'] != null ? profile['birthday'] : "";
    map['time_zone'] = timezone;
    map['login_type'] = type;
    map['ios_uuid'] = profile['ios_uuid'] != null ? profile['ios_uuid'] : "";
    map['ios_email'] = profile['ios_email'] != null ? profile['ios_email'] : "";
    print("profile map");
    print(map);
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }
}
