import 'package:get/get.dart';

import '../core.dart';

class User {
  int id = 0;
  String name = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String username = "";
  String mobile = "";
  String gender = "";
  String bio = "";
  String dp = "";
  DateTime dob = DateTime.now();
  String accessToken = "";
  String userDP = "";
  String country = "";
  String largeProfilePic = "";
  String smallProfilePic = "";
  String loginType = "O";
  int isAnyUserFollow = 0;
  int convId = 0;
  List<Video> userVideos = [];
  List<Video> userFavoriteVideos = [];
  int totalUserFavoriteVideos = 0;
  String followText = "";
  bool online = false;
  String blocked = "";
  int totalRecords = 0;
  String totalVideosLike = "0";
  String totalFollowings = "0";
  String totalFollowers = "0";
  int totalVideos = 0;
  String appVersion = "";
  bool isVerified = false;
  User();

  User.fromJSON(Map<String, dynamic> json) {
    print("User.fromJSON json $json ${json['user_id']}");
    try {
      id = json['user_id'];
      firstName = json['fname'] ?? "";
      lastName = json['lname'] != null ? json['lname'] : '';
      name = json['name'] ?? firstName + " " + lastName;
      username = json['username'];
      email = json['email'] ?? "";
      mobile = json['mobile'] != null ? json['mobile'] : '';
      gender = json['gender'] != null ? json['gender'] : '';
      bio = json['bio'] != null ? json['bio'] : '';
      dp = json['user_dp'] != null ? json['user_dp'] : '';
      largeProfilePic = json['large_pic'] != null ? json['large_pic'] : '';
      smallProfilePic = json['small_pic'] != null ? json['small_pic'] : '';
      accessToken = json['app_token'] != null ? json['app_token'] : '';
      blocked = json['blocked'] != null ? json['blocked'] : '';
      dob = json['dob'] != null ? DateTime.parse(json['dob']) : DateTime.now();
      country = json['country'] != null ? json['country'] : '';
      userVideos = json['data'] != null ? parseVideos(json['data']) : [];
      userDP = json['user_dp'] != null ? json['user_dp'] : '';
      isAnyUserFollow = json['is_following_videos'] != null ? json['is_following_videos'] : 0;
      totalRecords = json['totalRecords'] ?? 0;
      totalVideosLike = (json['totalVideosLike'] ?? 0).toString();
      totalFollowings = (json['totalFollowings'] ?? 0).toString();
      totalFollowers = (json['totalFollowers'] ?? 0).toString();
      totalVideos = json['totalVideos'] ?? 0;
      loginType = json['login_type'] ?? 'O';
      followText = json['followText'] ?? 'Follow'.tr;
    } catch (e, s) {
      print("userDataError $e $s");
      id = 0;
      firstName = '';
      lastName = '';
      name = '';
      username = '';
      email = '';
      mobile = '';
      gender = '';
      bio = '';
      dp = '';
      largeProfilePic = '';
      smallProfilePic = '';
      dob = DateTime.now();
      country = '';
    }
  }
  static List<Video> parseVideos(attributesJson) {
    print("parseAttributes");
    List list = attributesJson;
    List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
    return attrList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['gender'] = this.gender;
    data['bio'] = this.bio;
    data['dob'] = this.dob.toString();
    return data;
  }
}
