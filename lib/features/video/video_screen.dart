import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transverse/features/video/video_view.dart';
import 'package:video_player/video_player.dart';

import 'select_video.dart';

class VideoPlayersScreen extends StatefulWidget {
  const VideoPlayersScreen({super.key});

  @override
  State<VideoPlayersScreen> createState() => _VideoPlayersScreenState();
}

class _VideoPlayersScreenState extends State<VideoPlayersScreen> {
  final List<VideoItem> _videoItems = [
    VideoItem(
      url: 'assets/island.mp4',
      dataSourceType: DataSourceType.asset,
    ),
    VideoItem(
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      dataSourceType: DataSourceType.network,
    ),
  ];

  void _addVideo(File file) {
    setState(() {
      _videoItems.add(
        VideoItem(
          url: file.path,
          dataSourceType: DataSourceType.file,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Players')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectVideo(onVideoSelected: _addVideo),
          const SizedBox(height: 24),

          // Dynamically generated list of VideoPlayerView widgets
          for (var videoItem in _videoItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: VideoPlayerView(
                url: videoItem.url,
                dataSourceType: videoItem.dataSourceType,
              ),
            ),
        ],
      ),
    );
  }
}

class VideoItem {
  final String url;
  final DataSourceType dataSourceType;

  VideoItem({
    required this.url,
    required this.dataSourceType,
  });
}
