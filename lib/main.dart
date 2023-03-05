
import 'package:chat_boot_app/chat_history_helper.dart';
import 'package:chat_boot_app/http_tool.dart';
import 'package:chat_boot_app/prefs_helper.dart';
import 'package:chat_boot_app/widget/input_dialog.dart';
import 'package:dog/dog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsHelper.init();
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Boot App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Insert this line
      supportedLocales: [Locale("zh", "CN"), Locale("en", "US")],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();

    _messages.addAll(ChatHistoryHelper.getChatHistory());
    dog.d('$_messages');
  }


  void _sendQuestion(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(author: 'User', content: text, timeStamp: DateTime.now()));
      ChatHistoryHelper.saveChatHistory(_messages);
    });
    ChatMessage response = await _getChatResponse(text);
    setState(() {
      _messages.insert(0, response);
    });
    ChatHistoryHelper.saveChatHistory(_messages);
    if (response.error.isEmpty && HttpTool.apiKey.isEmpty) {
      // show snackbar to let the user know that the chatbot is not configured
      _showNotConfiguredApiSnackBar();
    }
  }

  void _showNotConfiguredApiSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('API key is not Configured'),
        action: SnackBarAction(
            label: 'Configured',
            onPressed: () async {
              // show the configuration dialog
              await _showApiKeyConfigDialog();
            }),
      ),
    );
  }

  Future _showApiKeyConfigDialog() async {
    final result = await InputDialog.show(
        context: context, content: HttpTool.apiKey, title: 'Configure Api Key');
    if (result != null) {
      HttpTool.apiKey = result;
    }
  }

  Future<ChatMessage> _getChatResponse(String text) async {
    return await HttpTool.post(text);
  }

  Widget _buildTextComposer() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _sendQuestion,
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
                // max lines should be 5
                // maxLines: 5,
                // minLines: 1,
                // ctrl + enter should send the message, enter should add a new line
                textInputAction: TextInputAction.newline,
              
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendQuestion(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        reverse: true,
        itemCount: _messages.length,
        itemBuilder: (_, int index) => _buildMessageItem(_messages[index]),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    // show an avatar for the user and the bot, use Icons.person for the user
    // and Icons.android for the bot
    // background color for the user should be blue and green for the bot
    // message content should be selectable
    // if the message has an error, show the error message instead of the content
    // and error messages should be red
    // add action, for user messages, retry sending the message
    // for bot messages, copy the message to the clipboard
    return Container(
      color: message.author == 'User' ? Colors.blue[50] : Colors.green[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              message.author == 'User' ? Colors.blue : Colors.green,
          child: Icon(message.author == 'User' ? Icons.person : Icons.android),
        ),
        title: SelectableText(
          message.error.isNotEmpty ? message.error : message.content.trim(),
          style: TextStyle(color: message.error.isNotEmpty ? Colors.red : null),
        ),
        subtitle: Text(_formatTimestamp(message.timeStamp)),
        trailing: message.author == 'User'
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  // retry sending the message
                  _sendQuestion(message.content);
                },
              )
            : IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  // copy the message to the clipboard
                  Clipboard.setData(ClipboardData(text: message.content));
                  // show a snackbar to let the user know that the message is copied
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message copied to clipboard'),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // convert the timestamp to a human readable format. e.g. 2 minutes ago
  /// Returns a string representation of the date and time
  /// formatted as "Just now", "minutes ago", "hours ago",
  /// or "days ago".
  String _formatTimestamp(DateTime timestamp) {
    var now = DateTime.now();
    var difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  Future _showProxyConfigDialog() async {
    final result = await InputDialog.show(
        context: context, content: HttpTool.httpProxy, title: 'Configure Proxy');
    if (result != null) {
      HttpTool.httpProxy = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Boot App"),
        // more action for set api key and proxy
        actions: [
          // clear chat history button
          IconButton(
            tooltip: 'Clear Chat History',
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _messages.clear();
                ChatHistoryHelper.clearChatHistory();
              });
            },
          ),
          IconButton(
            tooltip: 'Configure Api Key',
            icon: const Icon(Icons.key),
            onPressed: () async {
              await _showApiKeyConfigDialog();
              // show more option dropdown
              //await _showMoreOptionDialog();
            },
          ),
          IconButton(
            tooltip: 'Configure Proxy',
            icon: const Icon(Icons.network_ping),
            onPressed: () async {
              await _showProxyConfigDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildMessageList(),
          const Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }
}
