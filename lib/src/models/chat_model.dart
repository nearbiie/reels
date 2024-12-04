import '../core.dart';

class ChatModel {
  var formatterTime = new DateFormat('hh:mm a');
  var formatterDate = new DateFormat('dd MMM yyyy');
  int totalChat = 0;
  List<ChatMessage> chatMessages = [];

  ChatModel();

  ChatModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      totalChat = jsonMap['total'] ?? 0;
      chatMessages = jsonMap['data'] != null ? parseData(jsonMap['data']) : [];
    } catch (e) {
      totalChat = 0;
      chatMessages = [];
    }
  }

  static List<ChatMessage> parseData(jsonData) {
    List list = jsonData;
    List<ChatMessage> attrList = list.map((data) => ChatMessage.fromJSON(data)).toList();
    return attrList;
  }
}
