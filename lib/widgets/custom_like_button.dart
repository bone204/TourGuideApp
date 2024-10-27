import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CustomLikeButton extends StatelessWidget {
  final bool isLiked;
  final ValueChanged<bool> onLikeChanged;

  const CustomLikeButton({
    required this.isLiked,
    required this.onLikeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: isLiked,
      circleColor: const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: Colors.pink,
        dotSecondaryColor: Colors.white,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.favorite,
          color: isLiked ? Colors.red : Colors.grey.withOpacity(0.5),
          size: 30,
        );
      },
      onTap: (bool isLiked) async {
        onLikeChanged(!isLiked);
        return !isLiked;
      },
    );
  }
}
