import 'package:scoped_model/scoped_model.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'dart:convert';

import './User.dart';
import './Message.dart';

class ChatModel extends Model {
  List<User> users = [
    User('IronMan', '111'),
    User('Captain America', '222'),
    User('Antman', '333'),
    User('Hulk', '444'),
    User('Thor', '555'),
  ];

  User currentUser;
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  String token =
      "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIxMSIsImlhdCI6MTYxMzI1NjI5OSwiZXhwIjoxNjEzMjU5ODk5fQ.JBsFKDOM19QyxrDT-Nj2j7C4aq-iPvCiPTOK9Zs43EY";

  final client = StompClient(
      config: StompConfig.SockJS(
          url: 'http://localhost:8080/gs-guide-websocket',
          onConnect: (StompClient client, StompFrame frame) => client.subscribe(
              destination: '/topic/greetings',
              callback: (StompFrame frame) {
                var jsonData = json.decode(frame.body);
                print(jsonData);
              }),
          onWebSocketError: (dynamic error) => print(error.toString()),
          onDebugMessage: (dynamic msg) => print(msg.toString()),
          reconnectDelay: 0,
          connectionTimeout: Duration(seconds: 2)));

  void init() {
    currentUser = users[0];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();
    client.activate();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    client.send(
        destination: '/app/hello',
        body: json.encode({'name': text}));
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}
