import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multicast_app/custom_toast.dart';
import 'package:multicast_app/socket_manager.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  String name;
  VideoPlayerScreen({super.key, required this.name});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  String videoUrl = 'udp://224.1.1.1:5004'; // Địa chỉ video multicast
  final WebSocketClient _socketChannel = WebSocketClient();
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _socketChannel.init(_readMessage);
    _initializeVideoPlayer();
  }

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      final comment = {
        'name': widget.name,
        'content': _commentController.text,
      };
      log(comment.toString());
      _socketChannel.sendMessage(comment);
      comments.add(comment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
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
    if (message == 'start_stream') {
      _controller.dispose();
      _initializeVideoPlayer();
    } else if (message == 'pause') {
      if (_controller.value.isPlaying) {
        _controller.pause();
        CustomToast.showToastSuccess(context, description: 'Dừng video');
      }
    } else {
      try {
        Map<String, dynamic> comment = jsonDecode(message);
        setState(() {
          comments.add(comment);
        });
      } catch (e) {
        CustomToast.showToastWarning(context, description: 'Lỗi xảy ra');
        log('Error decoding message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          title: const Text(
            'Multicast Video Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                child: _controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Text('Trò chuyện trực tiếp',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.circle, color: Colors.blue, size: 15),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[comments.length - 1 - index];
                    return ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text.rich(
                        TextSpan(
                          text: comment['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: ': ${comment['content']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                        hintText: 'Trò chuyện...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
