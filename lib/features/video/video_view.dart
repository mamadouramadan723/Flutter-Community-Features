import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType,
  });

  final String url;
  final DataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubePlayerController;

  @override
  void initState() {
    super.initState();

    if (widget.url.contains("youtu")) {
      // Initialize YouTube player controller
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.url) ?? "",
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    } else {
      // Initialize video player controller for other sources
      switch (widget.dataSourceType) {
        case DataSourceType.asset:
          _videoPlayerController = VideoPlayerController.asset(widget.url);
          break;
        case DataSourceType.network:
          _videoPlayerController =
              VideoPlayerController.networkUrl(Uri.parse(widget.url));
          break;
        case DataSourceType.file:
          _videoPlayerController = VideoPlayerController.file(File(widget.url));
          break;
        case DataSourceType.contentUri:
          _videoPlayerController =
              VideoPlayerController.contentUri(Uri.parse(widget.url));
          break;
      }

      _videoPlayerController.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: 16 / 9,
            autoPlay: true,
            looping: true,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.dataSourceType.name.toUpperCase(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: widget.url.contains("youtu")
              ? YoutubePlayer(
                  controller: _youtubePlayerController!,
                  showVideoProgressIndicator: true,
                )
              : _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
