import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  final String socketUrl = 'ws://192.168.1.8:8765';
  late WebSocketChannel _channel;

  void init() {
    _channel = WebSocketChannel.connect(Uri.parse(socketUrl));
    _channel.stream.listen((message) {
      log('Received message from server: $message');
      // Xử lý message nhận từ server
    }, onError: (error) {
      log('Error: $error');
    }, onDone: () {
      log('Connection closed');
    });
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
    log('Sent message to server: $message');
  }

  void dispose() {
    _channel.sink.close();
  }
}
