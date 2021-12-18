import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'bar.dart';
import 'video_player_mode.dart';

class PlayerScreen extends StatefulWidget {
  final String path;
  final VideoPlayerMode mode;
  final double screenWidth;

  const PlayerScreen({
    required this.path,
    required this.mode,
    required this.screenWidth,
    Key? key,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  static const _barWidth = 5.0;
  final List<int> _bars = [];
  bool _dragStarted = false;
  double _bar1Position = 0.0;

  @override
  void initState() {
    super.initState();
    print('PATH ' + widget.path);
    _controller = widget.mode == VideoPlayerMode.online
        ? VideoPlayerController.network(widget.path)
        : VideoPlayerController.file(File(widget.path));
    _controller
      ..initialize().then((value) {
        setState(() {});
      });

    _controller.addListener(() {
      final progress =
          (_controller.value.position.inSeconds / _controller.value.duration.inSeconds) * 100;
      final position = widget.screenWidth * progress / 100;
      if (!_dragStarted) {
        setState(() {
          _bar1Position = position;
        });
      }
    });

    var countBars = widget.screenWidth / 5;
    // generate random bars
    Random r = Random();
    for (var i = 0; i < countBars; i++) {
      _bars.add(r.nextInt(200));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Column(
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : CircularProgressIndicator(),
          _buildChart(context),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    int i = 0;

    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: _bars.map((int height) {
            Color color = i >= _bar1Position / _barWidth ? Colors.blueGrey : Colors.deepPurple;
            i++;

            return Container(
              color: color,
              height: height.toDouble(),
              width: 5.0,
            );
          }).toList(),
        ),
        Bar(
          position: _bar1Position,
          onHorizontalDragStart: (DragStartDetails details) {
            setState(() {
              _dragStarted = true;
            });
            _controller.pause();
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              _bar1Position += details.delta.dx;
            });
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            final progressInPercents = (_bar1Position / widget.screenWidth) * 100;
            final playerPosition =
                (_controller.value.duration.inSeconds * progressInPercents) ~/ 100;
            setState(() {
              _dragStarted = false;
            });
            _controller.seekTo(Duration(seconds: playerPosition));
            _controller.play();
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FloatingActionButton(
          onPressed: () {
            _controller.seekTo(_controller.value.position - Duration(seconds: 15));
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            _controller.seekTo(_controller.value.position + Duration(seconds: 15));
          },
          child: Icon(
            Icons.arrow_forward,
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
