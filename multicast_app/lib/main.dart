import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:multicast_app/custom_toast.dart';
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
    _socketChannel.init(_readMessage);
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
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

  void _readMessage(String message) {
    log('Refreshing screen... Message: $message');
    if (message == 'start_stream') {
      _controller.dispose();
      _initializeVideoPlayer();
    } else if (message == 'pause') {
      if (_controller.value.isPlaying) {
        _controller.pause();
        CustomToast.showToastSuccess(context, description: 'Dừng video');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multicast Video Player')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(
                    color: Colors.green,
                  ),
          ),
        ),
      ),
    );
  }
}
