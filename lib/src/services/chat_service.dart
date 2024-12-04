import 'package:get/get.dart';

import '../core.dart';

class ChatService extends GetxService {
  // var chats = List<Chat>().obs;
  // var myConversations = <Conversation>[].obs;

  // var openChatRooms = <Chat>[].obs;
  var chatsCount = 0.obs;
  var currentConversation = Conversation().obs;
  var currentChatRequestMessage = "".obs;
  var showSendInterest = false.obs;
  // var currentChat = ChatRoom().obs;
  var activeChats = [].obs;
  var onlineUserIds = <int>[].obs;
  var users = <User>[].obs;
  var frequentlyContactedPersons = <User>[].obs;
  var unreadMessageCount = 0.obs;
  var onlineUsers = <User>[].obs;
  // var chats = <Conversation>[].obs;
  var conversations = ConversationsModel().obs;
  var peopleData = FollowingModel().obs;
  var chatService = FollowingModel().obs;
  var showTyping = false.obs;
  var chatSettings = ''.obs;
  var conversationUser = User().obs;
  // int convId = 0;
}
