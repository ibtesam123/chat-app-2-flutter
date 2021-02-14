import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';

// import 'package:flutter_socket_io/flutter_socket_io.dart';
// import 'package:flutter_socket_io/socket_io_manager.dart';
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

  // SocketIO socketIO;
  // var io = new Server();
  // var nsp = io.of('');

  // final client = StompClient(
  //     config: StompConfig.SockJS(
  //         url: 'https://127.0.0.1:8080/ws-stomp',
  //         onConnect: (StompClient client, StompFrame frame) => client.subscribe(
  //             destination: '/ws-stomp',
  //             callback: (StompFrame frame) {
  //               var jsonData = json.decode(frame.body);
  //               print(jsonData);
  //             }),
  //         onWebSocketError: (dynamic error) => print(error.toString()),
  //         onDebugMessage: (dynamic msg) => print(msg.toString()),
  //         reconnectDelay: 0,
  //         connectionTimeout: Duration(seconds: 2)));

  void init() {
    currentUser = users[0];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    IO.Socket socket = IO.io('http://localhost:8081',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setExtraHeaders({'query': 'chatID=${currentUser.chatID}'}) // optional
            .build());
    // IO.Socket socket = IO.io(
    //     'http://localhost:8080/sub/chat/room/1fb99464-8be6-4240-b7af-decae0402447',
    //     IO.OptionBuilder()
    //         .setTransports(['websocket']) // for Flutter or Dart VM
    //         .setExtraHeaders({'token': token}) // optional
    //         .build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('connection', 'hello');
    });

    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));

    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });
    // socket.on('event', (data) => print(data));
    // socket.onDisconnect((_) => print('disconnect'));
    // socket.on('fromServer', (_) => print(_));

    // socketIO = SocketIOManager().createSocketIO(
    //     'http://localhost:8081', '/',
    //     query: 'chatID=${currentUser.chatID}');
    // socketIO.init();

    // socketIO.subscribe('receive_message', (jsonData) {
    //   Map<String, dynamic> data = json.decode(jsonData);
    //   messages.add(Message(
    //       data['content'], data['senderChatID'], data['receiverChatID']));
    //   notifyListeners();
    // });

    socket.connect();

    // socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    final jsonEncoder = JsonEncoder();
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    // client.send(
    //     destination: '/pub/chat/message',
    //     body: json.encode({
    //       'type': 'TALK',
    //       'roomId': '1fb99464-8be6-4240-b7af-decae0402447',
    //       'message': text
    //     }),
    //     headers: {"token": token});
    // IO.Socket socket = IO.io('http://localhost:8080/pub/chat/message',
    //     IO.OptionBuilder()
    //         .setTransports(['websocket']) // for Flutter or Dart VM
    //         .setExtraHeaders({'token': token}) // optional
    //         .build());
    IO.Socket socket = IO.io('http://localhost:8081', <String, dynamic>{
      'transports': ['websocket'],
      'query': 'chatID=${currentUser.chatID}'
    });
    socket.emit(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    // socket.emit(
    //   'sendMessage',
    //   json.encode({
    //     'type': 'TALK',
    //     'roomId': '1fb99464-8be6-4240-b7af-decae0402447',
    //     'message': text,
    //     "sender":"11",
    //     "userCount":0
    //   }),
    // );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}
