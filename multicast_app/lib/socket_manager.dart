import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  final String socketUrl = 'ws://192.168.1.13:8765';
  late WebSocketChannel _channel;
  late Function(String) onMessageReceived;
  void init(Function(String) onMessageReceived) {
    this.onMessageReceived = onMessageReceived;
    _channel = WebSocketChannel.connect(Uri.parse(socketUrl));
    _channel.stream.listen((message) {
      log('Received message from server: $message');
      onMessageReceived(message);
    }, onError: (error) {
      log('Error: $error');
    }, onDone: () {
      log('Connection closed');
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    String jsonString = jsonEncode(message);
    _channel.sink.add(jsonString);
  }

  void dispose() {
    _channel.sink.close();
  }
}
