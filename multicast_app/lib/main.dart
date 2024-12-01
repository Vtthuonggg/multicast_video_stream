import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:multicast_app/login_page.dart';
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
  String videoUrl = 'udp://224.1.1.1:5004';
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _connectWebSocket();
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

  void _connectWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.9:8765'));
    log('Connected to WebSocket server');
    channel.stream.listen((message) {
      log('Received message: $message');
      if (message == 'refresh_screen') {
        _refreshScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    channel.sink.close();
    super.dispose();
  }

  void _refreshScreen() {
    _controller.dispose();
    _initializeVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multicast Video Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: _controller.value.isInitialized
                    ? Expanded(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.green,
                      ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Đăng nhập'))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshScreen,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
