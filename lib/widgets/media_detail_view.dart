// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MediaDetailView extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;

  const MediaDetailView({
    required this.mediaUrl,
    this.isVideo = false,
    Key? key,
  }) : super(key: key);

  @override
  State<MediaDetailView> createState() => _MediaDetailViewState();
}

class _MediaDetailViewState extends State<MediaDetailView> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool isPlaying = false;
  bool isInitialized = false;
  String? errorMessage;
  bool isYoutubeVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  bool _isYoutubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  String? _getYoutubeId(String url) {
    try {
      return YoutubePlayer.convertUrlToId(url);
    } catch (e) {
      print('Error extracting YouTube ID: $e');
      return null;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      if (!widget.mediaUrl.startsWith('http')) {
        setState(() {
          errorMessage = 'Invalid video URL';
        });
        return;
      }

      // Check if it's a YouTube video
      if (_isYoutubeUrl(widget.mediaUrl)) {
        final youtubeId = _getYoutubeId(widget.mediaUrl);
        if (youtubeId == null) {
          setState(() {
            errorMessage = 'Invalid YouTube URL';
          });
          return;
        }

        isYoutubeVideo = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            showLiveFullscreenButton: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            hideControls: false,
          ),
        );

        if (mounted) {
          setState(() {
            isInitialized = true;
          });
        }
        return;
      }

      // If not YouTube, use regular video player
      _videoController = VideoPlayerController.network(widget.mediaUrl);
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _videoController?.pause();
        _youtubeController?.pause();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _videoController?.pause();
              _youtubeController?.pause();
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: widget.isVideo
                ? _buildVideoPlayer()
                : Image.network(
                    widget.mediaUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 48.sp),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (!isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (isYoutubeVideo && _youtubeController != null) {
      return OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
                onReady: () {
                  print('YouTube Player is ready');
                },
                onEnded: (data) {
                  _youtubeController?.pause();
                },
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(
                    isExpanded: true,
                    colors: const ProgressBarColors(
                      playedColor: Colors.red,
                      handleColor: Colors.redAccent,
                    ),
                  ),
                  RemainingDuration(),
                  const PlaybackSpeedButton(),
                ],
              ),
              builder: (context, player) {
                return Container(
                  color: Colors.black,
                  child: player,
                );
              },
            ),
          );
        },
      );
    }

    if (_videoController != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isPlaying = !isPlaying;
                if (isPlaying) {
                  _videoController!.play();
                } else {
                  _videoController!.pause();
                }
              });
            },
            child: AnimatedOpacity(
              opacity: isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 60.h,
                width: 60.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}