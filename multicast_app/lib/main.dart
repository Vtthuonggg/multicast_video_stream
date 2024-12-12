import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:multicast_app/login_page.dart';
import 'package:multicast_app/socket_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multicast Video Player',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  String videoUrl = 'udp://224.1.1.1:5004'; // Địa chỉ video multicast
  final WebSocketClient _socketChannel = WebSocketClient();

  @override
  void initState() {
    super.initState();
    _socketChannel.init(_refreshScreen);
    _initializeVideoPlayer();
  }

  // Hàm khởi tạo video mới
  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Cập nhật lại giao diện khi video được khởi tạo
        _controller.play();
        log('Video initialized and playing');
      }).catchError((error) {
        log('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _socketChannel.dispose();
    super.dispose();
  }

  // Hàm refresh màn hình khi đổi video
  void _refreshScreen(String message) {
    log('Refreshing screen... Message: $message');
    _controller.dispose();

    // Cập nhật URL video nếu cần thiết
    videoUrl = 'udp://224.1.1.1:5004'; // Hoặc video khác

    // Khởi tạo video mới với video URL mới
    _initializeVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multicast Video Player')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value
                            .aspectRatio, // Cập nhật tỷ lệ khung hình của video
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.green,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshScreen('Manual refresh'),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
