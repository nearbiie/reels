class UserVideoArgs {
  int userId;
  int videoId;
  String name = "";
  String hashTag = "";
  String searchType = "";
  UserVideoArgs({this.userId = 0, this.videoId = 0, this.name = "", this.hashTag = "", this.searchType = ""});
}
