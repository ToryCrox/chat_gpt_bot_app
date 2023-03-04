import 'package:chat_boot_app/type_util.dart';

/// chatGpt api response like this:
/// {
//   "id": "chatcmpl-123",
//   "object": "chat.completion",
//   "created": 1677652288,
//   "choices": [{
//     "index": 0,
//     "message": {
//       "role": "assistant",
//       "content": "\n\nHello there, how may I assist you today?",
//     },
//     "finish_reason": "stop"
//   }],
//   "usage": {
//     "prompt_tokens": 9,
//     "completion_tokens": 12,
//     "total_tokens": 21
//   }
// }

class ChatResponse {
  String id;
  String object;
  int created;
  List<Choice> choices;
  Usage usage;

  ChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.choices,
    required this.usage,
  });

  factory ChatResponse.fromMap(Map<String, dynamic> map) {
    return ChatResponse(
      id: TypeUtil.parseString(map['id']),
      object: TypeUtil.parseString(map['object']),
      created: TypeUtil.parseInt(map['created']),
      choices: TypeUtil.parseList(
          map['choices'], (e) => Choice.fromMap(TypeUtil.parseMap(e))),
      usage: Usage.fromMap(TypeUtil.parseMap(map['usage'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'choices': choices.map((e) => e.toMap()).toList(),
      'usage': usage.toMap(),
    };
  }
}

class Choice {
  int index;
  Msg message;
  String finishReason;

  Choice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      index: TypeUtil.parseInt(map['index']),
      message: Msg.fromMap(TypeUtil.parseMap(map['message'])),
      finishReason: TypeUtil.parseString(map['finish_reason']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'message': message.toMap(),
      'finishReason': finishReason,
    };
  }
}

class Msg {
  String role;
  String content;

  Msg({required this.role, required this.content});

  factory Msg.fromMap(Map<String, dynamic> map) {
    return Msg(
      role: TypeUtil.parseString(map['role']),
      content: TypeUtil.parseString(map['content']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class Usage {
  int promptTokens;
  int completionTokens;
  int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromMap(Map<String, dynamic> map) {
    return Usage(
      promptTokens: TypeUtil.parseInt(map['prompt_tokens']),
      completionTokens: TypeUtil.parseInt(map['completion_tokens']),
      totalTokens: TypeUtil.parseInt(map['total_tokens']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }
}

// write a [Message] class that has author, timeStamp, and content fields
class ChatMessage {
  final String author;
  final String content;
  final DateTime timeStamp;

  final String error;


  const ChatMessage({
    required this.author,
    required this.content,
    required this.timeStamp,
    this.error = '',
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      author: TypeUtil.parseString(map['author']),
      content: TypeUtil.parseString(map['content']),
      timeStamp: DateTime.fromMillisecondsSinceEpoch(TypeUtil.parseInt(map['timeStamp'])),
      error: TypeUtil.parseString(map['error']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'content': content,
      'timeStamp': timeStamp.millisecondsSinceEpoch,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'ChatMessage{author: $author, content: $content, timeStamp: $timeStamp, error: $error}';
  }
}