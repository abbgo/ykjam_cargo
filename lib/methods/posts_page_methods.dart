import 'package:flutter/material.dart';
import 'package:ykjam_cargo/datas/post_data.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';

ElevatedButton elevatedButtonMethod(
    String text, IconData icon, Function()? onPressed, List<Post> posts) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100),
    onPressed: onPressed,
    child: Row(
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    ),
  );
}

Column columnMethod(int index, List<Post> posts, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        posts[index].authorName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              posts[index].timeAgo,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Icon(
                  Icons.remove_red_eye,
                  color: Colors.grey.shade600,
                  size: 12,
                ),
                Text(
                  posts[index].viewCount.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        posts[index].title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: calculateFontSize(context, 16),
        ),
      ),
    ],
  );
}
