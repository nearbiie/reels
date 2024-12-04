class CommentModel {
  bool status = false;
  List<CommentData> comments = [];
  int totalRecords = 0;

  CommentModel();

  CommentModel.fromJSON(Map<String, dynamic> json) {
    try {
      comments = json['data'] != null ? CommentModel.parseComments(json['data']) : [];
      status = json['status'] ?? false;
      totalRecords = json['total_records'] ?? 0;
    } catch (e) {
      print("CommentModel.fromJSON" + e.toString());
    }
  }

/*  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }*/

  static List<CommentData> parseComments(attributesJson) {
    print("attributesJson $attributesJson");
    List list = attributesJson;
    List<CommentData> attrList = list.map((data) => CommentData.fromJSON(data)).toList();
    return attrList;
  }
}

class CommentData {
  int commentId = 0;
  int userId = 0;
  String username = "";
  bool isVerified = false;
  String userDp = "";
  String comment = "";
  String time = "";
  int videoId = 0;
  int streamId = 0;
  String accessToken = "";
  CommentData();

  CommentData.fromJSON(Map<String, dynamic> json) {
    print("CommentData.fromJSON json $json");
    try {
      commentId = json['comment_id'] ?? 0;
      userId = json['user_id'] ?? 0;
      videoId = json['video_id'] ?? 0;
      streamId = json['stream_id'] ?? 0;
      username = json['name'] ?? json['username'] ?? '';
      comment = json['comment'] ?? '';
      userDp = json['pic'] ?? '';
      time = json['timing'] ?? json['added_on'] ?? '';
      isVerified = json['isVerified'] != null
          ? json['isVerified'] == 1
              ? true
              : false
          : false;
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.username;
    data['commentId'] = this.commentId;
    data['comment'] = this.comment;
    data['time'] = this.time;
    data['userDp'] = this.userDp;
    data['videoId'] = this.videoId;
    data['token'] = this.accessToken;
    data['isVerified'] = this.isVerified;
    return data;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['userName'] = username;
    map['commentId'] = commentId;
    map['comment'] = comment;
    map['time'] = time;
    map['userDp'] = userDp;
    map['isVerified'] = isVerified;
    return map;
  }
}
