import 'dart:convert';

import '../core.dart';

class ConversationsModel {
  int total = 0;
  List<Conversation> data = [];
  ConversationsModel();
  ConversationsModel.fromJSON(Map<String, dynamic> json) {
    try {
      total = json['totalRecords'] ?? 0;
      data = json['data'] != null ? parseData(json['data']) : [];
    } catch (e, s) {
      total = 0;
      data = [];
      print("Exception:  $e $s");
    }
  }
  static List<Conversation> parseData(jsonData) {
    List _list = jsonData;
    List<Conversation> list = _list.map((data) => Conversation.fromJSON(data)).toList();
    return list;
  }
}

class Conversation {
  int id = 0;
  int userId = 0;
  String personName = '';
  String username = '';
  String userDp = '';
  String message = '';
  String time = '';
  bool online = false;
  bool isRead = false;
  List<ChatMessage> messages = [];
  int totalMessages = 0;

  Conversation({
    this.id = 0,
    this.userId = 0,
    this.personName = "",
    this.username = "",
    this.userDp = "",
    this.message = "",
    this.time = "",
    this.online = false,
    this.isRead = false,
    this.messages = const [],
    this.totalMessages = 0,
  });
  Conversation.fromJSON(Map<String, dynamic> json) {
    print("Conversation.fromJSON $json");
    var data;
    if (json['data'] != null) {
      data = jsonDecode(json['data']);
      // data = json['data'];
    }
    if (data == null) {
      data = json;
    }
    try {
      id = data["id"] ?? 0;
      userId = data["user_id"] ?? 0;
      personName = data["person_name"] ?? '';
      username = data["username"] ?? '';
      userDp = data["user_dp"] ?? '';
      message = data["message"] ?? '';
      time = data["time"] ?? '';
      online = data["online"] == 0 || data["online"] == null ? false : true;
      isRead = data["isRead"] == 0 || data["isRead"] == null ? false : true;
      totalMessages = data["totalMessages"] == null ? 0 : int.parse(data["totalMessages"].toString());
      messages = data['messages'] != null ? ChatMessage.parseData(data['messages']) : [];
    } catch (e, s) {
      id = 0;
      userId = 0;
      personName = '';
      username = '';
      userDp = '';
      message = '';
      time = '';
      online = false;
      isRead = false;
      print("Exceptionsssssssssss: $e $s");
    }
  }
}
