import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoThumbnail extends StatelessWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const VideoThumbnail({
    Key? key,
    required this.videoUrl,
    required this.onTap,
  }) : super(key: key);

  String? _getYoutubeId(String url) {
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      }
      if (url.contains('youtube.com/watch')) {
        return YoutubePlayer.convertUrlToId(url);
      }
      return null;
    } catch (e) {
      print('Error extracting YouTube ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final youtubeId = _getYoutubeId(videoUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: youtubeId != null
                  ? Image.network(
                      'https://img.youtube.com/vi/$youtubeId/0.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
              child: Icon(
                Icons.play_arrow,
                size: 20.sp,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.video_library,
          size: 30.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
} 