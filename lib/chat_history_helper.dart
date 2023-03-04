

// a chat history helper, the messages are stored in a on SharedPreferences use PrefsHelper
import 'package:chat_boot_app/prefs_helper.dart';
import 'package:chat_boot_app/type_util.dart';
import 'package:chat_boot_app/model.dart';

class ChatHistoryHelper {

  static const String _key = 'chat_history';

  static List<ChatMessage> getChatHistory() {
    final list = PrefsHelper.getStringList(_key);
    return list.map((e) => ChatMessage.fromMap(TypeUtil.parseMap(e))).toList();
  }

  static void saveChatHistory(List<ChatMessage> messageList) {
    PrefsHelper.setStringList(_key, messageList.map((e) => TypeUtil.parseString(e.toMap())).toList());
  }

  static void clearChatHistory() {
    PrefsHelper.setStringList(_key, []);
  }
}