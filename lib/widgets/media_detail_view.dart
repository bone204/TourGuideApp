import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaDetailView extends StatelessWidget {
  final String mediaUrl;
  final bool isVideo;

  const MediaDetailView({
    required this.mediaUrl,
    this.isVideo = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: isVideo
            ? Center(
                child: Text(
                  'Video Player will be implemented here',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              )
            : Image.network(
                mediaUrl,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}